module Model
	class User < Base
		require 'bcrypt'
		DATA_MODEL = {
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
		ATTRS = [:id, :password, :monoApiKey, :allowedAccountIds, :allowedJarIds, :ethAddresses, :ethApiKey]
		attr_accessor *ATTRS
		def parseOptions(options)
			@id = options[:id]
			@password = options[:password] || nil
			@monoApiKey = options[:monoApiKey] || ''
			@allowedAccountIds = options[:allowedAccountIds].split(',') if options[:allowedAccountIds]
			@allowedJarIds = options[:allowedJarIds].split(',') if options[:allowedJarIds]
			@ethAddresses = options[:ethAddresses].split(',') if options[:ethAddresses]
			@ethApiKey = options[:ethApiKey] || ''
			@error = nil
			@model = DATA_MODEL
			return true
		end
		def parseCryptedPass()
			return BCrypt::Password.new(@password) if @password
		end
		def to_h
			return result = {
				:id => @id,
				:password => @password,
				:monoApiKey => @monoApiKey,
				:allowedAccountIds => @allowedAccountIds.join(','),
				:ethAddresses => @ethAddresses.join(','),
				:ethApiKey => @ethApiKey
			}
		end
	end
end
