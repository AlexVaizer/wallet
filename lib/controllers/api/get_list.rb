module Controller
	module API
		class GetList < Base
			@@ERROR_PREFIX = Controller::API::CLASS_ERROR_CODES['GetList']
			@@SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				logger.debug(@request.path_info)
				self.parsePath
				@token = nil
				@protected = true
				@user = nil
			end
			def getBySymbol
				begin
					@model = Model.getListBySymbol(@modelName)
				rescue
					self.handleError!("Unknown Model", "#{@@ERROR_PREFIX}-1",404)
					return nil
				end
			end
			def parsePath
				@modelName = @request.path_info.gsub(API::PATH_PREFIX, "")
				@modelName = @modelName.to_sym
			end
			def prepareSuccessResponse
				@response.data = @model.to_a
				@response.status = @@SUCCESS_CODE
				@response.success = true
			end
			def run
				self.getBySymbol
				self.getFromDb if @model
			end
			def run!
				begin
					self.run
				rescue => e 
					@response.data = {}
					self.handleError!("Internal Error", "#{@@ERROR_PREFIX}-0",500)
				end
			end
		end
	end
end