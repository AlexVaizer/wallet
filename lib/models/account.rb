module Model
	class Account < Base
		ROUND_ETH_AMOUNTS_TO = Model::ROUND_ETH_AMOUNTS_TO
		DATA_MODEL = {
			tableName: 'accounts',
			idField: '_id',
			fields: [ 
				{ name: '_id', type: :text},
				{ name: 'balance', type: :integer},
				{ name: 'balanceUsd', type: :integer},
				{ name: 'currencyCode', type: :text},
				{ name: 'type', type: :text},
				{ name: 'maskedPan', type: :text},
				{ name: 'maskedPanFull', type: :text},
				{ name: 'ethUsdRate', type: :text},
				{ name: 'userId', type: :text},
				{ name: 'timeUpdated', type: :time},
				{ name: 'timeCreated', type: :time}
			]
		}
		PAYMENT_SYSTEMS = {
			'5' => 'MC',
			'4' => 'VISA'
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
		def statements
			@statements
		end
		def parseMonobankAccount(account, userId)
			if account['maskedPan'].empty?
				maskedPan = "#{account['type'].upcase} #{DataFactory::CURRENCIES[account['currencyCode'].to_s]}"
			else
				maskedPan = account['maskedPan'].first
			end
			ps_prefix = PAYMENT_SYSTEMS[maskedPan[0]]
			@_id = "#{account['id']}_#{userId}"
			@balance = account['balance'].to_f/100
			@balanceUsd = 0
			@currencyCode = DataFactory::CURRENCIES[account['currencyCode'].to_s]
			@type = account['type'].upcase
			@maskedPanFull = maskedPan.gsub('******', '*')
			@maskedPan = "#{ps_prefix} #{maskedPan[-4..-1]}"
			@ethUsdRate = 0
			@userId = userId
		end
		def parseEtherscanAccount(account = {},last_price = {},userId)
			in_float = (BigDecimal(account['balance'])/10**18).to_f
			bal_eth = in_float.round(ROUND_ETH_AMOUNTS_TO)
			bal_usd = bal_eth * last_price['ethusd'].to_f
			bal_usd = bal_usd.round(1)
			@currencyCode = 'ETH'
			@type = 'CRYPT'
			@maskedPan = "#{account['account'][0..4]}..#{account['account'][-5..-1]}"
			@balance = bal_eth
			@balanceUsd = bal_usd
			@ethUsdRate = last_price['ethusd'].to_f
			@_id = "#{account['id']}_#{userId}"
			@maskedPanFull = "#{account['account'][0..5]}..#{account['account'][-6..-1]}"
			@userId = userId
			return true
		end
		def getStatements(options = {monoApiKey: '', ethApiKey: '', settings: []})
			@statements = Model::StatementsList.new([])
			if @type == 'CRYPT' then 
				logger.debug("#{self.class} Getting Statements from Etherscan for account: #{@_id}")
				@statements.getEtherscanStatements(@_id,options[:ethApiKey],options[:settings])
			else
				logger.debug("#{self.class} Getting Statements from Monobank for account: #{@_id}")
				@statements.getMonobankStatements(@_id,options[:monoApiKey],options[:settings])
			end
		end
	end
	class AccountsList < BaseList
		fieldSet = Account::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: Account::DATA_MODEL[:tableName], idField: Account::DATA_MODEL[:idField], fieldSet: fieldSet)
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@list = []
			options.each {|acc| 
				model = Model::Account.new(acc)
				@list.push(model)
			}
			return true
		end
		def selectById(id)
			@list.select{|i| i._id == id}.first
		end
		def parseApi(monoAccounts = [], ethAccounts = [],last_price = {},allowedAccounts = [],userId = '')
			monoAccounts.each { |acc|
				obj = Model::Account.new({})
				obj.parseMonobankAccount(acc,userId)
				@list.push(obj)
			}
			ethAccounts.each { |acc|
				obj = Model::Account.new({})
				obj.parseEtherscanAccount(acc,last_price,userId)
				@list.push(obj)
			}
			@list.sort_by! {|acc| [acc.type,acc.currencyCode]}
			logger.debug("#{self.class} Filtering retrieved accounts by: #{allowedAccounts}")
			self.filterByIdsList(allowedAccounts, userId)
		end
	end
end