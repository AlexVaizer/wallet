module Controller
	module API
		class Get < Base
			@@ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Get']}"
			@@SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				@token = nil
				@protected = true
				@user = nil
				self.parsePath
			end
		end
	end
end