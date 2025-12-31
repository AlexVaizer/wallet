module Controllers
	module Api
		class Schema < Base
			ERROR_PREFIX = "#{Controllers::Api::CLASS_ERROR_CODES['Schema']}"
			HAS_REQUEST_BODY = false
			HAS_RESPONSE_BODY = true
			SUCCESS_CODE = 200
			def validateRequest
				validateHeaders
				authorize
			end
			def parsePath
				@modelName = @request.path_info.gsub(Api::API_PATH_PREFIX, "")
				@modelName = @modelName.gsub(self.class::PATH_PREFIX,"")
			end
			def run
				validateRequest
				begin
					client = Mongo::Client.new(Model::MONGO_STRING, database: Model::MONGO_DATABASE)
					coll = client['props-fe']
					if @modelName == 'schema' || @modelName == 'schema/'
						req = {}
						data = coll.find(req).to_a
						@model = {"content" => data}
					else
						@id = @modelName.split("/").last
						req = {"_id" => "schema.#{@id}"}
						puts(req)
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