module Controller
	module Api
		class Post < Base
			@@ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Post']
			def run
				validateRequest
				self.getBySymbol
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "01-06"
					raise error
				end
				@model.insertToDb
			end
		end
	end
end