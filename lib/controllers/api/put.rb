module Controller
	module Api
		class Put < Base
			@@ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Put']
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def run
				if self.parsePayload
					return self.handleError!("ID change not permitted", "#{@@ERROR_PREFIX}-2",400) if @requestPayload['_id'] != @id
					@model = Model.getBySymbol(@modelName)
					@model._id = @id
					@model.getFromDb
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code]) if @model.error
					@model.parseOptions(@requestPayload)
					@model.saveToDb
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-4",@model.error[:code]) if @model.error
					self.prepareSuccessResponse
				end
			end
		end
	end
end