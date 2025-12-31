module Controllers
	module Api
		class Put < Base
			ERROR_PREFIX = Controllers::Api::CLASS_ERROR_CODES['Put']
			SUCCESS_CODE = 200
			HAS_REQUEST_BODY = true
			HAS_RESPONSE_BODY = true
			# PATH_PREFIX = 'admin/'
			def dbAction
				@model._id = @id
				@model.getFromDb
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-07"
					@error.details = {params: {userId: @id}}
					raise @error
				end
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-08"
					raise error
				end
				@model.saveToDb
			end
		end
	end
end