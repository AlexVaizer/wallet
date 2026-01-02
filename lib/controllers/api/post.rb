module Controllers
	module Api
		class Post < Base
			SUCCESS_CODE = 201
			ERROR_PREFIX = Controllers::Api::CLASS_ERROR_CODES['Post']
			HAS_REQUEST_BODY = true
			HAS_RESPONSE_BODY = true
			def parsePath
				path = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				path = path.gsub(self.class::PATH_PREFIX,"")
				@modelName = path.to_sym
			end
			def filterByUser
				@model.userId = @user.userId if self.class::FILTER_BY_USER
				return true
			end
			def dbAction
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("Invalid Request")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-06"
					raise error
				end
				filterByUser
				@model.insertToDb
			end
		end
	end
end