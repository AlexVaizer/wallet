module Controllers
	module Api
		class GetProps < Base
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['GetProps']}"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			def parsePath; end
			def run
				validateRequest
				s = Controllers::Settings.new().getFromDb
				@model = {"content" => s.to_a}
			end
		end
		class GetProp < Base
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['GetProp']}"
			SUCCESS_CODE = 200
			def run
				validateRequest
				s = Controllers::Settings.new().getFromDb
				@model = s.id(@id)
			end
		end
	end
end