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
			FILTER_BY_USER = false
			def parsePath
				@modelName = nil
				@id = nil
			end
			def run
				@error = Controllers::Api::NotFoundError.new("Not Found")
				@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
				@error.details = {path: @request.path_info}
				raise @error 
			end
		end
		def self.constructor(rawClass, sinatraRequest)
			parsedClass = {
				prefix: 'Wallet',
				module: 'Api',
				subModule: nil,
				methodName: rawClass[:methodClassName]
			}
			parsedClass[:methodName] = "GetList" if rawClass[:id].nil? && rawClass[:methodClassName] == "Get"
			case rawClass[:subModule]
			when "admin"
				parsedClass[:subModule] = "Admin"
				parsedClass[:methodName] = "GetProp" if rawClass[:modelName] == "props"
				parsedClass[:methodName] = "GetProps" if rawClass[:modelName] == "props" && rawClass[:id].nil?
			when "customer"
				parsedClass[:subModule] = "Customer"
				parsedClass[:methodName] = "Schema" if rawClass[:modelName] == "schema"
				parsedClass[:methodName] = "MonoSync" if rawClass[:modelName] == "mono-sync"
			else
				return c = Wallet::Api::UnknownController.new(sinatraRequest).run!
			end
			return Wallet.contructClassFromCapitalizedStrings(parsedClass.values).new(sinatraRequest)
		end
		module Admin
			def self.renderControllers(array = [], c = nil)
				array.each do |class_name|
					parent_class = Controllers::Api.const_get(class_name)
					klass = Class.new(parent_class) do
						c.map{|h| self.const_set(h[:key],h[:value])}
					end if !c.nil?
					const_set(class_name, klass)
				end if !array.empty?
			end
			DEFAULT_CONSTANTS = [
				{ key: :REQUIRED_PERMISSION, value: 'API_ADMIN' },
				{ key: :PATH_PREFIX, value: 'admin/' },
				{ key: :FILTER_BY_USER, value: false }
			]
  			self.renderControllers([:Post,  :Get, :GetList, :Patch, :Put, :Delete, :GetProps, :GetProp],DEFAULT_CONSTANTS)
		end
		module Customer
			def self.renderControllers(array = [], c = nil)
				array.each do |class_name|
					parent_class = Controllers::Api.const_get(class_name)
					klass = Class.new(parent_class) do
						c.map{|h| self.const_set(h[:key],h[:value])}
					end if !c.nil?
					const_set(class_name, klass)
				end if !array.empty?
			end
			CUSTOM_CONSTANTS = [
				{ key: :REQUIRED_PERMISSION, value: 'API_CUSTOMER' },
				{ key: :PATH_PREFIX, value: 'customer/' },
				{ key: :FILTER_BY_USER, value: true }
			]
			DEFAULT_CONSTANTS = CUSTOM_CONSTANTS + [{ key: :ALLOWED_MODELS, value: ['jar','account', 'clientInfo']}]
			self.renderControllers([:Get, :GetList, :Post, :Patch, :Put, :Delete],DEFAULT_CONSTANTS)
			self.renderControllers([:Schema, :MonoSync],CUSTOM_CONSTANTS)
		end
	end
	def self.contructClassFromCapitalizedStrings(*array)
		raise ArgumentError.new("Cannot Construct object from empty array or elements") if array.empty? || array.include?(nil)
		str = array.join("::")
		return cls = Object.const_get(str)
	end
	def self.constructor(sinatraRequest = nil)
		prefix = 'Wallet'
		arr = sinatraRequest.path_info.split("/")
		rawClass = {
			module: arr[1].downcase,
			subModule: arr[2].downcase,
			methodClassName: sinatraRequest.request_method.capitalize,
			modelName: arr[3],
			id: arr[4]
		}
		case rawClass[:module]
		when 'api'
			Wallet::Api.constructor(rawClass, sinatraRequest)
		else
			return c = Wallet::Api::UnknownController.new(sinatraRequest).run!
		end
	end
end