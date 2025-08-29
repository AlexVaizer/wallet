module Controller
	module Api
		class GetProps < Base
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['GetProps']}"
			REQUIRED_PERMISSION = "API_ADMIN"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			PATH_PREFIX = 'admin/'
			def validateRequest
				validateHeaders
				authorize
			end
			def parsePath; end
			def run
				validateRequest
				s = Controller::Settings.new().getFromDb
				@model = {"content" => s.to_a}
			end
		end
		class GetProp < Base
			REQUIRED_PERMISSION = "API_ADMIN"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['GetProp']}"
			PATH_PREFIX = 'admin/'
			def validateRequest
				validateHeaders
				authorize
			end
			def run
				validateRequest
				s = Controller::Settings.new().getFromDb
				@model = s.id(@id)
			end
		end
	end
end