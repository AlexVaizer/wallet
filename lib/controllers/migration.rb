module Controller
	class Migration
		require 'json'
		def initialize()
			@models = [Model::User::DATA_MODEL, Model::ClientInfo::DATA_MODEL, Model::Account::DATA_MODEL, Model::Jar::DATA_MODEL]
			@users = {dataModel: Model::User::DATA_MODEL}
			if File.exist?('./create_users.json')
				usersRaw = File.read(File.expand_path('./create_users.json')) 
				@users[:data] = JSON.parse(usersRaw,symbolize_names: true) 
			end
			@requests = []
			@models.each do |m|
				@requests.push(DataFactory::SQLite.prepare_migration_request(m))	
			end
		end
		def run!
			@requests.each do |req|
				DataFactory::SQLite.request(req)
			end
			@users[:data].each do |u|
				DataFactory::SQLite.create(@users[:dataModel],u)
			end
			return true
		end
	end
end