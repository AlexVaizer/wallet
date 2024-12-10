module Controller
	module API
		class Patch < Base
			@@SUCCESS_CODE = 200
			@@ERROR_PREFIX = Controller::API::CLASS_ERROR_CODES['Patch']
			attr_reader :modelName, :model, :id
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def parsePayload
				begin
					@request.body.rewind
					body = @request.body.read
					@requestPayload = JSON.parse(body)#, symbolize_names: true)
					return true
				rescue => e 
					handleError("Request Validation Error", "#{@@ERROR_PREFIX}-1",400)
					return false
				end
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