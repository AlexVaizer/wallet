module DataFactory
	module DataFactory::SQLite
		require 'sqlite3'
		require 'bcrypt'
		DB_PATH = ENV["WALLET_DB_PATH"] || '../db.sqlite'
		DB_UPD_INTERVAL = 70 #seconds
		MODELS = {
			clientInfo: {
				tableName: 'clients',
				idField: 'id',
				fields:[
					{ name: 'id', type: 'TEXT'},
					{ name: 'clientId', type: 'TEXT'},
					{ name: 'name', type: 'TEXT'},
					{ name: 'webHookUrl', type: 'TEXT'},
					{ name: 'permissions', type: 'TEXT' },
					{ name: 'timeUpdated', type: 'TEXT'}
				]
			},
			account: {
				tableName: 'accounts',
				idField: 'id',
				fields: [ 
					{ name: 'id', type: 'TEXT'},
					{ name: 'balance', type: 'NUMERIC'},
					{ name: 'balanceUsd', type: 'NUMERIC'},
					{ name: 'currencyCode', type: 'TEXT'},
					{ name: 'type', type: 'TEXT'},
					{ name: 'maskedPan', type: 'TEXT'},
					{ name: 'maskedPanFull', type: 'TEXT'},
					{ name: 'ethUsdRate', type: 'NUMERIC'},
					{ name: 'userId', type: 'TEXT'},
					{ name: 'timeUpdated', type: 'TEXT'},
				]
			},
			jar: {
				tableName: 'jars',
				idField: 'id',
				fields: [ 
					{ name: 'id', type: 'TEXT'},
					{ name: 'sendId', type: 'TEXT'},
					{ name: 'title', type: 'TEXT'},
					{ name: 'description', type: 'TEXT'},
					{ name: 'currencyCode', type: 'TEXT'},
					{ name: 'balance', type: 'NUMERIC'},
					{ name: 'goal', type: 'NUMERIC'},
					{ name: 'timeUpdated', type: 'TEXT'}
				]
			},
			user: {
				tableName: 'user',
				idField: 'id',
				fields: [ 
					{ name: 'id', type: 'TEXT'},
					{ name: 'password', type: 'TEXT'},
					{ name: 'monoApiKey', type: 'TEXT'},
					{ name: 'allowedAccountIds', type: 'TEXT'},
					{ name: 'allowedJarIds', type: 'TEXT'},
					{ name: 'ethAddresses', type: 'TEXT'},
					{ name: 'ethApiKey', type: 'TEXT'},
					{ name: 'timeUpdated', type: 'TEXT'}
				]
			}
		}
		def self.prepare_migration_request(model)
			request = ''
			scheme = MODELS[model]
			fields = scheme[:fields].map { |m| "\"#{m[:name]}\" #{m[:type]}" }
			request = "CREATE TABLE IF NOT EXISTS \"#{scheme[:tableName]}\"(#{fields.join(',')},PRIMARY KEY(\"#{scheme[:idField]}\"))"
			return request
		end

		def self.migrate_db
			File.delete(DB_PATH) if File.exist?(DB_PATH)
			request_accounts = self.prepare_migration_request(:account)
			request_jars = self.prepare_migration_request(:jar)
			request_client_info = self.prepare_migration_request(:clientInfo)
			request_users = self.prepare_migration_request(:user)
			resp_client_info = self.request(request_client_info)
			resp_accounts = self.request(request_accounts)
			resp_jars = self.request(request_jars) 
			resp_users = self.request(request_users)
			return true
		end

		
		def self.request(request)
			db = SQLite3::Database.open(DB_PATH)
			#puts request
			db.results_as_hash = true
			re = db.execute(request)
			db.close
			resp = re.map {|str| str.transform_keys(&:to_sym) }
			return resp
		end


		def self.get(model, id)
			request = "SELECT * FROM #{MODELS[model][:tableName]} "
			filter = "WHERE #{MODELS[model][:idField]}=\"#{id}\""
			re = self.request(request + filter)
			return re.first
		end
		
		def self.create(model, data)
			id_pointer = MODELS[model][:idField].to_sym
			acc = self.get(model, data[id_pointer])
			if ! acc then
				data[:timeUpdated] = Time.now.iso8601
				keys = data.keys.map { |e| e.to_s }.join(',')
				values = " '#{data.values.join('\',\'')}' "
				request = "INSERT INTO #{MODELS[model][:tableName]} (#{keys.to_s}) VALUES (#{values})"
				re = self.request(request)
				return acc = self.get(model, data[id_pointer])
			else
				acc = self.update(model, data)
				return acc
			end
		end

		def self.get_all(model)
			request = "SELECT * FROM #{MODELS[model][:tableName]}"
			re = self.request(request)
			resp = re.map {|str| str.transform_keys(&:to_sym) }
			return resp
		end

		def self.update(model,  data)
			id_pointer = MODELS[model][:idField].to_sym
			request = "UPDATE #{MODELS[model][:tableName]} SET"
			data[:timeUpdated] = Time.now.iso8601
			data.each do |k,v|
				request = "#{request} #{k.to_s}='#{v}',"
			end
			request = "#{request.chop} WHERE #{MODELS[model][:idField]}=\"#{data[id_pointer]}\""
			re = self.request(request)
			return self.get(model, data[id_pointer])
		end
	end
end