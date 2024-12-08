module Model
	class ZMAccount < Base
		#ROUND_ETH_AMOUNTS_TO = Model::ROUND_ETH_AMOUNTS_TO
		DATA_MODEL = {
			tableName: 'accounts',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: 'TEXT'},
				{ name: 'name', type: 'TEXT'}
			]
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
	end
	class ZMAccountsList < BaseList
		DATA_MODEL_OBJ = ZMAccount::DATA_MODEL_OBJ
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@list = []
			options.each {|acc| 
				parsed = Model::ZMAccount.new(acc)
				@list.push(parsed)
			}
			return true
		end
	end
end