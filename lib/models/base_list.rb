module Model
	class BaseList
		include Logging
		MONGO_DEFAULT_PAGE_LIMIT = 100
		attr_accessor :list, :error, :sort, :page
		def initialize(options = [])
			@list = []
			@page = 0
			@size = MONGO_DEFAULT_PAGE_LIMIT
			@sort = {timeUpdated: -1}
			self.parseOptions!(options)

		end
		def model; Base::DATA_MODEL_OBJ_DEFAULT ;end
		def setUserId(id)
			@list.each do |el|
				el.userId = id
			end
		end
		def fieldNames
			return self.model.fieldSet.map { |e| e.name }
		end
		def filterByIdsList(ids = [],userId = '')
			ids = ids.map { |e| "#{e}_#{userId}" }
			return @list = @list.select{|i| ids.include?(i._id) } if !ids.empty?
		end
		def empty?
			return @list.empty?
		end
		def to_a
			return @list.map {|elem| elem.to_h}
		end
		def to_h
			return h = {
				content: @list.map {|elem| elem.to_h}, 
				pageNumber: @page,
				pageSize: @size,
				total: @total,
				sorting: @sort
			}

			
		end
		def getFromDb(page, size,request,sort = nil, user = nil)
			logger.debug("#{self.class} Getting #{page} page by #{size} #{model.tableName} from DB with request: #{request}, sort: #{sort}")
			logger.debug("#{self.class} Also filtering by user: #{user.userId}") if !user.nil?
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[model.tableName.to_sym]
				params = {}
				params[:limit] = size
				params[:skip] = page * size
				params[:sort] = sort || @sort
				aggregations = [
					{ "$facet": {
						"data": [
							{ "$sort": params[:sort]},
							{ "$match": request},
							{ "$skip": params[:skip] },
							{ "$limit": params[:limit] }
						],
						"totalCount": [{ "$group": {_id: nil, "count": { "$sum": 1 }}}]
					}
					}
				]
				aggregations.unshift({ "$match": { "userId": user.userId } }) if !user.nil?
				pagedata = collection.aggregate(aggregations)
				pagedata = pagedata.first
				self.parseOptions!(pagedata['data'])
				@page = page
				#@sort = sort
			ensure
				client.close if client
			end
			@sort = params[:sort]
			@size = pagedata['data'].size
			@total = pagedata['totalCount'].first['count'] if !pagedata['totalCount'].empty?
			return self
		end
		def saveToDb
			if !@list.empty?
				command = @list.map { |elem| 
					{replace_one: {
						filter: {model.idField => elem._id},
						replacement: elem.to_bson,
						upsert: true
						}
					}
				}
				#logger.debug("#{self.class} DB Command: #{command}")
				logger.info("#{self.class} BulkWriting #{@list.length} #{model.tableName} to DB")
				begin
					client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
					collection = client[model.tableName.to_sym]
					#@list.map { |e| e.saveToDb }
					data = collection.bulk_write(command,ordered:true)
				ensure
					client.close if client
				end
			else
				logger.debug("#{self.class} List is empty, nothing to write")
			end
			return self
		end
	end
end