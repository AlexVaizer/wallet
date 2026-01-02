module Controllers
	module Erb
		class Login < Base
			SUCCESS_CODE = 302
			SUCCESS_ERB = :index
			CONTROLLER_ERROR_PREFIX = '02'
			def initVars
				@protected = false
				@userId = nil
				@password = nil
				@user = nil
				@response = Response.new()
				@cookie = nil
			end
			def run!
				@userId = @request.params["id"]
				@password = @request.params["password"]
				logger.debug("Params: #{@request.params}, userId: #{@userId.inspect}, password: #{@password}")
				self.handleError!("User was not defined","#{CONTROLLER_ERROR_PREFIX}-01-01",400) if !@userId
				self.handleError!("Password was not defined","#{CONTROLLER_ERROR_PREFIX}-01-02",400) if !@userId
				@user = Model::User.new({userId: @userId}).getFromDb
				logger.debug(@user.inspect)
				if @user.parseCryptedPass == @password
					@token = Token.new(nil,@settings)
					@token.create(userId: @user.userId, permissions: @user.permissions)
					@response.code = SUCCESS_CODE
					@response.erb = SUCCESS_ERB
					@response.success = true
				else
					self.handleError!("Invalid Password","#{CONTROLLER_ERROR_PREFIX}-01-03",400)
				end
			end
		end
	end
end