module Model
	TIME_FORMAT = "%d.%m %H:%M:%S"
	API_UPDATE_TIMEOUT = 70
	ROUND_ETH_AMOUNTS_TO = 6
	def self.getBySymbol(symbol)
		case symbol
		when :user
			return Model::User.new()
		when :account 
			return Model::Account.new()
		when :clientInfo
			return Model::ClientInfo.new()
		when :jar
			return Model::Jar.new()
		else
			raise StandardError.new "Unknown model"
		end
	end
	def self.getListBySymbol(symbol)
		case symbol
		when :account
			return Model::AccountsList.new()
		when :jar 
			return Model::JarsList.new()
		when :clientInfo
			return Model::ClientInfosList.new()
		when :user
			return Model::UsersList.new()
		else
			raise StandardError.new "Unknown model"
		end
	end
end