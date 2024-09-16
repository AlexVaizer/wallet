module Controller
	require 'securerandom'
	class Response
		include Logging
		attr_accessor :erb, :code, :success, :errorCode, :errorMessage, :cookie
		def initialize(options = {})
			@erb = options[:erb] || :errors
			@code = options[:code] || 500
			@success = options[:success] || false
			@errorCode = nil
			@errorMessage = nil
			@cookie = nil
		end
		def to_h
			response = {
				:success => @success,
				:code => @code,
				:errorCode => @errorCode,
				:errorMessage => @errorMessage,
				:erb => @erb,
				:cookie => @cookie
			}
		end
	end
	class Base
		include Logging
		attr_reader :response, :request, :protected, :token
		def initialize(request)
			@_objId = SecureRandom.hex(10)
			logger.progname = "#{self.class}::#{@_objId}"
			@request = request
			@response = Response.new()
			logger.info("Request: #{@request.ip}/#{@request.request_method} #{@request.path_info}")
			self.initVars
			self.run! if self.checkAuth
			
			logger.info("ResponseCode: #{@response.code}, ERB: #{@response.erb}")
		end
		def initVars
			@token = nil
			@protected = false
		end
		def checkAuth
			if @protected
				logger.debug("Accessing protected Controller. Parsing Token: #{@request.cookies['token'][0..6] if @request.cookies['token']}..#{@request.cookies['token'][-6..-1] if @request.cookies['token']}")
				begin
					self.parseToken
				rescue
					logger.debug("Token parsing failed, redirecting to Login")
					@response.erb = :login
					return false
				end
			else
				logger.debug("Accessing unprotected controller, token parsing skipped")
			end
			return true
		end
		def handleError!(message = "Unknown Error",errorCode = '0-0-0', httpCode = 500)
			logger.error(message)
			@response.code = httpCode
			@response.errorMessage = message
		end
		def handleError(message = "Unknown Error",errorCode = '0-0-0', httpCode = 500)
			full_message = "Error #{httpCode} occured. Code=#{errorCode}, Message=#{message}"
			begin
				raise StandardError.new(full_message)
			rescue => e 
				self.handleError!(full_message , errorCode, httpCode)
				logger.debug("Traceback: #{e.backtrace.take(5)}")
				raise e
			end
		end

		def parseToken
			reqToken = @request.cookies['token']
			@token = Token.new(reqToken)
			if !@token.isValid
				self.handleError("Token Parsing failed", '0-0-1', 401)
			end
			@user = Model::User.new({id:@token.payload["userId"]}).getFromDb
			if @user.error
				self.handleError("User #{@token.payload["userId"]}} does not exist", "0-0-2", 401)
			end
		end
	end
end