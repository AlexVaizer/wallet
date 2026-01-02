module Controllers
	module Api
		class Delete < Base
			SUCCESS_CODE = 200
			HAS_REQUEST_BODY = false 
			HAS_RESPONSE_BODY = false 
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Delete']}"
			def dbAction
				@model.getFromDb
				if @model.error
					@error = Api::NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
					@error.details = {path: {id: @id}}
					raise @error 
				end
				@model.deleteFromDb
			end
		end
	end
end