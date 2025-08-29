puts "(WORKS ONLY IN UBUNTU) Do you want to set up service [y/n]"
service_setup = gets.chomp
until ['y','n'].include?(service_setup)
	puts "Wrong input, type in 'y' or 'n'"
	service_setup = gets.chomp
end
#if service_setup == 'y' then
# 	#GET Domain
# 	puts "Please enter DOMAIN and hit Enter (will be used by NGINX)"
# 	domain = gets.chomp
# 	values['domain'] = domain
# 	puts "Domain chosen: #{values['domain']}"
# 	puts "----------------------------------------------"
# 	# GET PORT
# 	puts "Please enter PORT number and hit Enter (will be used by NGINX)"
# 	port_s = gets.chomp
# 	values['port'] = port_s.to_i
# 	puts "Port chosen: #{values['port']}"
# 	puts "----------------------------------------------"

# 	# Get SSL files path
# 	puts "Please enter Path where your SSL certificates are located"
# 	values['ssl'] = gets.chomp
# 	puts "SSL Path saved: #{values['ssl']}"
# 	puts "----------------------------------------------"
# 	Controller::Settings.setup_service(values)
# end
