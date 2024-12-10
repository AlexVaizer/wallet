module Controller
	module API
		class Post < Put
			@@ERROR_PREFIX = Controller::API::CLASS_ERROR_CODES['Put']
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def run
				if self.parsePayload
					@model = Model.getBySymbol(@modelName)
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code]) if @model.error
					@model.parseOptions(@requestPayload)
					@model.insertToDb
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-4",@model.error[:code]) if @model.error
					self.prepareSuccessResponse
				end
			end
		end
	end
end