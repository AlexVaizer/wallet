module Controller
	module API
		class Response
			attr_accessor :data, :status, :success, :errorCode, :errorMessage, :headers
			def initialize(options = {})
				@data = options[:data] || ''
				@status = options[:status] || 500
				@success = options[:success] || false
				@errorCode = nil
				@errorMessage = nil
				@cookie = nil
				@headers = nil
			end
			def to_json
				response = {
					:success => @success,
					:status => @status,
					:errorCode => @errorCode,
					:errorMessage => @errorMessage,
					:data => @data,
					:headers => @headers
				}.to_json
			end
		end
		PATH_PREFIX = '/api/'
		class Base
			DEFAULT_HEADERS = {
				"Content-Type" => "application/json"
			}
			include Logging
			attr_reader :response, :request, :protected, :token, :user
			def initialize(request)
				@_objId = SecureRandom.hex(10)
				logger.progname = "#{self.class}::#{@_objId}"
				@request = request
				@response = Response.new()
				@response.headers = DEFAULT_HEADERS
				logger.info("Request: #{@request.ip}/#{@request.request_method} #{@request.path_info}")
				self.initVars
				self.run! if self.checkAuth
				logger.info("ResponseCode: #{@response.status}, Body: #{@response.to_json}")
			end
			def initVars
				@token = nil
				@protected = true	
			end
			def checkAuth
				if @protected
					logger.debug("Accessing protected Controller. Parsing Token: #{@request.cookies['token'][0..6] if @request.cookies['token']}..#{@request.cookies['token'][-6..-1] if @request.cookies['token']}")
					begin
						self.parseToken
					rescue
						logger.debug("Token parsing failed, redirecting to Login")
						# TODO @response.erb = :login
						return false
					end
				else
					logger.debug("Accessing unprotected controller, token parsing skipped")
				end
				return true
			end
			def handleError!(message = "Unknown Error",errorCode = '0-0-0', httpCode = 500)
				logger.error(message)
				@response.status = httpCode
				@response.errorMessage = message
				@response.data = {}
				@response.errorCode = errorCode
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
end