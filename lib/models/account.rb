module Model
	class Account < Base
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
			@model = :account
			@statements = nil
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
			@statements = Model::StatementsList.new([],@logger)
			if @type == 'CRYPT' then 
				Model.logDebug(@logger, "Getting Statements from Etherscan for account: #{id}")
				@statements.getEtherscanStatements(@id,options[:ethApiKey])
			else
				Model.logDebug(@logger, "Getting Statements from Monobank for account: #{id}")
				@statements.getMonobankStatements(@id,options[:monoApiKey])
			end
		end
	end
		class AccountsList < BaseList
		def parseOptions(options)
			@list = []
			options.each {|acc| 
				model = Model::Account.new(acc, @logger)
				@list.push(model)
			}
			@model = :account
			return true
		end
		def selectById(id)
			return result = @list.select{|i| i.id == id}.first
		end
		def getFromDbByUser(userId)
			Model.logDebug(@logger, "Getting All Accounts List from DB")
			data = DataFactory::SQLite.get_all(@model)
			if data.nil? || data.empty?
				@errors = {code: 404,message:"Could not find #{@model} by '#{userId}' id"}
				Model.logError(@logger, @errors.to_s)
				return false
			else
				self.parseOptions(data)
				return true
			end
		end
		def parseApi(monoAccounts = [], ethAccounts = [],last_price = {},allowedAccounts = [],userId = '')
			monoAccounts.each { |acc|
				obj = Model::Account.new({}, @logger)
				obj.parseMonobankAccount(acc,userId)
				@list.push(obj)
			}
			ethAccounts.each { |acc|
				obj = Model::Account.new({}, @logger)
				obj.parseEtherscanAccount(acc,last_price,userId)
				@list.push(obj)
			}
			@list.sort_by! {|acc| [acc.type,acc.currencyCode]}
			Model.logDebug(@logger, "Filtering retrieved accounts by: #{allowedAccounts}")
			self.filterByIdsList(allowedAccounts)
		end
		def saveToDb()
			@list.each { |acc|
				Model.logDebug(@logger, "Saving Account to DB")
				DataFactory::SQLite.create(@model, acc.to_h)
			}
		end
	end
end