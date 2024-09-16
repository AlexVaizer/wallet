module Controller
	class GetIndex < Base
		SUCCESS_CODE = 200
		SUCCESS_ERB = :index
		CONTROLLER_ERROR_PREFIX = '01'
		attr_reader :user, :clientInfo, :accountsList, :jarsList, :requestedAccountId, :requestedAccount
		def initVars
			@token = nil
			@protected = true
			@user = nil
			@clientInfo = nil
			@accountsList = nil
			@jarsList = nil
			@requestedAccountId = nil
			@requestedAccount = nil
		end
		def getRequestedAccount
			if @requestedAccountId = @request.params['id']
				logger.debug("Requested Account: #{@requestedAccountId.to_s}")
				@requestedAccount = @accountsList.selectById(@requestedAccountId)
				self.handleError("Account #{@requestedAccountId} was not found","#{CONTROLLER_ERROR_PREFIX}-01-01",404) if @requestedAccount.nil?
				begin
					logger.info("Requesting Account: '#{requestedAccountId}' from API")
					@requestedAccount.getStatements({monoApiKey:@user.monoApiKey, ethApiKey:@user.ethApiKey})
				rescue => e
					self.handleError(e.message,"#{CONTROLLER_ERROR_PREFIX}-01-07", 500)
				end
			end
		end
		def getMonobankClientInfo
			logger.info("Getting Client Info and Accounts from Monobank/Mock")
			clientInfo = DataFactory::Mono.get_client_info(@user)
			monoAccounts = clientInfo['accounts']
			jars = clientInfo['jars']
			clientInfo.delete('accounts')
			clientInfo.delete('jars')
			@clientInfo = Model::ClientInfo.new()
			logger.debug("Parsing Client Info from Monobank/Mock")
			@clientInfo.parseMonobankClientInfo(clientInfo,@user.id)
			logger.debug("Getting Client Info and Accounts from Etherscan")
			ethClientInfo = DataFactory::ETH.get_client_info(@user)
			@accountsList = Model::AccountsList.new()
			logger.debug("Parsing Accounts from Monobank and Etherscan")
			@accountsList.parseApi(monoAccounts, ethClientInfo[:balances], ethClientInfo[:last_price],@user.allowedAccountIds,@user.id)
			@jarsList = Model::JarsList.new()
			logger.debug("Parsing Jars")
			@jarsList.parseMonobankJars(jars,@user.allowedJarIds)
		end
		def saveAllToDb
			@clientInfo.saveToDb
			self.handleError("Client info was not saved","#{CONTROLLER_ERROR_PREFIX}-01-03",500) if @clientInfo.error
			@accountsList.saveToDb
			self.handleError("Accounts were not saved","#{CONTROLLER_ERROR_PREFIX}-01-04",500) if @accountsList.error
			@jarsList.saveToDb
			self.handleError("Jars was not saved","#{CONTROLLER_ERROR_PREFIX}-01-05",500) if @accountsList.error
		end
		def getClientInfo
			self.handleError("User was not defined","#{CONTROLLER_ERROR_PREFIX}-01-02",500) if !@user
			@clientInfo = Model::ClientInfo.new({id: @user.id}).getFromDb
			logger.debug("ClientInfo validity: #{@clientInfo.isValid}")
			if !@clientInfo.isValid
				self.getMonobankClientInfo
				self.saveAllToDb
			else
				logger.debug("Getting Client Accounts and Jars from DB")
				@accountsList = Model::AccountsList.new().getFromDbByUser(@user.id)
				@jarsList = Model::JarsList.new().getFromDbByUser()
			end
		end
		def run!
			begin
				self.getClientInfo
				self.getRequestedAccount
				@response.code = SUCCESS_CODE
				@response.erb = SUCCESS_ERB
				@response.success = true
			rescue
				return false
			end
		end
	end
end