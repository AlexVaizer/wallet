module Model
	class Jar < Base
		DATA_MODEL = {
			tableName: 'jars',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: :text},
				{ name: 'sendId', type: :text},
				{ name: 'title', type: :text},
				{ name: 'description', type: :text},
				{ name: 'currencyCode', type: :text},
				{ name: 'balance', type: :integer},
				{ name: 'goal', type: :integer},
				{ name: 'userId', type: :text},
				{ name: 'timeUpdated', type: :time},
				{ name: 'timeCreated', type: :time}
			]
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
		def parseMonobankJar(options,userId)
			@_id = options[:id] 
			@sendId = options[:sendId]
			@title = options[:title]
			@description = options[:description] 
			@currencyCode = DataFactory::CURRENCIES[options[:currencyCode].to_s]
			@balance = options[:balance].to_f/100 
			@goal = options[:goal].to_f/100
			@userId = userId
			return true
		end
	end
	class JarsList < BaseList
		fieldSet = Jar::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: Jar::DATA_MODEL[:tableName], idField: Jar::DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@list = []
			options.each {|acc| 
				model = Model::Jar.new(acc)
				@list.push(model)
			}
			return true
		end
		def parseMonobankJars(jars,allowedJars,userId)
			@list = []
			jars.each { |jar|
				jar = jar.transform_keys(&:to_sym)
				obj = Model::Jar.new()
				obj.parseMonobankJar(jar,userId)
				@list.push(obj)
			}
			logger.debug("#{self.class} Filtering retrieved jars by: #{allowedJars}")
			self.filterByIdsList(allowedJars)
		end
	end
end