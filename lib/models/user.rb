module Model
	class User < Base
		require 'bcrypt'
		DATA_MODEL = {
			tableName: 'users',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: :text},
				{ name: 'password', type: :text},
				{ name: 'monoApiKey', type: :text},
				{ name: 'allowedAccountIds', type: :text},
				{ name: 'allowedJarIds', type: :text},
				{ name: 'ethAddresses', type: :text},
				{ name: 'ethApiKey', type: :text},
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
		def mongoClient
			return client = Mongo::Client.new(Model::MONGO_STRING, database: 'wallet-dev')
		end
		def parseCryptedPass()
			return BCrypt::Password.new(@password) if @password
		end
	end
	class UsersList < BaseList
		fieldSet = User::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: User::DATA_MODEL[:tableName], idField: User::DATA_MODEL[:idField], fieldSet: fieldSet)
		def model
			DATA_MODEL_OBJ
		end
		def mongoClient
			return client = Mongo::Client.new(Model::MONGO_STRING, database: 'wallet-dev')
		end
		def parseOptions!(options)
			@list = []
			options.each {|acc| 
				model = Model::User.new(acc)
				@list.push(model)
			}
			return true
		end
	end
end