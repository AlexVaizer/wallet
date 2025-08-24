module Controller
	module Api
		class GetDataModel < Base
			@@ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Get']}"
			def validateRequest
				validateHeaders
				authorize
			end
			def parsePath
				@modelName = @request.path_info.gsub("/api/datamodel/", "").gsub("/","")
				@modelName = @modelName.to_sym
			end
			def run
				@requiredPermission = "API_CUSTOMER"
				validateRequest
				getBySymbol
				@model = {@modelName => @model.fieldSet}
			end
		end
	end
end