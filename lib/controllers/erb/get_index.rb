module Controllers
	module Erb
		class GetIndex < Base
			SUCCESS_CODE = 200
			SUCCESS_ERB = :index
			CONTROLLER_ERROR_PREFIX = '01'
			API_UPDATE_TIMEOUT = 10
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
				#logger.debug("params ID: #{@request}")
				if @requestedAccountId = @request.params['id']
					@requestedAccount = @accountsList.selectById(@requestedAccountId)
					self.handleError("Account #{@requestedAccountId} was not found","#{CONTROLLER_ERROR_PREFIX}-01-01",404) if @requestedAccount.nil?
					begin
						@requestedAccount.getStatements({monoApiKey:@user.monoApiKey, ethApiKey:@user.ethApiKey, settings:@settings})
					rescue => e
						self.handleError(e.message,"#{CONTROLLER_ERROR_PREFIX}-01-07", 500)
					end
				end
			end
			def getMonobankClientInfo
				logger.info("Getting Client Info and Accounts from Monobank/Mock")
				clientInfo = DataFactory::Mono.get_client_info(@user,$walletSettings)
				monoAccounts = clientInfo['accounts']
				jars = clientInfo['jars']
				clientInfo.delete('accounts')
				clientInfo.delete('jars')
				@clientInfo = Model::ClientInfo.new()
				logger.debug("Parsing Client Info from Monobank/Mock")
				@clientInfo.parseMonobankClientInfo(clientInfo,@user._id)
				logger.debug("Getting Client Info and Accounts from Etherscan")
				ethClientInfo = DataFactory::ETH.get_client_info(@user, $walletSettings)
				@accountsList = Model::AccountsList.new()
				logger.debug("Parsing Accounts from Monobank and Etherscan")
				@accountsList.parseApi(monoAccounts, ethClientInfo[:balances], ethClientInfo[:last_price],@user.allowedAccountIds,@user._id)
				@jarsList = Model::JarsList.new()
				logger.debug("Parsing Jars")
				@jarsList.parseMonobankJars(jars,@user.allowedJarIds,@user._id)
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
				@clientInfo = Model::ClientInfo.new({_id: @user._id}).getFromDb
				api_timeout = @settings.get("client.apiUpdateTimeoutSec") || API_UPDATE_TIMEOUT
				isValid = @clientInfo.timeUpdated > (Time.now - api_timeout)
				logger.debug("ClientInfo validity: #{isValid}")
				if !isValid
					self.getMonobankClientInfo
					self.saveAllToDb
				end
				logger.debug("Getting Client Accounts and Jars from DB")
				@accountsList = Model::AccountsList.new().getFromDb(0,15,{userId: @user._id})
				@jarsList = Model::JarsList.new().getFromDb(0,15,{userId: @user._id})
			end
			def run!
				begin
					self.getClientInfo
					self.getRequestedAccount
					@response.code = SUCCESS_CODE
					@response.erb = SUCCESS_ERB
					@response.success = true
				rescue => e
				 	logger.debug("Error: #{e.inspect}. Backtrace: #{e.backtrace.take(10)}")
				 	raise e
				end
			end
		end
	end
end