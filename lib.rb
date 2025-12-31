require File.expand_path('./lib/logging.rb')
require File.expand_path('./lib/datafactory.rb')
require File.expand_path('./lib/model.rb')
require File.expand_path('./lib/token.rb')
require File.expand_path('./lib/controllers.rb')

module Wallet
	module Api 
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
			# Need to add validations for posting/getting not own IDs
			#class Post < Controllers::Api::Post ;end 
			#class Patch < Controllers::Api::Patch ;end
			#class Put < Controllers::Api::Put ;end
			#class Delete < Controllers::Api::Delete ;end
			#class Get < Controllers::Api::Get ;end
			
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
			

			# class Schema < Controllers::Api::GetProps 
			# 	REQUIRED_PERMISSION = 'API_CUSTOMER'
			# 	PATH_PREFIX = 'customer/'
			# end
		end
	end
	def self.contructClassFromCapitalizedStrings(array = [])
		raise ArgumentError.new("Cannot Construct object from empty array") if array.empty?
		str = array.join("::")
		cls = Object.const_get(str)
		puts cls
		return cls
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
		puts "Module: #{mod}, Submodule: #{subMod}, Model Name: #{modelName}"
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
				#methodClassName = "Schema" if modelName == "schema"
			else
				subModClassName = nil
			end
		# when 'erb'
		# 	modClassName = "Erb"
		else
			modClassName = nil
		end
		
		if id.nil? && methodClassName == "Get"
			methodClassName = "GetList"
		end

		#check if one of modules/submodules is not nil
		raise StandardError.new("unknown module") if modClassName.nil? 
		raise StandardError.new("unknown submodule") if subModClassName.nil?
		#construct: pass sinatraRequest, model and id(if any) to controllers as args
		return c = Wallet.contructClassFromCapitalizedStrings([prefix,modClassName,subModClassName,methodClassName]).new(sinatraRequest)
		#return Controllers
	end
end

# r = Wallet::MockSinReq.new(path_info: '/api/admin/user/vzr', request_method: 'POST', ip: '127.0.0.1')
# w = Wallet.constructor(r)
# puts w.class