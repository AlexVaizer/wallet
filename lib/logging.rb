require 'logger'

module Logging
	class << self
		def logger
				@logger ||= Logger.new($stdout, formatter: proc {|severity, datetime, progname, msg|
					"time=[#{datetime}] severity=[#{severity}] cid=[#{progname}] - msg=[#{msg}]\n"
				}, level: 'info')
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