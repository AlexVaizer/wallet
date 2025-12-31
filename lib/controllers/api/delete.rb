module Controllers
	module Api
		class Delete < Base
			SUCCESS_CODE = 200
			HAS_REQUEST_BODY = false # TODO
			HAS_RESPONSE_BODY = false # TODO
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Delete']}"
			def dbAction
				@model._id = @id
				@model.getFromDb
				if @model.error
					@error = NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-07"
					@error.details = {params: {userId: @id}}
					raise @error
				end
				@model.deleteFromDb
			end
		end
	end
end