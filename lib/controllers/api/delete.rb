module Controller
	module API
		class Delete < Base
			ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['Delete']}"
			SUCCESS_CODE = 200
			attr_reader :modelName, :model, :id
			def initVars
				logger.debug(@request.path_info)
				@token = nil
				@protected = true
				@user = nil
				@modelName = @request.path_info.gsub(API::PATH_PREFIX, "").split("/")[0]
				@modelName = @modelName.to_sym
				@id = @request.path_info.gsub(API::PATH_PREFIX, "").split("/")[1]
				logger.debug("model name = #{@modelName}, id = #{@id}")
			end
			def prepareSuccessResponse
				@response.data = {}
				@response.status = SUCCESS_CODE
			end
			def run!
				@model = Model.getBySymbol(@modelName)
				@model.id = @id
				@model.getFromDb()
				if @model.error
					self.handleError!(@model.error[:message], "#{ERROR_PREFIX}-1",@model.error[:code])
				else
					@model.deleteFromDb()
					self.prepareSuccessResponse
				end
			end
		end
	end
end