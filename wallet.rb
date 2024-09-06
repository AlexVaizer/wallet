#!/usr/bin/ruby

#########################################################
# => DEPENDENCIES										#
#########################################################
require 'bundler/setup'
Bundler.require 
require 'sinatra'
require "sinatra/basic_auth"
require "sinatra/cookies"
#require 'optparse'
require File.expand_path('./lib/server_settings.rb')
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
require File.expand_path('./lib/controller.rb')
#########################################################
env = ENV['WALLET_ENV'] || 'development'
env = env.to_sym
enable :logging
require 'logger'
ServerSettings::ENV = ServerSettings.validate_env(env)
logger = Logger.new(STDOUT)
logger.level = 'debug' if ENV['WALLET_DEBUG_MODE'] == 'true'
logger.debug(ServerSettings::ENV)
ServerSettings.save_pid
ServerSettings.create_token_keypair
migration = Controller::Migration.new
migration.run!

helpers do 
	def protected!
    	return if authorized?
    	cookies.delete(:token)
    	Model.logInfo(logger,"Token Invalid, logging out")
    	redirect to('/login')
	end

	def extractToken
		return reqToken = cookies[:token]
	end

	def authorized?
		reqToken = extractToken
		token = Token.new()
		token.parseJwt(reqToken)
		return token.isValid
	end
end

	set :environment, ServerSettings::ENV
	set :port, ServerSettings::PORT
	set :bind, ServerSettings::IP
	set :allow_origin, '*'
	set :views, Proc.new { File.join(root, "views") }

	get '/login' do 
		erb :login
	end

	post '/login' do 
		userId = params["id"]
		password = params["password"]
		@user = Model::User.new({id: userId},logger)
		@user.getFromDb
		if @user.parseCryptedPass == password
			token = Token.new()
			token.create(userId: userId)
			response.set_cookie(:token, :value => token.jwt, :expires => Time.at(token.exp))
			redirect('/')
		else
			status 400
			@errors = "Wrong Credentials"
			logger.error(@errors)
			erb :errors
		end
	end

		
	get '/' do
		protected!
		date_start = params['start'] || Time.now.to_i - 30*24*60*60
		date_end = params['end'] || Time.now.to_i
		begin
			@token = Token.new()
			@token.parseJwt(cookies[:token])
			@user = Model::User.new({id: @token.payload["userId"]},logger)
			@user.getAllInfoFromDb
			Model.logDebug(logger,"ClientInfo Validity: #{@user.clientInfo.isValid}")
			if !@user.clientInfo.isValid
				@user.getAndParseClientInfoFromApi
			end
			@title = "Accounts List – Wallet"
			if !(params['id'].nil? || params['id'].empty?) then 
				@user.requestedAccountId = params['id']
				Model.logDebug(logger,"RequestedAccount: '#{@user.requestedAccount}'")
				@user.getStatements
				@title = "#{@user.requestedAccount.maskedPan} – Wallet"
			end
			erb :index
		rescue 
			@errors = ServerSettings.return_errors($!,$@,ServerSettings::ENV)
			logger.error(@errors)
			status 500
			erb :errors
		end
	end

	
	get '/public/*' do 
		send_file(File.join('./public', params['splat'][0]))
	end
