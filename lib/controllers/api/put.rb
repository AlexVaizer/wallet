module Controller
	module API
		class Put < Base
			@@SUCCESS_CODE = 200
			@@ERROR_PREFIX = Controller::API::CLASS_ERROR_CODES['Put']
			attr_reader :modelName, :model, :id
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def prepareSuccessResponse
				@response.data = @model.to_h
				@response.status = @@SUCCESS_CODE
			end
			def parsePayload
				begin
					@request.body.rewind
					body = @request.body.read
					logger.debug("Request body: #{body}")
					@requestPayload = JSON.parse(body)#, symbolize_names: true)
					return true
				rescue => e 
					self.handleError("Request Validation Error", "#{@@ERROR_PREFIX}-1",400)
					return false
				end
			end
			def run!
				if self.parsePayload
					return self.handleError!("ID change not permitted", "#{@@ERROR_PREFIX}-2",400) if @requestPayload['id']
					@model = Model.getBySymbol(@modelName)
					@model._id = @id
					@model.getFromDb
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-3",@model.error[:code]) if @model.error
					@model.parseOptions!(@requestPayload)
					@model.saveToDb
					return self.handleError!(@model.error[:message], "#{@@ERROR_PREFIX}-4",@model.error[:code]) if @model.error
					self.prepareSuccessResponse
				end
			end
		end
	end
end