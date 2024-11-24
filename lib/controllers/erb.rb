module Controller
	module Erb
		MODULE_ERROR_CODES = '02'
		require File.expand_path(File.join(__dir__,"erb/base.rb"))
		require File.expand_path(File.join(__dir__,"erb/login.rb"))
		require File.expand_path(File.join(__dir__,"erb/get_index.rb"))
	end
end