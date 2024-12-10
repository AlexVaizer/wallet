module Controller
	module API
		class Delete < Base
			@@ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Delete']}"
			@@SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
			def run
				self.getBySymbol
				if @model
					@model._id = @id
					self.deleteFromDb
				end 
				@response.data = {}
			end
		end
	end
end