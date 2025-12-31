module Controllers
	module Api
		class MonoSync < Base
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Sync']}"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			attr_reader :clientInfo, :accountsList, :jarsList
			def parsePath
				@modelName = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				@modelName = @modelName.gsub(self.class::PATH_PREFIX,"")
				@modelName = @modelName.to_sym
			end
			def getMonobankClientInfo
				clientInfo = DataFactory::Mono.get_client_info(@user,@settings)
				monoAccounts = clientInfo['accounts']
				jars = clientInfo['jars']
				clientInfo.delete('accounts')
				clientInfo.delete('jars')
				@clientInfo = Model::ClientInfo.new()
				logger.debug("Parsing Client Info from Monobank/Mock")
				@clientInfo.parseMonobankClientInfo(clientInfo,@user._id)
				logger.debug("Getting Client Info and Accounts from Etherscan")
				ethClientInfo = DataFactory::ETH.get_client_info(@user, @settings)
				@accountsList = Model::AccountsList.new()
				logger.debug("Parsing Accounts from Monobank and Etherscan")
				@accountsList.parseApi(monoAccounts, ethClientInfo[:balances], ethClientInfo[:last_price],@user.allowedAccountIds,@user._id)
				@jarsList = Model::JarsList.new()
				logger.debug("Parsing Jars")
				@jarsList.parseMonobankJars(jars,@user.allowedJarIds,@user._id)
			end
			def saveAllToDb
				@clientInfo.saveToDb
				#self.handleError("Client info was not saved","#{ERROR_PREFIX}-01-03",500) if @clientInfo.error
				@accountsList.saveToDb
				#self.handleError("Accounts were not saved","#{ERROR_PREFIX}-01-04",500) if @accountsList.error
				@jarsList.saveToDb
				#self.handleError("Jars was not saved","#{ERROR_PREFIX}-01-05",500) if @accountsList.error
			end
			def getClientInfo
				#self.handleError("User was not defined","#{ERROR_PREFIX}-01-02",500) if !@user
				@clientInfo = Model::ClientInfo.new({_id: @user._id}).getFromDb
				#api_timeout = @settings.get("client.updateTimeoutSeconds") || API_UPDATE_TIMEOUT
				#isValid = @clientInfo.timeUpdated > (Time.now - api_timeout)
				#logger.debug("ClientInfo validity: #{isValid}")
				logger.info("Getting Client Info and Accounts from Monobank/Mock")
				self.getMonobankClientInfo
				self.saveAllToDb
				logger.debug("Getting Client Accounts and Jars from DB")
				@accountsList = Model::AccountsList.new().getFromDb(0,15,{userId: @user._id})
				@jarsList = Model::JarsList.new().getFromDb(0,15,{userId: @user._id})
			end
			def run
				validateRequest
				self.getClientInfo
				@model = {
					clientInfo: @clientInfo.to_h,
					accounts: @accountsList.to_a,
					jars: @jarsList.to_a
				}
			end
		end
	end
end