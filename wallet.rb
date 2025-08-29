#!/usr/bin/ruby

#########################################################
# => DEPENDENCIES										#
#########################################################
require 'bundler/setup'
Bundler.require 
require 'sinatra'
require "sinatra/basic_auth"
require "sinatra/cookies"
require File.expand_path('./lib/server_settings.rb')
require File.expand_path('./lib/logging.rb')
require File.expand_path('./lib/datafactory.rb')
require File.expand_path('./lib/model.rb')
require File.expand_path('./lib/token.rb')
require File.expand_path('./lib/controller.rb')
#########################################################
$walletSettings = Controller::Settings.new().getFromDb
#enable :logging
ServerSettings::ENV = ServerSettings.validate_env($walletSettings.get("sinatra.env").to_sym)
ServerSettings.save_pid

ServerSettings.create_token_keypair if $walletSettings.get("sinatra.env") == "production"
	set :environment, $walletSettings.get("sinatra.env")
	set :port, $walletSettings.get("sinatra.port")
	set :bind, $walletSettings.get("sinatra.ip")
	set :allow_origin, '*'
	set :views, Proc.new { File.join(root, "views") }
	set :show_exceptions, true 
	before do 
		@title = "Wallet"
	end

	get '/login' do 
		erb :login
	end

	get '/' do
		@c = Controller::Erb::GetIndex.new(request)
		@title =  "#{@c.requestedAccount.maskedPan} - " + @title if @c.requestedAccount
		@resp = @c.response
		status @resp.code
		cookies.delete(:token) if @resp.code == 401
		erb @resp.erb
	end

	post '/login' do 
		@c = Controller::Erb::Login.new(request)
		if @c.response.success
			response.set_cookie(:token, :value => @c.token.jwt, :expires => Time.at(@c.token.exp))
			#redirect to '/'
			redirect to(request.env['HTTP_ORIGIN']) 
		else
			@resp = @c.response
			status @resp.code
			erb @resp.erb
		end
	end
	get '/public/*' do 
		send_file(File.join('./public', params['splat'][0]))
	end

	require File.expand_path('./api.rb')