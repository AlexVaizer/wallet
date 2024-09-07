module ServerSettings
	require 'erb'
	require 'openssl'
	require 'json'
	ALLOWED_ENVS = [:development, :test, :production]
	IP = '127.0.0.1'
	PORT = 8080
	SERVICE_TEMPLATE_PATH = './lib/templates/wallet_service.erb'
	NGINX_TEMPLATE_PATH = './lib/templates/nginx.erb'
	SERVICE_DESTINATION_PATH = '/etc/systemd/system/wallet.service'
	NGINX_DESTINATION_PATH = '/etc/nginx/sites-available'
	CURRENT_FOLDER = `pwd`.chomp
	DEBUG_MESSAGES_FOR = [:development, :test]
	CREATE_USERS_DESTINATION_PATH = './create_users.json'
	JWT_KEYPAIR_PATH = File.expand_path './jwt_keys'
	JWT_SIGN_FILE_NAME = 'token.rsa'
	JWT_VERIFY_FILE_NAME = 'token.rsa.pub'

	def ServerSettings.validate_env(env)
		if !ALLOWED_ENVS.include?(env) then 
			raise ArgumentError.new("Environment should be: #{ALLOWED_ENVS.to_s}")
		else 
			return env
		end
	end

	def ServerSettings.create_users(users = [])
		if !users.empty?
			puts "Creating #{CREATE_USERS_DESTINATION_PATH}. This file will be run on each server start to re-create users"
			out_file = File.new("#{ServerSettings::CREATE_USERS_DESTINATION_PATH}", "w")
			out_file.puts(users.to_json)
			out_file.close
		end
	end
	
	def ServerSettings.create_token_keypair()
		keypair = OpenSSL::PKey::RSA.generate(2048)
		Dir.mkdir(JWT_KEYPAIR_PATH) if !Dir.exist?(JWT_KEYPAIR_PATH)
		File.write("#{JWT_KEYPAIR_PATH}/#{JWT_SIGN_FILE_NAME}", keypair, mode: "w")
		File.write("#{JWT_KEYPAIR_PATH}/#{JWT_VERIFY_FILE_NAME}", keypair.public_key, mode: "w")
	end

	def ServerSettings.setup_service(env_values,users)
		ServerSettings.create_users(users)
		puts "Setting up service for Sinatra"
		puts "Saving file to #{ServerSettings::SERVICE_DESTINATION_PATH}"
		@env_values = env_values
		service_settings = ERB.new(File.read(File.expand_path(ServerSettings::SERVICE_TEMPLATE_PATH)))
		out_file = File.new(ServerSettings::SERVICE_DESTINATION_PATH, "w")
		out_file.puts(service_settings.result(binding))
		out_file.close
		puts "File saved."
		puts "If you want to run sinatra on startup, please run 'sudo systemctl enable wallet'"
		service_settings = ERB.new(File.read(File.expand_path(ServerSettings::NGINX_TEMPLATE_PATH)))
		out_file = File.new("#{ServerSettings::NGINX_DESTINATION_PATH}/#{@env_values['domain']}", "w")
		out_file.puts(service_settings.result(binding))
		out_file.close
		puts "You need to enable created nginx server: 'sudo ln -s /etc/nginx/sites-available/#{@env_values['domain']} /etc/nginx/sites-enabled  && sudo service nginx restart'"
	end
	
	def ServerSettings.list_ifconfig_ips
		a = `ifconfig | grep 'inet ' | awk '{print $2}'`
		a = a.split
		return a
	end
	
	def ServerSettings.return_errors(short,full,env)
		errorlevel = DEBUG_MESSAGES_FOR.include?(env)
		if errorlevel 
			return "#{short.message}. #{full.to_s}"
		else
			return short.message
		end
	end

	def ServerSettings.save_pid
		pid = Process.pid
		pidfile_path = File.join(ServerSettings::CURRENT_FOLDER,"wallet.pid")
		pidfile = File.new(pidfile_path, "w")
		pidfile.puts(pid)
		pidfile.close
	end
end
