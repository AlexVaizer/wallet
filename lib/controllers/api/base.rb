module Controller
	module Api	
		class Base
			@@ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Base']}"
			@@SUCCESS_CODE = 200
			DEFAULT_HEADERS = {
				"Content-Type" => "application/json"
			}
			include Logging
			include Api::RequestValidations
			attr_reader :response, :request, :protected, :token, :user, :modelName, :model, :id
			def initialize(request)
				@_objId = SecureRandom.hex(10)
				logger.progname = "#{self.class}::#{@_objId}"
				@request = request
				logger.info("Request: #{@request.request_method} #{@request.ip}#{@request.path_info}")
				logger.debug("Request Params: #{@request.params}")
				initVars
				@protected = true
			end
			def getBySymbol
				begin
					@model = Model.getBySymbol(@modelName)
				rescue
					@error = NotFoundError.new("")
					@error.internalCode = "01-05"
					@error.details = {value: @modelName}
					raise @error
				end
			end
			def parsePath
				path = @request.path_info.gsub(Api::PATH_PREFIX, "").split("/")
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
					@error.internalCode = "01-03"
					@error.details = {params: {userId: @id}}
					raise @error 
				end
			end
			def run!
				begin
					run
					@response = Api::SuccessResponse.new(success: true, status: @@SUCCESS_CODE, data: @model.to_h, headers: DEFAULT_HEADERS)
				rescue ValidationError, NotFoundError, AuthenticationError, AuthorizationError => e
					logger.warn(e.inspect)
					@response = ErrorResponse.new(success: false, status: e.class::HTTP_CODE, headers: DEFAULT_HEADERS, error: e.to_h)
				rescue => e
					error = InternalError.new("")
					error.internalCode = "0-0"
					error.details = e.inspect
					logger.error(e.backtrace)
					@response = Api::ErrorResponse.new(success: false, status: error.class::HTTP_CODE, headers: DEFAULT_HEADERS, error: error.to_h)
					logger.debug(@response.inspect)
					logger.error(e.backtrace)
				ensure
					logger.info("#{@response.class} Code: #{response.status}")
					return self
				end
			end
		end
	end
end