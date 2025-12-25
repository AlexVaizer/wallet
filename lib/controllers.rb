module Controllers
	require 'securerandom'
	include Logging
	class Response
		attr_accessor :erb, :code, :success, :errorCode, :errorMessage, :cookie
		def initialize(options = {})
			@erb = options[:erb] || :errors
			@code = options[:code] || 500
			@success = options[:success] || false
			@errorCode = nil
			@errorMessage = nil
			@cookie = nil
		end
		def to_h
			response = {
				:success => @success,
				:code => @code,
				:errorCode => @errorCode,
				:errorMessage => @errorMessage,
				:erb => @erb,
				:cookie => @cookie
			}
		end
	end
	require File.expand_path(File.join(__dir__,"/controllers/settings.rb"))
	require File.expand_path(File.join(__dir__,"/controllers/erb.rb"))
	require File.expand_path(File.join(__dir__,"/controllers/api.rb"))
end
