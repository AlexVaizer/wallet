module Model
	MONGO_LOGIN = ENV['WALLET_MONGO_LOGIN'] 
	MONGO_PASSWORD = ENV['WALLET_MONGO_PASSWORD']
	MONGO_STRING = ENV['WALLET_MONGO_STRING']
	MONGO_DATABASE = "wallet-dev"
	require 'mongo'
	require 'securerandom'
	Field = Struct.new(:name, :type, keyword_init: true)	
	DataModel = Struct.new(:tableName, :idField, :fieldSet, keyword_init: true)
	Error = Struct.new(:code, :message, :exception, keyword_init: true)
	class Base
		DATA_MODEL_OBJ_DEFAULT = Model::DataModel.new(tableName: 'default', idField: '_id', fieldSet: [])
		TIME_FORMAT = Model::TIME_FORMAT
		include Logging
		attr_reader :error
		def initialize(options = {})
			@error = nil
			parseOptions!(options)
		end
		def parseOptions!(options = {})			
			fieldNames.each do |f|
				self.instance_variable_set("@#{f}", options[f.to_sym]) if !options[f.to_sym].nil?
			end if !options.nil?
		end
		def parseOptions(options = {})			
			options.each do |k,v|
				if fieldNames.include?(k)
					instance_variable_set("@#{k}", v)
				else
					@error = {code: 400,message:"Field: #{k} does not exist"}
				end
			end if !options.nil?
		end
		def model
			DATA_MODEL_OBJ_DEFAULT
		end
		def fieldNames
			return self.model.fieldSet.map { |e| e.name }
		end
		def to_h
			h = {}
			self.fieldNames.each do |f|
				h[f.to_sym] = self.instance_variable_get("@#{f}") #if !self.instance_variable_get("@#{f}").nil?
			end
			h[:timeUpdated] = (@timeUpdated.strftime(TIME_FORMAT) if @timeUpdated)
			h[:timeCreated] = (@timeUpdated.strftime(TIME_FORMAT) if @timeUpdated)
			return h
		end
		def to_bson
			h = {}
			self.fieldNames.each do |f|
				h[f.to_sym] = self.instance_variable_get("@#{f}")
			end
			h[:timeUpdated] = Time.now
			return h
		end

		def tableNameSym
			self.model.tableName.to_sym
		end

		def idFieldSym
			self.model.idField.to_sym
		end

		def getFromDb
			logger.debug("#{self.class} Getting #{self.model.tableName} by '#{@_id}' id from DB")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				coll = client[tableNameSym]
				data = coll.find({idFieldSym => @_id}).first
				if data.nil?
					@error = {code: 404,message:"Could not find #{self.model.tableName} by '#{@_id}' id"}
					logger.debug(@error.to_s)
				else
					self.parseOptions!(data)
				end
				client.close
			rescue => e 
				client.close
				raise e
			end
			return self
		end
		def saveToDb
			if @_id.nil? || @_id.empty?
				logger.debug("#{self.class} has no _id, generating one")	
				@_id = SecureRandom.uuid
			end
			logger.debug("#{self.class} Replacing #{self.model.tableName} by '#{@_id}'")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[tableNameSym]
				data = collection.replace_one({idFieldSym => @_id},self.to_bson, upsert: true)
				client.close
			rescue => e 
				client.close
				raise e
			end
			return self
		end
		def insertToDb
			@_id = SecureRandom.uuid if @_id.nil? || @_id.empty?
			logger.debug("#{self.class} Inserting #{self.model.tableName}")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[tableNameSym]
				payload = self.to_bson
				payload[:timeCreated] = Time.now
				data = collection.insert_one(payload)
				client.close
			rescue => e 
				client.close
				raise e
			end
			return self
		end		
		def deleteFromDb
			logger.debug("#{self.class} Deleting #{model.tableName} by '#{@_id}' id from DB")
			begin
				#client = self.mongoClient
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[self.model.tableName.to_sym]
				data = collection.delete_one({idFieldSym => @_id})
				client.close
			rescue => e 
				client.close
				raise e
			end
			return self
		end
	end
	class BaseList
		include Logging
		MONGO_DEFAULT_PAGE_LIMIT = 100
		attr_accessor :list
		attr_accessor :error
		def initialize(options = [])
			@list = []
			@page = 0
			@size = MONGO_DEFAULT_PAGE_LIMIT
			@sort = {createddate: -1}
			self.parseOptions!(options)

		end
		def model; Base::DATA_MODEL_OBJ_DEFAULT ;end
		def setUserId(id)
			@list.each do |el|
				el.userId = id
			end
		end
		# def mongoClient
		# 	return client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
		# end
		def fieldNames
			return self.model.fieldSet.map { |e| e.name }
		end
		def filterByIdsList(ids = [])
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
				page: @list.map {|elem| elem.to_h}, 
				pageNumber: @page,
				pageSize: @size,
				total: @total,
				sorting: @sort
			}

			
		end
		def getFromDb(page = @page, size = @size, request = {},sort = @sort)
			logger.debug("#{self.class} Getting #{size} #{model.tableName} from DB with params: #{request}")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[model.tableName.to_sym]
				params = {}
				params[:limit] = size
				params[:skip] = page * size
				params[:sort] = sort
				aggregations = [
					{ "$facet": {
						"data": [
							{ "$sort": sort},
							{ "$match": request},
							{ "$skip": size*page },
							{ "$limit": size }
						],
						"totalCount": [{ "$group": {_id: nil, "count": { "$sum": 1 }}}]
					}
					}
				]
				pagedata = collection.aggregate(aggregations)
				pagedata = pagedata.first
				self.parseOptions!(pagedata['data'])
				@page = page
				@sort = sort
				client.close
			rescue => e
				client.close
				raise e
			end
			@size = pagedata['data'].size
			@total = pagedata['data'].size
			@total = pagedata['totalCount'].first['count'] if !pagedata['totalCount'].empty?
			return self
		end
		def saveToDb
			# command = @list.map { |elem| 
			# 	{'replace_one' => {
			# 		'filter' => {model.idField => elem._id},
			# 		'replacement' => elem.to_bson,
			# 		'upsert' => true
			# 	}
			# }}
			# logger.debug("#{self.class} DB Command: #{command}")
			logger.info("#{self.class} BulkWriting #{@list.length} #{model.tableName} to DB")
			begin
				# client = self.mongoClient
				# collection = client[model.tableName.to_sym]
				@list.map { |e| e.saveToDb }
				#data = collection.bulk_write(command,ordered:false)
				#self.parseOptions!(data.to_a)
				# client.close
			rescue => e
				# client.close
				raise e
			end
			return self
		end
	end
end