module Controller
	module Api
		class GetList < Base
			DEFAULT_PAGE_SIZE = 100
			ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['GetList']
			def getBySymbol
				begin
					@model = Model.getListBySymbol(@modelName)
				rescue
					@error = NotFoundError.new("Unknown Model")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-01-04"
					@error.details = {value: @modelName}
					raise @error
				end
			end
			def parsePath
				@modelName = @request.path_info.gsub(Api::PATH_PREFIX, "")
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
			def validateRequest
				validateHeaders
				authorize
			end
			def run
				validateRequest
				parseParams
				getBySymbol
				@model.getFromDb(@page,@size,{},@sort)
			end
		end
	end
end