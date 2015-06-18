# -*- coding: utf-8 -*-
require 'sinatra'
#user_path = "/home/sugano/files"
user_path = "./files"

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
