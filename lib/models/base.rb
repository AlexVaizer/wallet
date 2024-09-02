module Model
	class Base
		attr_reader :model
		attr_accessor :error, :logger
		def initialize(options = {},logger = nil)
			@logger = logger
			self.parseOptions(options)
		end
		def getFromDb()
			Model.logDebug(@logger, "Getting #{@model} by '#{@id}' id from DB")
			data = DataFactory::SQLite.get(@model, @id)
			#Model.logDebug(@logger, "DB Response: #{data}")
			if data.nil? || data.empty?
				@errors = {code: 404,message:"Could not find #{@model} by '#{@id}' id"}
				Model.logError(@logger, @errors.to_s)
				return false
			else
				self.parseOptions(data)
				return true
			end
		end
		def saveToDb
			data = self.to_h
			Model.logDebug(@logger, "Saving #{@model} to DB: #{data[:id]}")	
			DataFactory::SQLite.create(@model, data)
			return true
		end
	end
	class BaseList
		attr_reader :model
		attr_accessor :list, :error, :logger
		def initialize(options = [],logger = nil)
			@logger = logger
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