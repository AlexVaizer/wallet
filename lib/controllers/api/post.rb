module Controller
	module Api
		class Post < Base
			ERROR_PREFIX = Controller::Api::CLASS_ERROR_CODES['Post']
			def parsePath
				path = @request.path_info.gsub(Api::PATH_PREFIX, "").split("/")
				@modelName = path[0].to_sym
				#@id = path[1].gsub("/","") #comment
			end
			def run
				validateRequest
				self.getBySymbol
				logger.debug("Parsing Payload: #{@requestPayload}")
				@model.parseOptions(@requestPayload)
				if @model.error
					error = ValidationError.new("")
					error.details = @model.error
					error.internalCode = "#{self.class::ERROR_PREFIX}-06"
					raise error
				end
				@model.insertToDb
			end
		end
	end
end