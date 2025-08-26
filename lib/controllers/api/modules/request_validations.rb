module Controller
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
				if !h['accept'].nil? && h['accept'] != 'application/json'
					@error = ValidationError.new("Request Validation Failed") 
					@error.internalCode = "01-03"
					@error.details = {headers: {accept: {error:"only application/json acceptable", value: h['accept']}}}
					raise @error 
				end
			end
			def parseToken
				reqToken = @request.cookies['token']
				@token = Token.new(reqToken)
				@user = Model::User.new({_id:@token.payload["userId"]}).getFromDb if @token.isValid
				if !@token.isValid || @user.error
					@error = Api::AuthenticationError.new("Token invalid")
					@error.internalCode = "01-01"
					raise @error
				end
			end
			def authorize
				if @protected
					logger.debug("Accessing protected Controller. Parsing Token: #{@request.cookies['token'][0..6] if @request.cookies['token']}..#{@request.cookies['token'][-6..-1] if @request.cookies['token']}")
					parseToken
					if @requiredPermission
						logger.debug("Checking User's Permissions for '#{@requiredPermission}' role")
						return true if @user.permissions.include?(@requiredPermission) 
						
						logger.debug("No Needed Permissions for user #{@user._id}. Required: #{@requiredPermission}. Given: #{@user.permissions}")
						@error = Api::AuthorizationError.new("No Needed Permissions. Required: #{@requiredPermission}. Given: #{@user.permissions}")
						@error.internalCode = "01-04"
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
					@error.internalCode = "01-02"
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
				validatePayload
			end
		end
	end
end