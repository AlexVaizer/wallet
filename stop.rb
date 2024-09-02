#!/usr/bin/ruby
file = File.open("./wallet.pid")
pid = file.readlines.first.chomp
file.close
puts "Killing process #{pid}"
`kill #{pid}`
puts "Wallet process #{pid} killed"
File.delete("./wallet.pid")