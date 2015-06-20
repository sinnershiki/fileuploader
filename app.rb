# -*- coding: utf-8 -*-
require 'sinatra'
require 'omniauth-slack'
#user_path = "/home/sugano/files"
user_path = "./files"

configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :slack, ENV["SLACK_APP_ID"], ENV["SLACK_APP_SECRET"], scope: "client"
  end
end

get '/' do
  @list = Dir.glob("#{user_path}/*").map{|f| f.split('/').last}
  haml :index
end

post '/upload' do
  p "upload"
  if params[:file]
    filename = params[:file][:filename].split(".").first
    extension = params[:file][:filename].split(".").last
    p save_path = "#{user_path}/#{filename}.#{extension}"
    @list = Dir.glob("#{user_path}/*")
    index = 1
    while File.exist?(save_path) do
      p @message = "File is exist!"
      p save_path = "#{user_path}/#{filename}(#{index}).#{extension}"
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
  send_file "#{user_path}/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end

get '/delete/:filename' do |filename|
  File.delete("#{user_path}/#{filename}")
  redirect '/'
end

get '/auth/slack/callback' do
  p @auth = request.env['omniauth.auth']
  p request.env["omniauth.params"]
  p session[:uid] = request.env["omniauth.params"]["uid"]
  redirect '/'
end

get '/login' do
  #p ENV["SLACK_APP_ID"]
  #p ENV["SLACK_APP_SECRET"]

  # we do not want to redirect to twitter when the path info starts
  # with /auth/
  pass if request.path_info =~ /^\/auth\//

  # /auth/twitter is captured by omniauth:
  # when the path info matches /auth/twitter, omniauth will redirect to twitter
  redirect to('/auth/slack') unless current_user
end

helpers do
  # define a current_user method, so we can be sure if an user is authenticated
  def current_user
    !session[:uid].nil?
  end
end
