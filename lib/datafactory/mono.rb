module DataFactory
	module DataFactory::Mono
		CLIENT_INFO_PATH = '/personal/client-info'
		STATEMENTS_PATH = '/personal/statement'
		API_URL = 'https://api.monobank.ua'
		PAYMENT_SYSTEMS = {
			'5' => 'MC',
			'4' => 'VISA'
		}
		MOCK_DATA = {
			client_info: {
					"clientId"=>"4xhSmt92RD", 
					"name"=>"Вайзер Олександр", 
					"webHookUrl"=>"", 
					"permissions"=>"psfj", 
					"accounts"=>[ 
						{"id"=>"iPQ623XhEjaP03RvipzGvg", "sendId"=>"ASDFGYTR", "currencyCode"=>978, "cashbackType"=>"UAH", "balance"=>1200, "creditLimit"=>0, "maskedPan"=>["537541******4467"], "type"=>"black", "iban"=>"UA69322001000001234567890123"}, 
						{"id"=>"RXgPPTrGMLQu_iX", "sendId"=>"", "currencyCode"=>980, "cashbackType"=>"", "balance"=>50, "creditLimit"=>0, "maskedPan"=>[], "type"=>"fop", "iban"=>"UA623220010000026009300295836"}, 
						{"id"=>"vwM0597-8y5pyZX", "sendId"=>"4xhSmt9HHU", "currencyCode"=>980, "cashbackType"=>"UAH", "balance"=>791749, "creditLimit"=>0, "maskedPan"=>["537541******0999"], "type"=>"black", "iban"=>"UA17322001000001234567890123"}, 
						{"id"=>"aDIOepi3OM48BgBqHVZQhw", "sendId"=>"7Vx3VA7HHU", "currencyCode"=>980, "cashbackType"=>"UAH", "balance"=>248018, "creditLimit"=>0, "maskedPan"=>["444111******8867"], "type"=>"white", "iban"=>"UA42322001000001234567890123"}, 
						{"id"=>"ZhcEkxQNsgSozL2", "sendId"=>"", "currencyCode"=>980, "cashbackType"=>"UAH", "balance"=>0, "creditLimit"=>0, "maskedPan"=>["444111******9876"], "type"=>"eAid", "iban"=>"UA63322001000001234567890123"}
					], 
					"jars"=>[
						{"id"=>"SlHUM-1qJEA_pzc_EvGIf5Cs1234567", "sendId"=>"jar/5D155113tY7", "title"=>"На машину", "description"=>"", "currencyCode"=>978, "balance"=>40000, "goal"=>40000}, 
						{"id"=>"3_eXW5If939bPhonMGclqxba1234588", "sendId"=>"jar/3XSbN321KK", "title"=>"На чорний день", "description"=>"", "currencyCode"=>840, "balance"=>40000, "goal"=>400000}
					]
			},
			statements: [
				{"id"=>"fQ35XN5yrDI0wFys", "time"=>1612212722, "description"=>"Patreon", "mcc"=>5815, "amount"=>-14080, "operationAmount"=>-500, "currencyCode"=>840, "commissionRate"=>0, "cashbackAmount"=>0, "balance"=>1409232, "hold"=>false, "receiptId"=>"K737-HMXC-H45X-1234"}, 
				{"id"=>"43zcG2xWtQ-OE3Or", "time"=>1612188144, "description"=>"Від: Антон К.", "mcc"=>4829, "amount"=>12400, "operationAmount"=>12400, "currencyCode"=>980, "commissionRate"=>0, "cashbackAmount"=>0, "balance"=>1423312, "hold"=>true}, 
				{"id"=>"Gzl-xSPVTvsj-Lf5", "time"=>1612187087, "description"=>"Велика Кишеня", "mcc"=>5411, "amount"=>-12400, "operationAmount"=>-12400, "currencyCode"=>980, "commissionRate"=>0, "cashbackAmount"=>0, "balance"=>1410912, "hold"=>false, "receiptId"=>"HE3P-T762-EE2K-1234"}, 
				{"id"=>"ZEcXBmHXn6GzoqPN", "time"=>1612143372, "description"=>"Відсотки за сiчень", "mcc"=>4829, "amount"=>5010, "operationAmount"=>5010, "currencyCode"=>980, "commissionRate"=>0, "cashbackAmount"=>0, "balance"=>1423312, "hold"=>true}
			],
		}
		def self.get_client_info(user)
			if DataFactory::MOCK_DATA_FOR.include?(DataFactory::ENVIRONMENT) then
				client_info = Marshal.load(Marshal.dump(DataFactory::Mono::MOCK_DATA[:client_info]))
			else
				url = URI.join(DataFactory::Mono::API_URL, DataFactory::Mono::CLIENT_INFO_PATH).to_s
				client_info = DataFactory.send_request(url, user.monoApiKey)
			end
			return client_info
		end
		def self.get_statements(selected_account,monoApiKey, date_start = Time.now.to_i - 30*24*60*60, date_end = Time.now.to_i)
			if DataFactory::MOCK_DATA_FOR.include?(DataFactory::ENVIRONMENT) then
				statements = Marshal.load(Marshal.dump(DataFactory::Mono::MOCK_DATA[:statements]))
			else
				url = URI.join(DataFactory::Mono::API_URL, "#{DataFactory::Mono::STATEMENTS_PATH}/#{selected_account}/#{date_start}/#{date_end}").to_s
				statements = DataFactory.send_request(url, monoApiKey)
			end
			return statements
		end
	end
end