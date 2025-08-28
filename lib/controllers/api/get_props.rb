module Controller
	module Api
		class GetProps < Base
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['GetProps']}"
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
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['GetProp']}"
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