module Controller
	module Api
		class Patch < Base
			@@ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Patch']
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def run
				if self.parsePayload
					@model = Model.getBySymbol(@modelName)
					@model._id = @id
					@model.getFromDb
					return handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code]) if @model.error
					@model.parseOptions(@requestPayload)
					@model.saveToDb
					return handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-4",@model.error[:code]) if @model.error
					prepareSuccessResponse
				end
			end
		end
	end
end