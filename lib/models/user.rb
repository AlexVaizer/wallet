module Model
	class User < Base
		require 'bcrypt'
		ATTRS = [:id, :password, :monoApiKey, :allowedAccountIds, :ethAddresses, :ethApiKey,:clientInfo,:accountsList,:requestedAccountId, :requestedAccount, :jarsList]
		attr_accessor *ATTRS
		def parseOptions(options)
			@id = options[:id]
			@password = options[:password] || ''
			@monoApiKey = options[:monoApiKey] || ''
			@allowedAccountIds = options[:allowedAccountIds].split(',') if options[:allowedAccountIds]
			@allowedJarIds = options[:allowedJarIds].split(',') if options[:allowedJarIds]
			@ethAddresses = options[:ethAddresses].split(',') if options[:ethAddresses]
			@ethApiKey = options[:ethApiKey] || ''
			@requestedAccountId = options[:requestedAccountId] || nil
			@error = nil
			@model = :user
			@accountsList = nil
			@clientInfo = nil
			@jarsList = nil
			@requestedAccount = nil
			return true
		end
		def parseCryptedPass()
			return BCrypt::Password.new(@password)
		end
		def to_h
			return result = {
				:id => @id,
				:password => @password,
				:monoApiKey => @monoApiKey,
				:allowedAccountIds => @allowedAccountIds.join(','),
				:ethAddresses => @ethAddresses.join(','),
				:ethApiKey => @ethApiKey,
				:clientInfo => @clientInfo.to_h,
				:accountsList => @accountsList.to_a,
				:jarsList => @jarsList.to_a
			}
		end
		def getAllInfoFromDb
			self.getFromDb
			@clientInfo = Model::ClientInfo.new({id: @id},@logger)
			@clientInfo.getFromDb
			@accountsList = Model::AccountsList.new([],@logger)
			@accountsList.getFromDbByUser(@id)
			@jarsList = Model::JarsList.new([],@logger)
			@jarsList.getFromDbByUser()
			return true
		end
		def saveAllInfoToDb
			Model.logDebug(@logger,"Saving All ClientInfo to DB")
			@clientInfo.saveToDb if @clientInfo
			@accountsList.saveToDb if !@accountsList.empty?
			@jarsList.saveToDb if !@jarsList.empty?
			return true
		end
		def getAndParseClientInfoFromApi
			Model.logDebug(@logger, "Getting Client Info and Accounts from Monobank/Mock")
			clientInfo = DataFactory::Mono.get_client_info(self)
			monoAccounts = clientInfo['accounts']
			jars = clientInfo['jars']
			clientInfo.delete('accounts')
			clientInfo.delete('jars')
			@clientInfo = Model::ClientInfo.new({},@logger)
			Model.logDebug(@logger, "Parsing Client Info from Monobank/Mock")
			@clientInfo.parseMonobankClientInfo(clientInfo,@id)
			Model.logDebug(@logger, "Getting Client Info and Accounts from Etherscan")
			ethClientInfo = DataFactory::ETH.get_client_info(self)
			@accountsList = Model::AccountsList.new([],@logger)
			Model.logDebug(@logger, "Parsing Accounts from Monobank and Etherscan")
			@accountsList.parseApi(monoAccounts, ethClientInfo[:balances], ethClientInfo[:last_price],@allowedAccountIds,@id)
			@jarsList = Model::JarsList.new([],@logger)
			Model.logDebug(@logger, "Parsing Jars")
			@jarsList.parseMonobankJars(jars,@allowedJarIds)
			self.saveAllInfoToDb
			return true
		end
		def getStatements
			if @requestedAccountId
				@requestedAccount = @accountsList.selectById(@requestedAccountId)
				raise StandardError.new("Could not find account id #{@requestedAccountId}") if @requestedAccount.nil?
				@requestedAccount.getStatements({monoApiKey:@monoApiKey, ethApiKey:@ethApiKey}) 
				return false
			else
				return false
			end
		end
		def getAllInfoFromMonobank
			self.getAndParseClientInfoFromApi
			self.getStatements
			return true
		end
	end
end