require File.expand_path('./lib/logging.rb')
require File.expand_path('./lib/datafactory.rb')
require File.expand_path('./lib/model.rb')
require File.expand_path('./lib/token.rb')
require File.expand_path('./lib/controllers.rb')

module Wallet
	module Api 
		module Admin
			class Post < Controllers::Api::Post ;end
			class Get < Controllers::Api::Get ;end
			class GetList < Controllers::Api::GetList ;end
			class Patch < Controllers::Api::Patch ;end
			class Put < Controllers::Api::Put ;end
			class Delete < Controllers::Api::Delete ;end
			class GetProps < Controllers::Api::GetProps ;end
		end
		module Customer
			# Need to add validations for posting/getting not own IDs
			#class Post < Controllers::Api::Post ;end 
			#class Patch < Controllers::Api::Patch ;end
			#class Put < Controllers::Api::Put ;end
			#class Delete < Controllers::Api::Delete ;end
			#class Get < Controllers::Api::Get ;end
			
			#List should be filtered by own only when getFromDb'ing
			#class GetList < Controllers::Api::GetList ;end
			#also should define 

			class Schema < Controllers::Api::GetProps ;end
		end
	end
	def contructClassFromCapitalizedStrings(array = [])
		raise ArgumentError.new("Cannot Construct object from empty array") if array.empty
		str = array.join("::")
		return cls = Object.const_get(str)
	end
	MockSinReq = Struct.new(:path_info, :request_method, keyword_init: true)
	def constructor(sinatraRequest = MockSinReq.new())
		prefix = 'Wallet' # TODO replace to proper function
		arr = sinatraRequest.path_info.split("/")
		methodClassName = sinatraRequest.request_method.capitalize
		mod = arr[0].downcase
		subMod = arr[1].downcase
		modelName = arr[2].downcase
		id = arr[3]
		case mod
		when 'api'
			modClassName = "Api"
			case subMod
			when 'admin'
				subModClassName = "Admin"
			when 'customer'
				subModClassName = "Customer"
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
		#construct: pass sinatraRequest, model and id(if any) to controllers as args
		c = contructClassFromCapitalizedStrings([prefix,modClassName,subModClassName]).new(sinatraRequest, optsHash)
		#return Controllers
	end
end