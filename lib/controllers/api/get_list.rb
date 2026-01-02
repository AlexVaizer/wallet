module Controllers
	module Api
		class GetList < Base
			DEFAULT_PAGE_SIZE = 100
			ERROR_PREFIX = Controllers::Api::CLASS_ERROR_CODES['GetList']
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			def getListBySymbol
				begin
					logger.debug(@modelName)
					@model = Model.getListBySymbol(@modelName)
					if self.class.const_defined?(:ALLOWED_MODELS) && !self.class::ALLOWED_MODELS.include?(@modelName.to_s)
						@error = Api::NotFoundError.new("Not Found")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-05"
						@error.details = {path: {model: @modelName}}
						raise @error
					end
				rescue
					@error = Api::NotFoundError.new("Not Found")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-05"
					@error.details = {path: {model: @modelName}}
					raise @error
				end
			end
			def parsePath
				@modelName = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				@modelName = @modelName.gsub(self.class::PATH_PREFIX,"")
				@modelName = @modelName.to_sym
			end
			def parseParams
				@page = @request.params['page'].to_i if @request.params['page'] 
				@page ||= 0
				@size = @request.params['size'].to_i if @request.params['size']
				@size ||= DEFAULT_PAGE_SIZE
				sort = @request.params['sort'].to_sym if @request.params['sort']
				sort ||= :timeUpdated
				order = @request.params['order'].to_i if @request.params['order']
				order ||= -1
				@sort ||= {sort => order}
			end
			def validateParams
				parseParams
			end
			def dbAction
				if self.class::FILTER_BY_USER
					@model.getFromDb(@page,@size,{},@sort,@user)
				else
					@model.getFromDb(@page,@size,{},@sort)  
				end
			end
			def run
				validateRequest
				parseParams
				getListBySymbol
				dbAction
			end
		end
	end
end