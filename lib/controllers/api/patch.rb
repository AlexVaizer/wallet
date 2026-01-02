module Controllers
	module Api
		class Patch < Base
			ERROR_PREFIX = Controllers::Api::CLASS_ERROR_CODES['Patch']
			HAS_REQUEST_BODY = true
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			def dbAction
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.getFromDb
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-08"
					raise error
				end
				@model.parseOptions!(@requestPayload)
				@model.userId = @user.userId if self.class::FILTER_BY_USER
				@model.saveToDb
			end
		end
	end
end