module ServerSettings
	require 'erb'
	require 'openssl'
	require 'json'
	ALLOWED_ENVS = [:development, :test, :production]
	SERVICE_TEMPLATE_PATH = './lib/templates/wallet_service.erb'
	NGINX_TEMPLATE_PATH = './lib/templates/nginx.erb'
	SERVICES_DESTINATION_PATH = './services/'
	CURRENT_FOLDER = `pwd`.chomp

	def validate_env(env)
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

	def save_pid
		pid = Process.pid
		pidfile_path = File.join(CURRENT_FOLDER,"wallet.pid")
		pidfile = File.new(pidfile_path, "w")
		pidfile.puts(pid)
		pidfile.close
	end
end
