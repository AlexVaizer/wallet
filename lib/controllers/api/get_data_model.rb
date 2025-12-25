module Controllers
	module Api
		class Schema < Base
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Schema']}"
			PATH_PREFIX = "customer/schema"
			REQUIRED_PERMISSION = "API_CUSTOMER"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			def validateRequest
				validateHeaders
				authorize
			end
			def parsePath
				@modelName = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				@modelName = @modelName.gsub(self.class::PATH_PREFIX,"")
				logger.debug("model name: #{@modelName}")
			end
			def run
				validateRequest
				begin
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
				ensure
					client.close if client
				end
			end
		end
	end
end