class Token	
	require 'jwt'
	require 'openssl'
	include Logging
	TOKEN_TTL = 7*24*3600 #7 days
	FALLBACK_SIGN = "-----BEGIN RSA PRIVATE KEY-----\n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\n-----END RSA PRIVATE KEY-----\n"
	FALLBACK_VERIFY = "-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAljhe/W8De6cM0NyCg+29\n+jfCYvJ/vL3upqI7mDiItHqphjgw6uvPj4fe5wVJ7EjJ8/g/zQgmcHAjBf1WKV4V\nDlUjBDXPBKpUlczCque6QKWD0ZJwII3rI0ik+BWFXr5EWdjdb0xPSF0UFY5rJvW9\nvuG3pbHDZM2d2dJ9ihpayRPeS6M9k+DXSdOR9emTEkDHRJRrGQJXe52bn3kjJNyP\nRkmo+oqj3WbD260fHjuIsaoM6jdAzDquBa7s42tmcjJ3bL41gmXKt0+mM6qbKY5U\nLrakwmqOm9FH+5UAVoWtdfF4XRBL/z7tRhYiFZVwGskVQpdRimhKHgZBpX/tRwNw\nxIrXHUMxq0rEt6v602ouf2yjrWRnQuQiT9u4u5lYPaY9egMnMoKyBEFtmKEiSLXv\nHMY8xcij3zZyuwkHcY2emIpvO4n9Gbqr1ut51BUHq6C9mw1dk2NfPjSEsiK2zns7\nTuSdFO6L9t/mKI1l7pepx08W44/73R3qQ4tpQne/XD0nzwcGLxQDlDUS6ZTNcxbP\ny+zpAzr4y7jxxmhmgYwpamSV6d1iExuF+eHV2rJB20F3ssWVXXtB4f61AAx3FTJv\nPVQHXN/QQrs6RQG7NUplWFQbtAYcMm9aedifxFtKGzlfsbcvRV6jIBsKFCjDlHOF\nGkztI/p5SWsvCOpiJTvGEhECAwEAAQ==\n-----END PUBLIC KEY-----\n"
	attr_reader :errorMessage, :exp, :header, :payload, :verifyKey, :signKey, :jwt, :isValid
	
	def initialize(token = nil, settings = nil)
		if settings && settings.get("sinatra.jwt.keys.sign") && settings.get("sinatra.jwt.keys.verify")
			@signKey = OpenSSL::PKey.read(settings.get("sinatra.jwt.keys.sign"))
			@verifyKey = OpenSSL::PKey.read(settings.get("sinatra.jwt.keys.sign"))
		else
			@signKey = OpenSSL::PKey.read FALLBACK_SIGN
			@verifyKey = OpenSSL::PKey.read FALLBACK_VERIFY
		end
		@payload = nil 
		@jwt = nil
		@isValid = false
		self.parseJwt(token) if token
		return self
	end

	def parseJwt(jwt)
		@jwt = jwt
		 begin
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
		rescue JWT::DecodeError => e
			@errorMessage = "JWT invalid: #{e.message}"
			@isValid = false
		end
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