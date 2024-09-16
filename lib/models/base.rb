module Model
	class Base
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
	end
end