module Controller
	module Api
		class Get < Base
			@@ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Get']}"
			def validateRequest
				validateHeaders
				authorize
			end
		end
	end
end