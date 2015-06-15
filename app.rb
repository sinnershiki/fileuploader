# -*- coding: utf-8 -*-
require 'sinatra'

get '/' do
  @list = Dir.glob("./files/*").map{|f| f.split('/').last}
  haml :index
end

post '/upload' do
  if params[:file]
    filename = params[:file][:filename].split(".").first
    extension = params[:file][:filename].split(".").last
    p save_path = "./files/#{filename}.#{extension}"
    @list = Dir.glob("./files/*")
    index = 1
    while File.exist?(save_path) do
      p @message = "File is exist!"
      p save_path = "./files/#{filename}(#{index}).#{extension}"
      index += 1
    end
    File.open(save_path, 'wb') do |f|
      #p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      p @message = "File upload success"
    end
  end
#  haml :upload
  redirect '/'
end

get '/download/:filename' do |filename|
  send_file "./files/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end

get '/delete/:filename' do |filename|
  File.delete("./files/#{filename}")
  redirect '/'
end
