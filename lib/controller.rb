module Controller
	require 'securerandom'
	include Logging
	Setting = Struct.new(:_id, :value, keyword_init: true)
	class Settings < Array 
		include Logging
		SETTINGS_TABLE_NAME = 'props-be'
		ENV_VARS_LIST = ["WALLET_MONGO_STRING","WALLET_DB_NAME"]
		def readEnvVars
			ENV_VARS_LIST.each do |v|
				s = {_id: "env.#{v}", value: ENV[v]}
				self.push(Setting.new(s))
			end
		end
		def to_a
			return self.map { |e| e.to_h }
		end
		def id(id)
			s = self.find {|e| e._id == id}
			raise ArgumentError.new("Could not find setting by id: #{id}") if s.nil?
			return s
		end
		def get(id) 
			s = self.find {|e| e._id == id}
			return nil if s.nil?
			return s.value
		end
		def getFromDb
			#self.clear
			readEnvVars
			client = Mongo::Client.new(self.get("env.WALLET_MONGO_STRING"), database: self.get("env.WALLET_DB_NAME"))
			coll = client[SETTINGS_TABLE_NAME]
			req = {} 	
			data = coll.find({}).to_a
			data.each do |e|
				self.push(Setting.new(e))
			end
			return self
		end
	end

	class Response
		attr_accessor :erb, :code, :success, :errorCode, :errorMessage, :cookie
		def initialize(options = {})
			@erb = options[:erb] || :errors
			@code = options[:code] || 500
			@success = options[:success] || false
			@errorCode = nil
			@errorMessage = nil
			@cookie = nil
		end
		def to_h
			response = {
				:success => @success,
				:code => @code,
				:errorCode => @errorCode,
				:errorMessage => @errorMessage,
				:erb => @erb,
				:cookie => @cookie
			}
		end
	end
	require File.expand_path(File.join(__dir__,"/controllers/erb.rb"))
	require File.expand_path(File.join(__dir__,"/controllers/api.rb"))
end
