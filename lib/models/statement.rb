module Model
	class Statement < Base
		ATTRS = [:id, :balance, :time,:comissionRate,:txId,:txIdShort,:txFee,:etherscanUrl,:description,:amount]
		ROUND_ETH_AMOUNTS_TO = 6
		attr_accessor(*ATTRS) 
		def parseOptions(options)
			@id = options[:id] || ''
			@balance = options[:balance] || 0
			@amount = options[:amount] || 0
			@time = Time.parse(options[:time]) if options[:time]
			@comissionRate = options[:comissionRate] || ''
			@txIdShort = options[:txIdShort] || ''
			@txFee = options[:txFee] || ''
			@etherscanUrl = options[:etherscanUrl] || ''
			@description = options[:description] || ''
			@error = nil
			@model = nil
			return true
		end
		def to_h
			return result = {
				:id => @id, 
				:amount => @amount,
				:balance => @balance, 
				:time => @time, 
				:comissionRate => @comissionRate, 
				:txIdShort => @txIdShort, 
				:txFee => @txFee, 
				:etherscanUrl => @etherscanUrl,
				:description => @description
			}
		end
		def parseMonobankStatement(stat)
			@id = stat['id']
			@time = Time.at(stat['time']).strftime(Model::TIME_FORMAT)
			@amount = stat['amount'].to_f/100
			@description = stat['description']
			@balance = stat['balance'].to_f/100
		end
		def parseEtherscanStatement(stat,address)
			fee = ((BigDecimal(stat['gasPrice']) * BigDecimal(stat['gasUsed'])) / 10**18).to_f.round(Model::ROUND_ETH_AMOUNTS_TO)
			amount = (BigDecimal(stat['value']) / 10**18).to_f.round(Model::ROUND_ETH_AMOUNTS_TO)
			if stat['from'].downcase == address.downcase then 
				symbol =  '-'
			else 
				symbol = '+'
			end
			@time = Time.at(stat['timeStamp'].to_i).strftime(Model::TIME_FORMAT)
			@amount = symbol + amount.to_s
			@id = stat['hash']
			@txIdShort = "#{stat['hash'][0..6]}..#{stat['hash'][-6..-1]}"
			@etherscanUrl = "#{DataFactory::ETH::ETH_TX_URL}#{stat['hash']}"
			@txFee = fee
		end
	end
	class StatementsList < BaseList
		def parseOptions(options)
			@list = []
			options.each {|opt| 
				model = Model::Statement.new(opt)
				@list.push(model)
			}
			#@model = nil
			return true
		end
		def parseMonobankStatements(options)
			@list = []
			options.each {|opt| 
				model = Model::Statement.new()
				model.parseMonobankStatement(opt)
				@list.push(model)
			}
			#@model = nil
			return true
		end
		def parseEtherscanStatements(options,address)
			@list = []
			options.each {|opt| 
				model = Model::Statement.new()
				model.parseEtherscanStatement(opt,address)
				@list.push(model)
			}
			#@model = nil
			return true
		end
		def getMonobankStatements(accountId,monoApiKey)
			logger.debug("Getting Statements from Monobank by AccountId: #{accountId}")
			self.parseMonobankStatements(DataFactory::Mono.get_statements(accountId,monoApiKey))
			return true
		end
		def getEtherscanStatements(accountId,ethApiKey)
			logger.debug("Getting Statements from Etherscan by AccountId: #{accountId}")
			self.parseEtherscanStatements(DataFactory::ETH.get_statements(accountId,ethApiKey),accountId)
			return true
		end
	end
end