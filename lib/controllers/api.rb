module Controller
	module Api
		MODULE_ERROR_CODE = '01'
		CLASS_ERROR_CODES = {
			'Base' => "#{MODULE_ERROR_CODE}-00",
			'Get' => "#{MODULE_ERROR_CODE}-01",
			'GetList' => "#{MODULE_ERROR_CODE}-02",
			'Delete' => "#{MODULE_ERROR_CODE}-03",
			'Patch' => "#{MODULE_ERROR_CODE}-04",
			'Put' => "#{MODULE_ERROR_CODE}-05",
			'Post' => "#{MODULE_ERROR_CODE}-06"
		}
		ERROR_CODES = {

		}
		PATH_PREFIX = '/api/admin/'
		ErrorResponse = Struct.new(:success, :status, :error, :headers, keyword_init: true)
		SuccessResponse = Struct.new(:success, :status, :data, :headers, keyword_init: true)
		class GenericError < Exception
			attr_accessor :internalCode, :details
			def inspect
				"#{self.class}. httpCode: #{self.class::HTTP_CODE}, internalCode: #{internalCode}"
			end
			def to_h
				{
					message: self.class::MESSAGE,
					httpCode: self.class::HTTP_CODE,
					internalCode: internalCode,
					details: details
				}
			end
		end
		class InternalError < GenericError
			HTTP_CODE = 500
			MESSAGE = "Internal Server Error"
			def inspect
				"#{self.class}: #{self.class::MESSAGE}. httpCode: #{self.class::HTTP_CODE}, internalCode: #{internalCode}"
			end
		end
		class ValidationError < GenericError 
			HTTP_CODE = 400
			MESSAGE = "Request Validation Error"
		end
		class AuthenticationError < GenericError 
			HTTP_CODE = 401
			MESSAGE = "Authentication failed"
		end
		class AuthorizationError < GenericError 
			MESSAGE = "Authorization failed"
			HTTP_CODE = 403
		end
		class NotFoundError < GenericError 
			MESSAGE = "Not Found"
			HTTP_CODE = 404
		end
		require File.expand_path(File.join(__dir__,"/api/modules/request_validations.rb"))
		require File.expand_path(File.join(__dir__,"/api/base.rb"))
		require File.expand_path(File.join(__dir__,"/api/get.rb"))
		require File.expand_path(File.join(__dir__,"/api/get_list.rb"))
		require File.expand_path(File.join(__dir__,"/api/get_data_model.rb"))
		require File.expand_path(File.join(__dir__,"/api/delete.rb"))
		require File.expand_path(File.join(__dir__,"/api/patch.rb"))
		require File.expand_path(File.join(__dir__,"/api/put.rb"))
		require File.expand_path(File.join(__dir__,"/api/post.rb"))
	end
end
