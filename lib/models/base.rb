module Model
	class Base
		TIME_FORMAT = Model::TIME_FORMAT
		include Logging
		attr_reader :model
		attr_accessor :error
		def initialize(options = {})
			self.parseOptions(options)
		end
		def getFromDb()
			logger.debug("Getting #{@model[:tableName]} by '#{@id}' id from DB")
			data = DataFactory::SQLite.get(@model, @id)
			if data.nil? || data.empty?
				@error = {code: 404,message:"Could not find #{@model[:tableName]} by '#{@id}' id"}
				logger.debug(@error.to_s)
			else
				self.parseOptions(data)
			end
			return self
		end
		def saveToDb
			data = self.to_h
			logger.debug("Saving #{@model[:tableName]} to DB: #{data[:id]}")	
			DataFactory::SQLite.create(@model, data)
			return true
		end
		def deleteFromDb
			logger.debug("Deleting #{@model[:tableName]} by '#{@id}' id from DB")
			logger.debug("#{DataFactory::SQLite.delete(@model,@id)}")
		end
	end
	class BaseList
		include Logging
		attr_reader :model
		attr_accessor :list
		attr_accessor :error
		def initialize(options = [])
			@list = []
			self.parseOptions(options)
		end
		def setUserId(id)
			@list.each do |el|
				el.userId = id
			end
		end
		def filterByIdsList(ids = [])
			return @list = @list.select{|i| ids.include?(i.id) } if !ids.empty?
		end
		def empty?
			return @list.empty?
		end
		def to_a 
			return @list.map {|elem| elem.to_h}
		end
		def getFromDbByUser(userId)
			logger.debug("Getting All #{@model[:tableName]} List from DB")
			data = DataFactory::SQLite.get_all(@model)
			self.parseOptions(data)
			return self
		end
		def saveToDb()
			@list.each { |elem|
				logger.debug("Saving #{elem.model[:tableName]} #{elem.id} to DB")
				DataFactory::SQLite.create(elem.model, elem.to_h)
			}
		end
	end
end