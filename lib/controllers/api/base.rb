module Controllers
	module Api	
		class Base
			DEFAULT_HEADERS = {
				"Content-Type" => "application/json"
			}
			include Logging
			include Api::RequestValidations
			attr_reader :response, :request, :protected, :token, :user, :modelName, :model, :id, :settings, :requiredPermission
			def initialize(request)
				@_objId = SecureRandom.hex(10)
				@settings = Controllers::Settings.new().getFromDb
				logger.progname = "#{self.class}::#{@_objId}"
				logger.level = "debug" if @settings.get("sinatra.debug_mode")
				@request = request
				logger.info("Request: #{@request.request_method} #{@request.ip}#{@request.path_info}")
				#logger.debug("Request Params: #{@request.inspect}")	
				initVars
				@protected = true
				@requiredPermission = self.class::REQUIRED_PERMISSION
			end
			def getBySymbol
				begin
					logger.debug(@modelName)
					@model = Model.getBySymbol(@modelName)
				rescue
					@error = NotFoundError.new("@modelName")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-05"
					@error.details = {value: @modelName}
					raise @error
				end
			end
			def parsePath
				path = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				path = path.gsub(self.class::PATH_PREFIX,"").split("/")
				@modelName = path[0].to_sym
				@id = path[1]
			end
			def initVars
				self.parsePath
				@token = nil
			end
			def run
				validateRequest
				self.getBySymbol
				@model._id = @id
				@model.getFromDb
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
					@error.details = {params: {id: @id}}
					raise @error 
				end
			end
			def run!
				begin
					run
					@response = Api::SuccessResponse.new(success: true, status: self.class::SUCCESS_CODE, data: @model.to_h, headers: DEFAULT_HEADERS)
					@response.headers["requiredPermission"] = @requiredPermission
				rescue ValidationError, NotFoundError, AuthenticationError, AuthorizationError => e
					logger.warn(e.inspect)
					@response = ErrorResponse.new(success: false, status: e.class::HTTP_CODE, headers: DEFAULT_HEADERS, error: e.to_h)
					#logger.debug(e.backtrace)
				rescue => e
					error = InternalError.new("Internal Error")
					logger.error(e.inspect)
					error.internalCode = "#{self.class::ERROR_PREFIX}-0-0"
					error.details = e.inspect
					logger.error(e.inspect)
					logger.error(e.backtrace)
					@response = Api::ErrorResponse.new(success: false, status: error.class::HTTP_CODE, headers: DEFAULT_HEADERS, error: error.to_h)
					logger.error(e.backtrace)
				ensure
					logger.debug(@response.inspect)
					logger.info("#{@response.class} Code: #{@response.status}")
					return self
				end
			end
		end
	end
end