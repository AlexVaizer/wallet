require File.expand_path('./lib.rb')
values = {}
# Get DB Connection string
puts "Please enter Mongo DB connection URI. Must contain login/password"
values['WALLET_MONGO_STRING'] = gets.chomp
puts "DB string saved: #{values['WALLET_MONGO_STRING']}"
puts "----------------------------------------------"
@s = Controller::Settings.new()
# Get DB Name
puts "Please enter Mongo Database name"
values['WALLET_DB_NAME'] = gets.chomp
puts "DB name saved: #{values['WALLET_DB_NAME']}"
puts "----------------------------------------------"
values['RACK_ENV'] = 'production'
@s.readVars(values)
puts "Trying to get settings from DB"
@s.getFromDb
puts @s.to_a.inspect
puts "----------------------------------------------"
puts "----------------------------------------------"
puts "----------------------------------------------"
env_values_string = "RACK_ENV='production' WALLET_MONGO_STRING=#{@s.get('env.WALLET_MONGO_STRING')} WALLET_DB_NAME=#{@s.get('env.WALLET_DB_NAME')}"
puts "----------------------------------------------"
puts "Command to run server manually:\n#{env_values_string} ruby #{Controller::Settings::CURRENT_FOLDER}/wallet.rb"

# 