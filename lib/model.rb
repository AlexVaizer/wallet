module Model
	TIME_FORMAT = "%d.%m %H:%M:%S"
	API_UPDATE_TIMEOUT = 70
	ROUND_ETH_AMOUNTS_TO = 6
	def self.logDebug(logger, text)
		logger.debug(text) if logger
	end
	def self.logError(logger, text)
		logger.error(text) if logger
	end
	def self.logInfo(logger, text)
		logger.info(text) if logger
	end
	def self.logWarn(logger, text)
		logger.warn(text) if logger
	end
end