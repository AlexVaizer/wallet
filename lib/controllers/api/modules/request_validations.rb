module Controllers
	module Api	
		module RequestValidations
			def parseHeaders
				return Hash[*@request.env.select {|k,v| k.start_with? 'HTTP_'}
					.collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
					.collect {|k,v| [k.split('_').collect(&:downcase).join('-'), v]}
					.sort
					.flatten]
			end
			def validateHeaders
				h = parseHeaders
				#logger.debug("Headers parsed: #{h}")
				if !h['accept'].nil? && !['application/json','*/*'].include?(h['accept'])
					@error = ValidationError.new("Request Validation Failed") 
					@error.internalCode = "#{self.class::ERROR_PREFIX}-03"
					@error.details = {headers: {accept: {error:"only application/json acceptable", value: h['accept']}}}
					raise @error 
				end
			end
			def parseToken
				reqToken = @request.cookies['token']
				@token = Token.new(reqToken,@settings)
				@user = Model::User.new({userId:@token.payload["userId"]}).getFromDb if @token.isValid
				if !@token.isValid || @user.error
					@error = Api::AuthenticationError.new("Token invalid")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-01"
					raise @error
				end
			end
			def authorize
				if @protected
					logger.debug("Accessing protected Controllers. Parsing Token: #{@request.cookies['token'][0..6] if @request.cookies['token']}..#{@request.cookies['token'][-6..-1] if @request.cookies['token']}")
					parseToken
					if @requiredPermission
						logger.debug("Checking User's Permissions for '#{@requiredPermission}' role")
						return true if @user.permissions.include?(@requiredPermission)
						@error = Api::AuthorizationError.new("No Needed Permissions. Required: #{@requiredPermission}. Given: #{@user.permissions}")
						@error.internalCode = "#{self.class::ERROR_PREFIX}-04"
						raise @error
					end
				else
					logger.debug("Accessing unprotected controller, token parsing skipped")
				end
				return true
			end
			def parsePayload
				begin
					@request.body.rewind
					body = @request.body.read
					@requestPayload = JSON.parse(body, symbolize_names: true)
				rescue => e 
					@error = Api::ValidationError.new("Request Validation Failed")
					@error.internalCode = "#{self.class::ERROR_PREFIX}-02"
					@error.details = e.inspect
					raise @error
				end
			end
			def validatePayload
				parsePayload
			end
			def validateRequest
				validateHeaders
				authorize
				validatePayload if self.class::HAS_REQUEST_BODY
			end
		end
	end
end