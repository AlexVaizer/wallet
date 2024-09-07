module Model
	class Jar < Base
		DATA_MODEL = {
			tableName: 'jars',
			idField: 'id',
			fields: [ 
				{ name: 'id', type: 'TEXT'},
				{ name: 'sendId', type: 'TEXT'},
				{ name: 'title', type: 'TEXT'},
				{ name: 'description', type: 'TEXT'},
				{ name: 'currencyCode', type: 'TEXT'},
				{ name: 'balance', type: 'NUMERIC'},
				{ name: 'goal', type: 'NUMERIC'},
				{ name: 'timeUpdated', type: 'TEXT'}
			]
		}
		PRINTABLE_ATTRS = [:id, :sendId, :title, :description, :currencyCode, :balance, :goal]
		attr_accessor(*PRINTABLE_ATTRS) 
		def parseOptions(options)
			@id = options[:id] 
			@sendId = options[:sendId]
			@title = options[:title]
			@description = options[:description] 
			@currencyCode = options[:currencyCode]
			@balance = options[:balance] 
			@goal = options[:goal]
			@error = nil
			@model = DATA_MODEL
			return true
		end
		def parseMonobankJar(options)
			@id = options[:id] 
			@sendId = options[:sendId]
			@title = options[:title]
			@description = options[:description] 
			@currencyCode = DataFactory::CURRENCIES[options[:currencyCode].to_s]
			@balance = options[:balance].to_f/100 
			@goal = options[:goal].to_f/100
			return true
		end
		def to_h
			return result = {
				:id => @id,
				:sendId => @sendId,
				:title => @title,
				:description => @description,
				:currencyCode => @currencyCode,
				:balance => @balance,
				:goal => @goal
			}
		end
	end
	class JarsList < BaseList
		def parseOptions(options)
			@list = []
			options.each {|acc| 
				model = Model::Jar.new(acc, @logger)
				@list.push(model)
			}
			@model = Jar::DATA_MODEL
			return true
		end
		def saveToDb()
			Model.logDebug(@logger, "Saving Jars to DB")
			@list.each { |jar|
				DataFactory::SQLite.create(jar.model, jar.to_h)
			}
		end
		def getFromDbByUser()
			Model.logDebug(@logger, "Getting All Jars List from DB")
			data = DataFactory::SQLite.get_all(@model)
			if data.nil? || data.empty?
				@errors = {code: 404,message:"Could not find #{@model[:tableName]}"}
				Model.logError(@logger, @errors.to_s)
				return false
			else
				self.parseOptions(data)
				return true
			end
		end
		def parseMonobankJars(jars,allowedJars)
			@list = []
			jars.each { |jar|
				jar = jar.transform_keys(&:to_sym)
				obj = Model::Jar.new({},@logger)
				obj.parseMonobankJar(jar)
				@list.push(obj)
			}
			Model.logDebug(@logger, "Filtering retrieved jars by: #{allowedJars}")
			self.filterByIdsList(allowedJars)
		end
	end
end