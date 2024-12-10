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
env = ENV['WALLET_ENV'] || 'development'
env = env.to_sym
disable :logging
ServerSettings::ENV = ServerSettings.validate_env(env)
ServerSettings.save_pid
#ServerSettings.create_token_keypair
migration = Controller::Migration.new
#migration.run!

	set :environment, ServerSettings::ENV
	set :port, ServerSettings::PORT
	set :bind, ServerSettings::IP
	set :allow_origin, '*'
	set :views, Proc.new { File.join(root, "views") }
	set :show_exceptions, false 
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
			redirect to('/') 
		else
			@resp = @c.response
			status @resp.code
			erb @resp.erb
		end
	end
	get '/public/*' do 
		send_file(File.join('./public', params['splat'][0]))
	end
if [:development,:test].include?(ServerSettings::ENV)


	get '/api/:model/:id' do
		@c = Controller::API::Get.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
	get '/api/:model' do
		@c = Controller::API::GetList.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
	delete '/api/:model/:id' do
		@c = Controller::API::Delete.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
	patch '/api/:model/:id' do
		@c = Controller::API::Patch.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
	put '/api/:model/:id' do
		@c = Controller::API::Put.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
	post '/api/:model' do
		@c = Controller::API::Post.new(request)
		status @c.response.status
		headers @c.response.headers
		body @c.response.to_json
	end
end