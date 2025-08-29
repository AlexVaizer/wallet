class Token	
	require 'jwt'
	include Logging
	TOKEN_TTL = 7*24*3600 #7 days
	attr_reader :errorMessage, :exp, :header, :payload, :verifyKey, :signKey, :jwt, :isValid
	
	def initialize(token = nil, settings = nil)
		@signKey = OpenSSL::PKey.read(settings.get("sinatra.jwt.keys.sign"))
		@verifyKey = OpenSSL::PKey.read(settings.get("sinatra.jwt.keys.verify"))
		@payload = nil 
		@jwt = nil
		@isValid = false
		self.parseJwt(token) if token
		return self
	end

	def parseJwt(jwt)
		@jwt = jwt
		# begin
			@payload, @header = JWT.decode(@jwt, @verifyKey, true, { algorithm: 'RS256'})
			@exp = @header["exp"]
			@isValid = true
			if @exp.nil?
				raise ArgumentError.new "No exp set on JWT token."
				@isValid = false
			end
			@exp = Time.at(@exp.to_i)
			if Time.now > @exp
				raise ArgumentError.new "JWT token expired."
				@isValid = false
			end
		# rescue JWT::DecodeError => e
		# 	@errorMessage = "JWT invalid: #{e.message}"
		# 	@isValid = false
		# end
	end

		
	def create(payload)
		@header = {
			exp: Time.now.to_i + TOKEN_TTL 
		}
		@jwt = JWT.encode(payload, @signKey, "RS256", header)
		@exp = @header[:exp]
		@payload = payload
		@isValid = true
		return @jwt
	end
end