module Controller
	module Api
		class Put < Base
			ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Put']
			def run
				validateRequest
				self.getBySymbol
				@model._id = @id
				@model.getFromDb
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-01-07"
					@error.details = {params: {userId: @id}}
					raise @error
				end
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-01-08"
					raise error
				end
				@model._id = @id
				@model.saveToDb
			end
		end
	end
end