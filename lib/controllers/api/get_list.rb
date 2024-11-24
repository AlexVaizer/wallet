module Controller
	module API
		class GetList < Base
			SUCCESS_CODE = 200
			ERROR_PREFIX = "#{Controller::API::CLASS_ERROR_CODES['GetList']}"
			attr_reader :modelName, :model, :id
			def initVars
				logger.debug(@request.path_info)
				@token = nil
				@protected = true
				@user = nil
				@modelName = @request.path_info.gsub(API::PATH_PREFIX, "")
				@modelName = @modelName.to_sym
				logger.debug("model name = #{@modelName}")
			end
			def prepareSuccessResponse
				@response.data = @model.to_a
				@response.status = SUCCESS_CODE
			end
			def run!
				@model = Model.getListBySymbol(@modelName)
				@model.getFromDbByUser(@user.id)
				if @model.error
					self.handleError!(@model.error[:message], "#{ERROR_PREFIX}-1",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
		end
	end
end