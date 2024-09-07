require File.expand_path('./lib/server_settings.rb')
#require  File.expand_path('./lib/datafactory/sqlite.rb')
require 'bcrypt'


values = {}



# Get DB PATH
puts "Please enter SQLite DB path."
values['db_path'] = gets.chomp
values['db_path'] = File.expand_path(values['db_path'])
puts "DB path saved: #{values['db_path']}"
puts "----------------------------------------------"


env_values_string = "WALLET_DEBUG_MODE='true' RACK_ENV='production' WALLET_DB_PATH=#{values['db_path']}"
puts "(WORKS ONLY IN UBUNTU) Do you want to set up service [y/n]"
service_setup = gets.chomp
until ['y','n'].include?(service_setup)
	puts "Wrong input, type in 'y' or 'n'"
	service_setup = gets.chomp
end
puts "Enter number of users you want to create on server start"
users_number = gets.chomp.to_i
users = []
users_number.times do |user|
	user = {}
	puts "Enter Username"
	user[:id] = gets.chomp
	puts "Enter Password"
	user[:password] = BCrypt::Password.create(gets.chomp)
	puts "Enter Monobank Api Key. For using local data for FE debug enter any string"
	user[:monoApiKey] = gets.chomp
	puts "Enter all Allowed accounts IDs including Ether ones. For using local data for FE debug enter 'iPQ623XhEjaP03RvipzGvg,RXgPPTrGMLQu_iX,vwM0597-8y5pyZX,aDIOepi3OM48BgBqHVZQhw,ZhcEkxQNsgSozL2,0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be,0x664f181df95a411865afc77a99cc0617d17f1c78'"
	user[:allowedAccountIds] = gets.chomp
	puts "Enter all Allowed Jar IDs. For using local data for FE debug enter 'SlHUM-1qJEA_pzc_EvGIf5Cs1234567,3_eXW5If939bPhonMGclqxba1234588'"
	user[:allowedJarIds] = gets.chomp
	puts "Enter ETH addresses, separated by comma. For using local data for FE debug enter '0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be,0x664f181df95a411865afc77a99cc0617d17f1c78'"
	user[:ethAddresses] = gets.chomp
	puts "Enter Etherscan Api Key. For using local data for FE debug enter any string"
	user[:ethApiKey] = gets.chomp
	users.push(user)
end


if service_setup == 'y' then
	#GET Domain
	puts "Please enter DOMAIN and hit Enter"
	domain = gets.chomp
	values['domain'] = domain
	puts "Port chosen: #{values['domain']}"
	puts "----------------------------------------------"
	# GET PORT
	puts "Please enter PORT number and hit Enter (will be used only in case of PROD)"
	port_s = gets.chomp
	values['port'] = port_s.to_i
	puts "Port chosen: #{values['port']}"
	puts "----------------------------------------------"

	# Get SSL files path
	puts "Please enter Path where your SSL certificates are located"
	values['ssl'] = gets.chomp
	puts "SSL Path saved: #{values['ssl']}"
	puts "----------------------------------------------"
	ServerSettings.setup_service(values,users)
else
	ServerSettings.create_users(users)
	puts "----------------------------------------------"
	puts "Command to run server manually:\n#{env_values_string} ruby #{ServerSettings::CURRENT_FOLDER}/wallet.rb"
end
