module Controllers
	module Api
		class Patch < Base
			ERROR_PREFIX = Controllers::Api::CLASS_ERROR_CODES['Patch']
			HAS_REQUEST_BODY = true
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			def run
				validateRequest
				self.getBySymbol
				@model._id = @id
				@model.getFromDb
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-07"
					@error.details = {params: {userId: @id}}
					raise @error
				end
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions!(@requestPayload)
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