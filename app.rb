# -*- coding: utf-8 -*-
require 'sinatra'
require 'omniauth-slack'
require_relative 'models/user'
Mongoid.load!('./mongoid.yml')
path = ENV["FILE_PATH"]
files_path = ENV["FILE_PATH"]

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
    @user = User.where(uid: session[:uid]).first
  end
  @dir = files_path
  @list = Dir.glob("#{files_path}/*").map{|f| f.split('/').last}
  haml :index
end

get '/file/:username' do |username|
  if session[:uid].nil? then
    @user = nil
  else
    @user = User.where(uid: session[:uid]).first
  end
  @list = Dir.glob("#{files_path}/#{username}/*").map{|f| f.split('/').last}
  haml :user
end

post '/upload' do
  if params[:file]
    @user = User.where(uid: session[:uid]).first
    filename = params[:file][:filename].split(".").first
    extension = params[:file][:filename].split(".").last
    p save_path = "#{files_path}/#{@user.name}/#{filename}.#{extension}"
    @list = Dir.glob("#{files_path}/#{@user.name}/*")
    index = 1
    while File.exist?(save_path) do
      p @message = "File is exist!"
      p save_path = "#{files_path}/#{@user.name}/#{filename}(#{index}).#{extension}"
      index += 1
    end
    File.open(save_path, 'wb') do |f|
      f.write params[:file][:tempfile].read
      p @message = "File upload success"
    end
  end
  #redirect '/file/'+@user.name
end

get '/download/:user/:filename' do |user, filename|
  send_file "#{files_path}/#{user}/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end

get '/delete/:user/:filename' do |user,filename|
  File.delete("#{files_path}/#{user}/#{filename}")
  redirect '/file/'+user
end

get '/auth/slack/callback' do
  auth = request.env['omniauth.auth']
  credentials = request.env['omniauth.auth']['credentials']
  extra = request.env['omniauth.auth']['extra']
  name = extra['raw_info']['user']
  path = "#{files_path}/#{name}"
  FileUtils.mkdir_p(path) unless File.exist?(path)
  if User.where(uid: auth['uid']).exists? then
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
end

get '/login' do
  pass if request.path_info =~ /^\/auth\//
  if current_user
    redirect '/'
  else
    redirect '/auth/slack'
  end
end

get '/logout' do
  session[:uid] = nil
  redirect '/'
end

helpers do
  def current_user
    if session[:uid].nil? then
      @user = nil
    else
      @user = User.where(uid: session[:uid]).first
    end
    #!session[:uid].nil?
    !@user.nil?
  end
end
