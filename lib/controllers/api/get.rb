module Controller
	module API
		class Get < Controller::API::Base
			SUCCESS_CODE = 200
			CONTROLLER_ERROR_PREFIX = '03'
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
					self.handleError!(@model.error[:message], "#{CONTROLLER_ERROR_PREFIX}-01-01",@model.error[:code])
				else
					self.prepareSuccessResponse
				end
			end
		end
	end
end