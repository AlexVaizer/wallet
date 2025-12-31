module Controllers
	module Api
		class Get < Base
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Get']}"
			SUCCESS_CODE = 200
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
		end
	end
end