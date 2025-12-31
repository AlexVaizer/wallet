module Model
	class ClientInfo < Base
		DATA_MODEL = {
			tableName: 'clientInfos',
			idField: '_id',
			fields:[
				{ name: '_id', type: :text},
				{ name: 'userId', type: :text},
				{ name: 'clientId', type: :text},
				{ name: 'name', type: :text},
				{ name: 'webHookUrl', type: :text},
				{ name: 'permissions', type: :text},
				{ name: 'timeUpdated', type: :time},
				{ name: 'timeCreated', type: :time}
			]
		}
		fieldSet = DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: DATA_MODEL[:tableName], idField: DATA_MODEL[:idField], fieldSet: fieldSet)
		attr_accessor *fieldSet.map { |e| e.name }
		def model
			DATA_MODEL_OBJ
		end
		# def	isValid
		# 	return @timeUpdated > (Time.now - API_UPDATE_TIMEOUT) if !@timeUpdated.nil?
		# end
		def parseMonobankClientInfo(clientInfo,userId)
			@clientId = clientInfo['clientId']
			@name = clientInfo['name'] 
			@webHookUrl = clientInfo['webHookUrl']
			@permissions = clientInfo['permissions']
			@timeUpdated = Time.now
			@_id = userId
			@userId = userId
		end
	end
	class ClientInfosList < BaseList
		fieldSet = ClientInfo::DATA_MODEL[:fields].map { |e| Field.new(name: e[:name], type: e[:type]) }
		DATA_MODEL_OBJ = Model::DataModel.new(tableName: ClientInfo::DATA_MODEL[:tableName], idField: ClientInfo::DATA_MODEL[:idField], fieldSet: fieldSet)
		def model
			DATA_MODEL_OBJ
		end
		def parseOptions!(options)
			@model = DATA_MODEL_OBJ
			@list = []
			options.each {|acc| 
				model = Model::ClientInfo.new(acc)
				@list.push(model)
			}
			return true
		end
	end
end