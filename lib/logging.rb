require 'logger'

module Logging
	class << self
		def logger
			if ENV['WALLET_DEBUG_MODE'] == 'true'
				level = 'debug' 
			else
				level = 'info'
			end
			@logger ||= Logger.new($stdout, formatter: proc {|severity, datetime, progname, msg|
				"time=[#{datetime}] severity=[#{severity}] cid=[#{progname}] - msg=[#{msg}]\n"
			}, level: level)
		end

		def logger=(logger)
			@logger = logger
		end
	end
	def self.included(base)
		class << base
			def logger
				Logging.logger
			end
		end
	end

	def logger
		Logging.logger
	end
end