require File.expand_path('./lib/logging.rb')
require File.expand_path('./lib/datafactory.rb')
require File.expand_path('./lib/model.rb')
require File.expand_path('./lib/token.rb')
require File.expand_path('./lib/controllers.rb')

module Wallet
	module Api 
		class UnknownController < Controllers::Api::Base
			REQUIRED_PERMISSION = 'API_CUSTOMER' 
			ERROR_PREFIX = '0'
			def parsePath
				@modelName = nil
				@id = nil
			end
			def run
				#validateRequest
				@error = Controllers::Api::NotFoundError.new("Not Found")
				@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
				@error.details = {path: @request.path_info}
				raise @error 
			end
		end
		module Admin
			# Initiate all controllers 
  			CONTROLLERS = [:Post, :Get, :GetList, :Patch, :Put, :Delete, :GetProps, :GetProp]
			CONTROLLERS.each do |class_name|
				parent_class = Controllers::Api.const_get(class_name)
				klass = Class.new(parent_class) do
					const_set(:REQUIRED_PERMISSION, 'API_ADMIN')
					const_set(:PATH_PREFIX, 'admin/')
				end
				const_set(class_name, klass)
			end
		end
		module Customer
			# Need to add validations for posting/deleting not own IDs
			#class Post < Controllers::Api::Post ;end 
			#class Patch < Controllers::Api::Patch ;end
			#class Put < Controllers::Api::Put ;end
			#class Delete < Controllers::Api::Delete ;end
			class Get < Controllers::Api::Get 
				REQUIRED_PERMISSION = 'API_CUSTOMER'
				PATH_PREFIX = 'customer/'
				def run
					super
					if @user._id != @model.userId
						@error = Controllers::Api::NotFoundError.new("Not Found")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
						@error.details = {params: {id: @id}}
						raise @error
					end
				end
			end
			
			class GetList < Controllers::Api::GetList
				REQUIRED_PERMISSION = 'API_CUSTOMER'
				PATH_PREFIX = 'customer/'
				def run
					if !['jar','account', 'clientInfo'].include?(@modelName.to_s)
						@error = Controllers::Api::NotFoundError.new("Not Found")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
						@error.details = {params: {model: @modelName}}
						raise @error
					end
					validateRequest
					parseParams
					getBySymbol
					@model.getFromDb(@page,@size,{},@sort,@user)
				end
			end
			

			class Schema < Controllers::Api::Schema 
				REQUIRED_PERMISSION = 'API_CUSTOMER'
				PATH_PREFIX = 'customer/'
			end
			class MonoSync < Controllers::Api::MonoSync 
				REQUIRED_PERMISSION = 'API_CUSTOMER'
				PATH_PREFIX = 'customer/'
			end
		end
	end
	def self.contructClassFromCapitalizedStrings(array = [])
		raise ArgumentError.new("Cannot Construct object from empty array or elements") if array.empty? || array.include?(nil)
		str = array.join("::")
		# needs to be refactored as raises error when module unknown
		return cls = Object.const_get(str)
	end
	MockSinReq = Struct.new(:path_info, :request_method, :ip, keyword_init: true)
	def self.constructor(sinatraRequest = MockSinReq.new())
		prefix = 'Wallet'
		arr = sinatraRequest.path_info.split("/")
		arr.shift # remove impact of / on start of path
		methodClassName = sinatraRequest.request_method.capitalize
		mod = arr[0].downcase
		subMod = arr[1].downcase
		modelName = arr[2]
		id = arr[3]
		#puts "Module: #{mod}, Submodule: #{subMod}, Model Name: #{modelName}"
		case mod
		when 'api'
			modClassName = "Api"
			case subMod
			when 'admin'
				subModClassName = "Admin"
				methodClassName = "GetProp" if modelName == "props"
				methodClassName = "GetProps" if modelName == "props" && id.nil?
			when 'customer'
				subModClassName = "Customer"
				methodClassName = "Schema" if modelName == "schema"
				methodClassName = "MonoSync" if modelName == "mono-sync"
			else
				return c = Wallet::Api::UnknownController.new(sinatraRequest).run!
			end
		else
			modClassName = nil
			raise StandardError.new("unknown module") if modClassName.nil?  #won't hit it for now as sinatra proxies only /api/* to Wallet
		end
		methodClassName = "GetList" if id.nil? && methodClassName == "Get"
		return Wallet.contructClassFromCapitalizedStrings([prefix,modClassName,subModClassName,methodClassName]).new(sinatraRequest)
	end
end

# r = Wallet::MockSinReq.new(path_info: '/api/admin/user/vzr', request_method: 'POST', ip: '127.0.0.1')
# w = Wallet.constructor(r)
# puts w.class