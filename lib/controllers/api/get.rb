module Controller
	module API
		class Get < Base
			ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Get']}"
			SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				@token = nil
				@protected = true
				@user = nil
				@modelName = @request.path_info.gsub(API::PATH_PREFIX, "").split("/")[0]
				@modelName = @modelName.to_sym
				@id = @request.path_info.gsub(API::PATH_PREFIX, "").split("/")[1]
				logger.debug("model name = #{@modelName}, id = #{@id}")
			end
			def prepareSuccessResponse
				@response.data = @model.to_h
				@response.status = SUCCESS_CODE
			end
			def run!
				@model = Model.getBySymbol(@modelName)
				@model.id = @id
				@model.getFromDb
				if @model.error
					self.handleError!(@model.error[:message], "#{ERROR_PREFIX}-01",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
		end
	end
end