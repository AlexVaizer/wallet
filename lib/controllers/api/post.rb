module Controller
	module Api
		class Post < Base
			SUCCESS_CODE = 201
			ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Post']
			REQUIRED_PERMISSION = "API_ADMIN"
			HAS_REQUEST_BODY = true
			HAS_RESPONSE_BODY = true
			PATH_PREFIX = 'admin/'
			def parsePath
				path = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				path = path.gsub(PATH_PREFIX,"")
				@modelName = path.to_sym
			end
			def run
				validateRequest
				self.getBySymbol
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-06"
					raise error
				end
				@model.insertToDb
			end
		end
	end
end