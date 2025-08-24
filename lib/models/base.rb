module Model
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
				if fieldNames.include?(k.to_s)
					self.instance_variable_set("@#{k}", v)
				else
					@error = {code: 400,message:"Field: #{k} does not exist. Existing fieldNames: #{fieldNames.to_s}"}
				end
			end if !options.nil?
		end
		def model
			DATA_MODEL_OBJ_DEFAULT
		end
		def fieldNames
			return self.model.fieldSet.map { |e| e.name }
		end
		def fieldSet
			return self.model.fieldSet.map {|e| e.to_h}
		end
		def to_h
			h = {}
			self.fieldNames.each do |f|
				h[f.to_sym] = self.instance_variable_get("@#{f}") #if !self.instance_variable_get("@#{f}").nil?
			end
			#todo add date formatting
			return h
		end
		def to_bson
			h = {}
			@timeUpdated = Time.now
			@timeCreated = Time.now if h[:timeCreated].nil?
			self.fieldNames.each do |f|
				h[f.to_sym] = self.instance_variable_get("@#{f}")
			end
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
			ensure
				client.close if client
			end
			return self
		end
		def saveToDb
			logger.debug("#{self.class} Replacing #{self.model.tableName} by '#{@_id}'")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[tableNameSym]
				data = collection.replace_one({idFieldSym => @_id},self.to_bson, upsert: true)
			ensure 
				client.close if client
			end
			return self
		end
		def insertToDb
			@_id = SecureRandom.uuid
			logger.debug("#{self.class} Inserting #{self.model.tableName}")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[tableNameSym]
				payload = self.to_bson
				payload[:timeCreated] = Time.now
				data = collection.insert_one(payload)
			ensure
				client.close if client
			end
			return self
		end		
		def deleteFromDb
			logger.debug("#{self.class} Deleting #{model.tableName} by '#{@_id}' id from DB")
			begin
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				collection = client[self.model.tableName.to_sym]
				data = collection.delete_one({idFieldSym => @_id})
			ensure
				client.close if client
			end
			return self
		end
	end
end