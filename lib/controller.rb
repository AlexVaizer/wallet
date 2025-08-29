module Controller
	require 'securerandom'
	include Logging
	Setting = Struct.new(:_id, :value, keyword_init: true)
	class Settings < Array 
		require 'erb'
		require 'openssl'
		require 'json'
		ALLOWED_ENVS = [:development, :test, :production]
		SERVICE_TEMPLATE_PATH = './lib/templates/wallet_service.erb'
		NGINX_TEMPLATE_PATH = './lib/templates/nginx.erb'
		SERVICES_DESTINATION_PATH = './services/'
		CURRENT_FOLDER = `pwd`.chomp
		SETTINGS_TABLE_NAME = 'props-be'
		ENV_VARS_LIST = ["WALLET_MONGO_STRING","WALLET_DB_NAME", "RACK_ENV"]
		def self.validate_env(env)
			if !ALLOWED_ENVS.include?(env) then 
				raise ArgumentError.new("Environment should be: #{ALLOWED_ENVS.to_s}")
			else 
				return env
			end
		end

		def self.setup_service(env_values)
			puts "Setting up service for Sinatra"
			puts "Saving file to #{SERVICE_DESTINATION_PATH}"
			@env_values = env_values
			Dir.mkdir(SERVICES_DESTINATION_PATH)
			service_settings = ERB.new(File.read(File.expand_path(SERVICE_TEMPLATE_PATH)))
			out_file = File.new(File.expand_path("#{SERVICES_DESTINATION_PATH}/wallet.service"), "w")
			out_file.puts(service_settings.result(binding))
			service_file = out_file.absolute_path
			out_file.close
			puts "File saved to #{service_file}."
			puts "If you want to run sinatra on startup, please run 'sudo systemctl enable wallet'"
			service_settings = ERB.new(File.read(File.expand_path(NGINX_TEMPLATE_PATH)))
			out_file = File.new("#{SERVICES_DESTINATION_PATH}/#{@env_values['domain']}", "w")
			out_file.puts(service_settings.result(binding))
			nginx_file = out_file.absolute_path
			out_file.close
			puts "File saved to #{nginx_file}"
			puts "You need to enable created nginx server: 'sudo ln -s /etc/nginx/sites-available/#{@env_values['domain']} /etc/nginx/sites-enabled  && sudo service nginx restart'"
		end

		def self.save_pid
			pid = Process.pid
			pidfile_path = File.join(CURRENT_FOLDER,"wallet.pid")
			pidfile = File.new(pidfile_path, "w")
			pidfile.puts(pid)
			pidfile.close
		end
		def readEnvVars(array = nil) 
			ENV_VARS_LIST.each do |v|
				if !(ENV[v].nil? || ENV[v].empty?)
					s = {_id: "env.#{v}", value: ENV[v]}
					self.push(Setting.new(s))
				end
			end
		end
		def readVars(hash) 
			hash.each do |k,v|
				s = {_id: "env.#{k}", value: v}
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
