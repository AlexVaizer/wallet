module Model
	class ZMTransaction < Base
		#ROUND_ETH_AMOUNTS_TO = Model::ROUND_ETH_AMOUNTS_TO
		DATA_MODEL = {
			tableName: 'transactions',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: :text},
				{ name: 'date', type: :time},
				{ name: 'categoryName', type: :text},
				{ name: 'payee', type: :text},
				{ name: 'comment', type: :text},
				{ name: 'outcomeAccountName', type: :text},
				{ name: 'outcome', type: :integer},
				{ name: 'outcomeCurrency', type: :text},
				{ name: 'incomeAccountName', type: :text},
				{ name: 'income', type: :integer},
				{ name: 'incomeCurrency', type: :text},
				{ name: 'timeCreated', type: :time},
				{ name: 'timeUpdated', type: :time},
			]
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
	end
	class ZMTxList < BaseList
		fieldSet = ZMTransaction::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: ZMTransaction::DATA_MODEL[:tableName], idField: ZMTransaction::DATA_MODEL[:idField], fieldSet: fieldSet)
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@list = []
			options.each {|acc| 
				parsed = Model::ZMTransaction.new(acc)
				@list.push(parsed)
			}
			return true
		end
	end
end