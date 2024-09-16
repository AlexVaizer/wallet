module Model
	class Account < Base
		DATA_MODEL = {
			tableName: 'accounts',
			idField: 'id',
			fields: [ 
				{ name: 'id', type: 'TEXT'},
				{ name: 'balance', type: 'NUMERIC'},
				{ name: 'balanceUsd', type: 'NUMERIC'},
				{ name: 'currencyCode', type: 'TEXT'},
				{ name: 'type', type: 'TEXT'},
				{ name: 'maskedPan', type: 'TEXT'},
				{ name: 'maskedPanFull', type: 'TEXT'},
				{ name: 'ethUsdRate', type: 'NUMERIC'},
				{ name: 'userId', type: 'TEXT'},
				{ name: 'timeUpdated', type: 'TEXT'},
			]
		}
		PAYMENT_SYSTEMS = {
			'5' => 'MC',
			'4' => 'VISA'
		}
		PRINTABLE_ATTRS = [:id, :balance, :balanceUsd, :currencyCode, :type, :maskedPan, :maskedPanFull, :ethUsdRate, :userId, :statements]
		attr_accessor(*PRINTABLE_ATTRS) 
		def parseOptions(options)
			@id = options[:id] || ''
			@balance = options[:balance] || 0
			@balanceUsd = options[:balanceUsd] || 0
			@currencyCode = options[:currencyCode] || ''
			@type = options[:type] || ''
			@maskedPan = options[:maskedPan] || ''
			@maskedPanFull = options[:maskedPanFull] || ''
			@ethUsdRate = options[:ethUsdRate] || 0
			@userId = options[:userId] || ''
			@error = nil
			@statements = nil
			@model = DATA_MODEL
			return true
		end
		def to_h
			return result = {
				:id => @id, 
				:balance => @balance, 
				:balanceUsd => @balanceUsd, 
				:currencyCode => @currencyCode, 
				:type => @type, 
				:maskedPan => @maskedPan, 
				:maskedPanFull => @maskedPanFull, 
				:ethUsdRate => @ethUsdRate, 
				:userId => @userId,
			}
		end
		def parseMonobankAccount(account, userId)
			if account['maskedPan'].empty?
				maskedPan = "#{account['type'].upcase} #{DataFactory::CURRENCIES[account['currencyCode'].to_s]}"
			else
				maskedPan = account['maskedPan'].first
			end
			ps_prefix = PAYMENT_SYSTEMS[maskedPan[0]]
			@id = account['id']
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
			bal_eth = in_float.round(Model::ROUND_ETH_AMOUNTS_TO)
			bal_usd = bal_eth * last_price['ethusd'].to_f
			bal_usd = bal_usd.round(1)
			@currencyCode = 'ETH'
			@type = 'CRYPT'
			@maskedPan = "#{account['account'][0..4]}..#{account['account'][-5..-1]}"
			@balance = bal_eth
			@balanceUsd = bal_usd
			@ethUsdRate = last_price['ethusd'].to_f
			@id = account['account']
			@maskedPanFull = "#{account['account'][0..5]}..#{account['account'][-6..-1]}"
			@userId = userId
			return true
		end
		def getStatements(options = {monoApiKey: '', ethApiKey: ''})
			@statements = Model::StatementsList.new([])
			if @type == 'CRYPT' then 
				logger.debug("Getting Statements from Etherscan for account: #{id}")
				@statements.getEtherscanStatements(@id,options[:ethApiKey])
			else
				logger.debug("Getting Statements from Monobank for account: #{id}")
				@statements.getMonobankStatements(@id,options[:monoApiKey])
			end
		end
	end
		class AccountsList < BaseList
		def parseOptions(options)
			@list = []
			options.each {|acc| 
				model = Model::Account.new(acc)
				@list.push(model)
			}
			@model = Account::DATA_MODEL
			return true
		end
		def selectById(id)
			return result = @list.select{|i| i.id == id}.first
		end
		def getFromDbByUser(userId)
			logger.debug("Getting All Accounts List from DB")
			data = DataFactory::SQLite.get_all(@model)
			if data.nil? || data.empty?
				@errors = {code: 404,message:"Could not find #{@model[:tableName]} by '#{userId}' id"}
				logger.error(@errors.to_s)
			else
				self.parseOptions(data)
			end
			return self
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
			logger.debug("Filtering retrieved accounts by: #{allowedAccounts}")
			self.filterByIdsList(allowedAccounts)
		end
		def saveToDb()
			@list.each { |acc|
				logger.debug("Saving Account #{acc.id} to DB")
				DataFactory::SQLite.create(@model, acc.to_h)
			}
		end
	end
end