module Controller
	module Api
		class Delete < Base
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Delete']}"
			def validateRequest
				validateHeaders
				authorize
			end
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
				@model.deleteFromDb
				#@response.data = {}
			end
		end
	end
end