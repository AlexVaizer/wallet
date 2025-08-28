module Controller
	module Api
		class GetDataModel < Base
			ERROR_PREFIX = "#{Controller::Api::CLASS_ERROR_CODES['Get']}"
			def validateRequest
				validateHeaders
				authorize
			end
			def parsePath
				@modelName = @request.path_info.gsub("/api/customer/info/schema", "")
				#@modelName = @modelName.to_sym
			end
			def run
				@requiredPermission = "API_CUSTOMER"
				validateRequest
				client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
				coll = client['props-fe']
				if @modelName.empty?
					req = {"_id" => /schema./} 	
					data = coll.find(req).to_a
					@model = {"content" => data}
				else
					@modelName = @modelName.gsub("/","")
					req = {"_id" => "schema.#{@modelName}"}
					logger.debug(req)
					data = coll.find(req).first
					@model = data
				end
			end
		end
	end
end