module Model
	class ClientInfo < Base 
		ATTRS = [:clientId, :name, :webHookUrl, :permissions, :timeUpdated, :id, :isValid]
		attr_accessor *ATTRS
		def parseOptions(options)
			@clientId = options[:clientId] || ''
			@name = options[:name] || ''
			@webHookUrl = options[:webHookUrl] || ''
			@permissions = options[:permissions] || ''
			@isValid = false
			if options[:timeUpdated]
				@timeUpdated = Time.parse(options[:timeUpdated])
				@isValid = @timeUpdated > (Time.now - Model::API_UPDATE_TIMEOUT)
			end
			@id = options[:id]
			@error = nil
			@model = :clientInfo
			return true
		end
		def to_h
			return result = {
				:clientId => @clientId,
				:name => @name,
				:webHookUrl => @webHookUrl,
				:permissions => @permissions,
				:timeUpdated => @timeUpdated.to_s,
				:id => @id
			}
		end
		def parseMonobankClientInfo(clientInfo,userId)
			@clientId = clientInfo['clientId']
			@name = clientInfo['name'] 
			@webHookUrl = clientInfo['webHookUrl']
			@permissions = clientInfo['permissions']
			@timeUpdated = Time.now
			@isValid = true
			@id = userId
		end
	end
end