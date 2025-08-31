require File.expand_path('./lib.rb')
values = {}
puts "================================================="
puts "== Phase1: DB Test"
puts "================================================="
puts "====== Please enter Mongo DB connection URI. Must contain login/password"
values['WALLET_MONGO_STRING'] = gets.chomp
puts "====== Please enter Mongo Database name"
values['WALLET_DB_NAME'] = gets.chomp
puts "================================================="
values['RACK_ENV'] = 'production'
@s = Controller::Settings.new()
@s.readVars(values)
puts "Trying to get settings from DB"
@s.getFromDb
puts "====== Next settingIds parsed from DB: #{@s.map {|e| e._id}}"
puts "================================================="
puts "== (PASSED) Phase1: DB Test"
puts "================================================="
puts "== Phase2: (optional) Service Files Generation"
puts "================================================="
puts "====== Do you want to set up service files for wallet and nginx? [y/n]"
service_setup = gets.chomp
until ['y','n'].include?(service_setup)
	puts "!!!!!! Wrong input, type in 'y' or 'n', it's just one letter out of 2, you can do it :harold:"
	puts "!!!!!! Check your Caps Lock man, IDK :old-man-yells-at-parrot:"
	service_setup = gets.chomp
end
if service_setup == 'y' then
	puts "====== Please enter DOMAIN and hit Enter (will be used by NGINX)"
	domain = gets.chomp
	values['domain'] = domain
	puts "====== Please enter PORT number and hit Enter (will be used by NGINX)"
	port_s = gets.chomp
	values['port'] = port_s.to_i
	puts "====== Please enter Path where your SSL certificates are located"
	values['ssl'] = gets.chomp

	values['sinatra_ip'] = @s.get("sinatra.ip") || "127.0.0.1"
	values['sinatra_port'] = @s.get("sinatra.port") || 8080
	Controller::Settings.setup_service(values)
else
	puts "====== Okay, then no files generation, so we assume you are using sinatra locally then :shrug:"
	puts "====== Command to run server in local dev mode:"
	env_values_string = "RACK_ENV='production' WALLET_MONGO_STRING=#{@s.get('env.WALLET_MONGO_STRING')} WALLET_DB_NAME=#{@s.get('env.WALLET_DB_NAME')}"
	puts "#{env_values_string} ruby #{Controller::Settings::CURRENT_FOLDER}/wallet.rb"

end

