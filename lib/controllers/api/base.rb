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
			def getModelBySymbol
				begin
					logger.debug(@modelName)
					@model = Model.getBySymbol(@modelName)
					if self.class.const_defined?(:ALLOWED_MODELS) && !self.class::ALLOWED_MODELS.include?(@modelName.to_s)
						@error = Api::NotFoundError.new("Not Found")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-05"
						@error.details = {path: {model: @modelName}}
						raise @error
					end
				rescue
					@error = Api::NotFoundError.new(@modelName)
					@error.internalCode = "#{self.class::ERROR_PREFIX}-05"
					@error.details = {path: {model: @modelName}}
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
			def filterByUser
				@model.send("#{@model.model.idField}=",@id)
				if self.class::FILTER_BY_USER
					@model.getFromDb
					if @model.error || @user.userId != @model.userId
						@error = Api::NotFoundError.new("Not Found")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
						@error.details = {path: {id: @id}}
						raise @error 
					end
				end
				return true
			end
			def dbAction
				@model.getFromDb
			end
			def run
				validateRequest
				getModelBySymbol
				filterByUser
				dbAction
			end
			def run!
				begin
					run
					@response = Api::SuccessResponse.new(success: true, status: self.class::SUCCESS_CODE, data: @model.to_h, headers: DEFAULT_HEADERS)
					@response.data = {} if !self.class::HAS_RESPONSE_BODY
					@response.headers["requiredPermission"] = @requiredPermission
				rescue Api::ValidationError, Api::NotFoundError, Api::AuthenticationError, Api::AuthorizationError => e
					logger.warn(e.inspect)
					@response = Api::ErrorResponse.new(success: false, status: e.class::HTTP_CODE, headers: DEFAULT_HEADERS, error: e.to_h)
					#logger.debug(e.backtrace)
				rescue => e
					error = Api::InternalError.new("Internal Error")
					logger.error(e.inspect)
					error.internalCode = "#{self.class::ERROR_PREFIX}-0"
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