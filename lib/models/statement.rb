module Model
	class Statement < Base
		ROUND_ETH_AMOUNTS_TO = Model::ROUND_ETH_AMOUNTS_TO
		DATA_MODEL = {
			tableName: 'statements',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: 'TEXT'},
				{ name: 'balance', type: 'NUMERIC'},
				{ name: 'amount', type: 'NUMERIC'},
				{ name: 'time', type: 'TEXT'},
				{ name: 'comissionRate', type: 'NUMERIC'},
				{ name: 'txIdShort', type: 'TEXT'},
				{ name: 'txFee', type: 'TEXT'},
				{ name: 'etherscanUrl', type: 'TEXT'},
				{ name: 'description', type: 'TEXT'},
				{ name: 'timeCreated', type: :time},
				{ name: 'timeUpdated', type: :time}
			]
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options = {})
			self.fieldNames.each do |f|
				self.send("#{f}=",options[f.to_sym])
			end
			@timeUpdated = Time.now
			@timeUpdated = Time.parse(options[:timeUpdated]) if options[:timeUpdated]
		end
		def parseMonobankStatement(stat)
			@_id = stat['id']
			@time = Time.at(stat['time']).strftime(Model::TIME_FORMAT)
			@amount = stat['amount'].to_f/100
			@description = stat['description']
			@balance = stat['balance'].to_f/100
			@timeCreated = @time
			@timeUpdated = Time.now
		end
		def parseEtherscanStatement(stat,address)
			fee = ((BigDecimal(stat['gasPrice']) * BigDecimal(stat['gasUsed'])) / 10**18).to_f.round(ROUND_ETH_AMOUNTS_TO)
			amount = (BigDecimal(stat['value']) / 10**18).to_f.round(ROUND_ETH_AMOUNTS_TO)
			if stat['from'].downcase == address.downcase then 
				symbol =  '-'
			else 
				symbol = '+'
			end
			@time = Time.at(stat['timeStamp'].to_i).strftime(Model::TIME_FORMAT)
			@amount = symbol + amount.to_s
			@_id = stat['hash']
			@txIdShort = "#{stat['hash'][0..6]}..#{stat['hash'][-6..-1]}"
			@etherscanUrl = "#{DataFactory::ETH::ETH_TX_URL}#{stat['hash']}"
			@txFee = fee
		end
	end
	class StatementsList < BaseList
		fieldSet = Statement::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: Statement::DATA_MODEL[:tableName], idField: Statement::DATA_MODEL[:idField], fieldSet: fieldSet)
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@list = []
			options.each {|opt| 
				model = Model::Statement.new(opt)
				@list.push(model)
			}
			return true
		end
		def parseMonobankStatements(options)
			@list = []
			options.each do |opt| 
				model = Model::Statement.new()
				model.parseMonobankStatement(opt)
				@list.push(model)
			end
			return true
		end
		def parseEtherscanStatements(options,address)
			@list = []
			options.each {|opt| 
				model = Model::Statement.new()
				model.parseEtherscanStatement(opt,address)
				@list.push(model)
			}
			return true
		end
		def getMonobankStatements(accountId,monoApiKey,settings)
			logger.debug("#{self.class} Getting Statements from Monobank by AccountId: #{accountId} with apiKey: #{monoApiKey}")
			self.parseMonobankStatements(DataFactory::Mono.get_statements(accountId,monoApiKey,settings))
			return true
		end
		def getEtherscanStatements(accountId,ethApiKey,settings)
			logger.debug("#{self.class} Getting Statements from Etherscan by AccountId: #{accountId}")
			self.parseEtherscanStatements(DataFactory::ETH.get_statements(accountId,ethApiKey,settings),accountId)
			return true
		end
	end
end