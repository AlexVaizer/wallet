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
require File.expand_path('./lib/datafactory/mono.rb')
require File.expand_path('./lib/datafactory/eth.rb')
require File.expand_path('./lib/datafactory/sqlite.rb')
require File.expand_path('./lib/model.rb')
require File.expand_path('./lib/models/base.rb')
require File.expand_path('./lib/models/user.rb')
require File.expand_path('./lib/models/client_info.rb')
require File.expand_path('./lib/models/account.rb')
require File.expand_path('./lib/models/statement.rb')
require File.expand_path('./lib/models/jar.rb')
require File.expand_path('./lib/token.rb')
require File.expand_path('./lib/controllers/migration.rb')
require File.expand_path('./lib/controllers/base.rb')
require File.expand_path('./lib/controllers/get_index.rb')
require File.expand_path('./lib/controllers/login.rb')
#########################################################
env = ENV['WALLET_ENV'] || 'development'
env = env.to_sym
disable :logging
ServerSettings::ENV = ServerSettings.validate_env(env)
ServerSettings.save_pid
ServerSettings.create_token_keypair
migration = Controller::Migration.new
migration.run!

	set :environment, ServerSettings::ENV
	set :port, ServerSettings::PORT
	set :bind, ServerSettings::IP
	set :allow_origin, '*'
	set :views, Proc.new { File.join(root, "views") }
	set :show_exceptions, true
	before do 
		@title = "vzrWallet"
	end

	get '/login' do 
		erb :login
	end

	get '/' do
		@c = Controller::GetIndex.new(request)
		@title =  "#{@c.requestedAccount.maskedPan} - " + @title if @c.requestedAccount
		@resp = @c.response
		status @resp.code
		erb @resp.erb
	end

	post '/login' do 
		@c = Controller::Login.new(request)
		if @c.response.success 
			response.set_cookie(:token, :value => @c.token.jwt, :expires => Time.at(@c.token.exp))
			redirect to('/') 
		else
			status @c.response.code
			@errors = @c.response.errorMessage
			erb @c.response.erb
		end
	end

	get '/public/*' do 
		send_file(File.join('./public', params['splat'][0]))
	end
