module Controller
	module API
		class Delete < Base
			@@ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Delete']}"
			@@SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				logger.debug(@request.path_info)
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def run!
				begin
					self.getBySymbol
					if @model
						@model._id = @id
						self.deleteFromDb
					end 
					@response.data = {}
				rescue => e 
					@response.data = {}
					self.handleError!("Internal Error: #{e.message}", "#{@@ERROR_PREFIX}-0",500)
				end

			end
		end
	end
end