#!/usr/bin/ruby
require 'bundler/setup'
Bundler.require 
require 'sinatra'
require "sinatra/basic_auth"
require "sinatra/cookies"
require File.expand_path('./lib.rb')
#########################################################
$walletSettings = Controllers::Settings.new().getFromDb
disable :logging
$walletSettings.save_pid
	set :environment, $walletSettings.get("sinatra.env")
	set :port, $walletSettings.get("sinatra.port")
	set :bind, $walletSettings.get("sinatra.ip")
	set :allow_origin, $walletSettings.get("sinatra.allowOrigin")
	set :views, Proc.new { File.join(root, $walletSettings.get("sinatra.viewsDir")) }
	set :show_exceptions, $walletSettings.get("sinatra.showExceptions")
	before do 
		@title = $walletSettings.get("sinatra.erb.webTitle")
	end

	get '/login' do 
		erb :login
	end

	get '/' do
		@c = Controllers::Erb::GetIndex.new(request)
		@title =  "#{@c.requestedAccount.maskedPan} - #{@title}" if @c.requestedAccount
		@resp = @c.response
		status @resp.code
		cookies.delete(:token) if @resp.code == 401
		erb @resp.erb
	end

	post '/login' do 
		@c = Controllers::Erb::Login.new(request)
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