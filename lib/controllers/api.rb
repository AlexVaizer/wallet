module Controller
	module API
		MODULE_ERROR_CODE = '01'
		CLASS_ERROR_CODES = {
			'Base' => "#{MODULE_ERROR_CODE}-00",
			'Get' => "#{MODULE_ERROR_CODE}-01",
			'GetList' => "#{MODULE_ERROR_CODE}-02",
			'Delete' => "#{MODULE_ERROR_CODE}-03",
			'Patch' => "#{MODULE_ERROR_CODE}-04",
			'Put' => "#{MODULE_ERROR_CODE}-05",
			'Post' => "#{MODULE_ERROR_CODE}-06"
		}
		require File.expand_path(File.join(__dir__,"/api/base.rb"))
		require File.expand_path(File.join(__dir__,"/api/get.rb"))
		require File.expand_path(File.join(__dir__,"/api/get_list.rb"))
		require File.expand_path(File.join(__dir__,"/api/delete.rb"))
		require File.expand_path(File.join(__dir__,"/api/patch.rb"))
	end
end
