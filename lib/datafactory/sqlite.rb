module DataFactory
	module DataFactory::SQLite
		require 'sqlite3'
		DB_PATH = ENV["WALLET_DB_PATH"] || '../db.sqlite'
		def self.prepare_migration_request(model)
			request = ''
			scheme = model
			fields = scheme[:fields].map { |m| "\"#{m[:name]}\" #{m[:type]}" }
			request = "CREATE TABLE IF NOT EXISTS \"#{scheme[:tableName]}\"(#{fields.join(',')},PRIMARY KEY(\"#{scheme[:idField]}\"))"
			return request
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
			request = "SELECT * FROM #{model[:tableName]} "
			filter = "WHERE #{model[:idField]}=\"#{id}\""
			re = self.request(request + filter)
			return re.first
		end
		
		def self.create(model, data)
			id_pointer = model[:idField].to_sym
			acc = self.get(model, data[id_pointer])
			if ! acc then
				data[:timeUpdated] = Time.now.iso8601
				keys = data.keys.map { |e| e.to_s }.join(',')
				values = " '#{data.values.join('\',\'')}' "
				request = "INSERT INTO #{model[:tableName]} (#{keys.to_s}) VALUES (#{values})"
				re = self.request(request)
				return acc = self.get(model, data[id_pointer])
			else
				acc = self.update(model, data)
				return acc
			end
		end

		def self.get_all(model)
			request = "SELECT * FROM #{model[:tableName]}"
			re = self.request(request)
			resp = re.map {|str| str.transform_keys(&:to_sym) }
			return resp
		end

		def self.update(model,  data)
			id_pointer = model[:idField].to_sym
			request = "UPDATE #{model[:tableName]} SET"
			data[:timeUpdated] = Time.now.iso8601
			data.each do |k,v|
				request = "#{request} #{k.to_s}='#{v}',"
			end
			request = "#{request.chop} WHERE #{model[:idField]}=\"#{data[id_pointer]}\""
			re = self.request(request)
			return self.get(model, data[id_pointer])
		end
	end
end