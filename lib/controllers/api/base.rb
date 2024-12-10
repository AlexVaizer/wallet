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
			@@ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Base']}"
			@@SUCCESS_CODE = "200"
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
				logger.info("Request: #{@request.request_method} #{@request.ip}#{@request.path_info}")
				self.initVars
				self.run! if self.checkAuth
				logger.info("Response Code: #{@response.status}. Success: #{@response.status}")
			end
			def parsePath
				path = @request.path_info.gsub(API::PATH_PREFIX, "").split("/")
				@modelName = path[0].to_sym
				@id = path[1]
			end
			def initVars
				self.parsePath
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
						return false
					end
				else
					logger.debug("Accessing unprotected controller, token parsing skipped")
				end
				return true
			end
			def handleError!(message = "Unknown Error",errorCode = '0-0-0', httpCode = 500)
				full_message = "Error #{httpCode} occured. Code=#{errorCode}, Message=#{message}"
				logger.error full_message
				begin
					raise StandardError.new(full_message)
				rescue => e 
					#logger.debug(self.inspect)
					logger.debug("Traceback: #{e.backtrace.take(8)}")
					raise e
				end
				@response.status = httpCode
				@response.errorMessage = message
				@response.errorCode = errorCode
			end
			def handleError(message = "Unknown Error",errorCode = '0-0-0', httpCode = 500)
				full_message = "Error #{httpCode} occured. Code=#{errorCode}, Message=#{message}"
				begin
					raise StandardError.new(full_message)
				rescue => e 
					self.handleError!(full_message , errorCode, httpCode)
					#logger.debug(self.inspect)
					logger.debug("Traceback: #{e.backtrace.take(8)}")
					raise e
				end
			end

			def parseToken
				reqToken = @request.cookies['token']
				@token = Token.new(reqToken)
				if !@token.isValid
					self.handleError("Token Parsing failed", "#{@@ERROR_PREFIX}-5", 401)
				end
				@user = Model::User.new({_id:@token.payload["userId"]}).getFromDb
				if @user.error
					logger.debug(@user.error)
					self.handleError("User #{@token.payload["userId"]}} does not exist", "#{@@ERROR_PREFIX}-2", 401)
				end
			end
			def getBySymbol
				begin
					@model = Model.getBySymbol(@modelName)
				rescue
					self.handleError!("Unknown Model", "#{@@ERROR_PREFIX}-1",404)
					return nil
				end
			end
			def getListBySymbol
				begin
					@model = Model.getListBySymbol(@modelName)
				rescue
					self.handleError!("Unknown Model", "#{@@ERROR_PREFIX}-2",404)
					return nil
				end
			end
			def getFromDb
				@model.getFromDb
				if @model.error
					self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
			def deleteFromDb
				@model.deleteFromDb
				if @model.error
					self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
			def prepareSuccessResponse
				@response.data = @model.to_h
				@response.status = @@SUCCESS_CODE
				@response.success = true
			end
			def getListFromDbByUser
				@model.getFromDbByUser(@user._id)
				if @model.error
					self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-4",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
			def run
				self.getBySymbol
				if @model
					@model._id = @id
					self.getFromDb
				end 
			end
			def run!
				begin 
					run
				rescue => e 
					@response.data = {}
					self.handleError!("Internal Error: #{e.message}", "#{@@ERROR_PREFIX}-0",500)
				end
			end
		end
	end
end