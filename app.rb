# -*- coding: utf-8 -*-
require 'sinatra'
require 'omniauth-slack'
require_relative 'models/user'
Mongoid.load!('./mongoid.yml')
file_path = ENV["FILE_PATH"]

configure do
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]
  use OmniAuth::Builder do
    provider :slack, ENV["SLACK_APP_ID"], ENV["SLACK_APP_SECRET"], scope: "client", team: "coms"
  end
end

get '/' do
  if session[:uid].nil? then
    @user = nil
  else
    p @user = User.where(uid: session[:uid]).first
  end
  @list = Dir.glob("#{file_path}/*").map{|f| f.split('/').last}
  haml :index
end

post '/upload' do
  p "upload"
  if params[:file]
    filename = params[:file][:filename].split(".").first
    extension = params[:file][:filename].split(".").last
    p save_path = "#{file_path}/#{filename}.#{extension}"
    @list = Dir.glob("#{file_path}/*")
    index = 1
    while File.exist?(save_path) do
      p @message = "File is exist!"
      p save_path = "#{file_path}/#{filename}(#{index}).#{extension}"
      index += 1
    end
    File.open(save_path, 'wb') do |f|
      #p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      p @message = "File upload success"
    end
  end
  redirect '/'
end

get '/download/:filename' do |filename|
  send_file "#{file_path}/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end

get '/delete/:filename' do |filename|
  File.delete("#{file_path}/#{filename}")
  redirect '/'
end

get '/auth/slack/callback' do
  auth = request.env['omniauth.auth']
  credentials = request.env['omniauth.auth']['credentials']
  extra = request.env['omniauth.auth']['extra']
  if User.where(uid: auth['uid']).exists? then
    p "exist"
    session[:uid] = auth["uid"]
    redirect '/'
  else
    user = User.new(uid: auth['uid'], token: credentials['token'], name: extra['raw_info']['user'])
    if user.save!
      session[:uid] = auth["uid"]
      redirect '/'
    else
      redirect '/login'
    end
  end
  #redirect '/'
end

get '/login' do
  # we do not want to redirect to twitter when the path info starts
  # with /auth/
  pass if request.path_info =~ /^\/auth\//

  # /auth/twitter is captured by omniauth:
  # when the path info matches /auth/twitter, omniauth will redirect to twitter
  if current_user
    redirect '/'
  else
    redirect '/auth/slack'
  end
  #p session[:uid]
end

get '/logout' do
  session[:uid] = nil
  redirect '/'
end

helpers do
  # define a current_user method, so we can be sure if an user is authenticated
  def current_user
    !session[:uid].nil?
  end
end
