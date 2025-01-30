module Controller
	module Api
		class Patch < Base
			@@ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Patch']
			def run
				validateRequest
				self.getBySymbol
				@model._id = @id
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "01-07"
					@error.details = {params: {userId: @id}}
					raise @error
				end
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions!(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "01-08"
					raise error
				end
				@model._id = @id
				@model.saveToDb
			end
		end
	end
end