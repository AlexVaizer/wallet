module Model
	TIME_FORMAT = "%d.%m %H:%M"
	ROUND_ETH_AMOUNTS_TO = 6
	MONGO_STRING = ENV['WALLET_MONGO_STRING']
	MONGO_DATABASE = ENV['WALLET_DB_NAME']
	require 'mongo'
	require 'securerandom'
	Field = Struct.new(:name, :type, keyword_init: true)	
	DataModel = Struct.new(:tableName, :idField, :fieldSet, keyword_init: true)
	Error = Struct.new(:code, :message, :exception, keyword_init: true)
	require File.expand_path(File.join(__dir__,"/models/base.rb"))
	require File.expand_path(File.join(__dir__,"/models/base_list.rb"))
	require File.expand_path(File.join(__dir__,"/models/user.rb"))
	require File.expand_path(File.join(__dir__,"/models/account.rb"))
	require File.expand_path(File.join(__dir__,"/models/client_info.rb"))
	require File.expand_path(File.join(__dir__,"/models/jar.rb"))
	require File.expand_path(File.join(__dir__,"/models/statement.rb"))
	#require File.expand_path(File.join(__dir__,"/models/zm_account.rb"))
	#require File.expand_path(File.join(__dir__,"/models/zm_tx.rb"))
	
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
