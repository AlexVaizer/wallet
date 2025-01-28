module Controller
	module Api
		class Delete < Base
			@@ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Delete']}"
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