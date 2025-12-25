module Controllers
Setting = Struct.new(:_id, :value, keyword_init: true)
	class Settings < Array 
		require 'erb'
		require 'openssl'
		require 'json'
		ALLOWED_ENVS = [:development, :test, :production]
		SERVICE_TEMPLATE_PATH = './lib/templates/wallet_service.erb'
		NGINX_TEMPLATE_PATH = './lib/templates/nginx.erb'
		SERVICES_DESTINATION_PATH = File.expand_path('~/services_for_sinatra')
		CURRENT_FOLDER = `pwd`.chomp
		SETTINGS_TABLE_NAME = 'props-be'
		ENV_VARS_LIST = ["WALLET_MONGO_STRING","WALLET_DB_NAME"]
		def self.validate_env(env)
			if !ALLOWED_ENVS.include?(env) then 
				raise ArgumentError.new("Environment should be: #{ALLOWED_ENVS.to_s}")
			else 
				return env
			end
		end

		def self.setup_service(env_values)
			puts "================================================="
			puts "====== Generating and saving files for Sinatra and nginx site to #{SERVICES_DESTINATION_PATH}"
			@env_values = env_values
			Dir.mkdir(File.expand_path(SERVICES_DESTINATION_PATH)) if !Dir.exist?(File.expand_path(SERVICES_DESTINATION_PATH))
			service_file = "#{SERVICES_DESTINATION_PATH}/wallet.service"
			service_settings = ERB.new(File.read(File.expand_path(SERVICE_TEMPLATE_PATH)))
			out_file = File.new(File.expand_path("#{service_file}"), "w")
			out_file.puts(service_settings.result(binding))
			out_file.close
			service_settings = ERB.new(File.read(File.expand_path(NGINX_TEMPLATE_PATH)))
			nginx_file = File.join("#{SERVICES_DESTINATION_PATH}",@env_values['domain'])
			out_file = File.new(nginx_file, "w")
			out_file.puts(service_settings.result(binding))
			out_file.close
			puts "====== Saving the configs Finished! :ultra-fast-parrot:"
			puts "====== Systemd service file: #{service_file}"
			puts "====== Nginx site config: #{nginx_file}"
			puts "================================================="
			puts "=== (PASSED) Phase2: Service Files Generation"
			puts "================================================="
			puts "=== Phase3: Services enablement"
			puts "=== THIS PHASE MUST BE RUN MANUALLY"
			puts "================================================="
			puts "====== Uncomment wanted sections in nginx config:"
			puts "nano #{nginx_file}"
			puts "====== Copy and link files to system directories:"
			puts "sudo cp #{service_file} /etc/systemd/system/"
			puts "sudo cp #{nginx_file} /etc/nginx/sites-available"
			puts "sudo ln -s /etc/nginx/sites-available/#{@env_values['domain']} /etc/nginx/sites-enabled"
			puts "================================================="
			puts "====== In order to start services immediately:"
			puts "sudo systemctl daemon-reload"
			puts "sudo systemctl restart nginx"
			puts "sudo systemctl start wallet"
			puts "====== To enable autorun on server startup run:"
			puts "sudo systemctl enable nginx"
			puts "sudo systemctl enable wallet"
			puts "================================================="
			puts "=== After that Set Up is Completed!!! You should check if everything works :sherlock:"
			puts "================================================="
		end

		def save_pid
			pid = Process.pid
			pidfile_path = File.join(CURRENT_FOLDER,"wallet.pid")
			pidfile = File.new(pidfile_path, "w")
			pidfile.puts(pid)
			pidfile.close
		end
		def readEnvVars() 
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

		def id(string)
			s = self.find {|e| e._id == string}
			raise ArgumentError.new("Could not find setting by id: #{string}") if s.nil?
			return s
		end
		def get(string) 
			s = self.find {|e| e._id == string}
			return nil if s.nil?
			return s.value
		end
		def set(string1, string2) 
			s = {_id: string1, value: string2}
			obj = Setting.new(s)
			self.delete_if { |e| e._id == string1} 
			self.push(obj)
		end
		def getFromDb
			#self.clear
			readEnvVars
			begin
				client = Mongo::Client.new(self.get("env.WALLET_MONGO_STRING"), database: self.get("env.WALLET_DB_NAME"))
				coll = client[SETTINGS_TABLE_NAME]
				req = {} 	
				data = coll.find({}).to_a
				data.map { |e| self.push(Setting.new(e)) } 
				return self
			ensure
				client.close # if client
			end
		end
	end
end