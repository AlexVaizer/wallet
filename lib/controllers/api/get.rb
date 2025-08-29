module Controller
	module Api
		class Get < Base
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Get']}"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			PATH_PREFIX = 'admin/'
			def validateRequest
				validateHeaders
				authorize
			end
		end
	end
end