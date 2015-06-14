# -*- coding: utf-8 -*-
require 'sinatra'

get '/' do
  @list = Dir.glob("./files/*").map{|f| f.split('/').last}
  haml :index
end

post '/upload' do
  if params[:file]
    p save_path = "./files/#{params[:file][:filename]}"
    p @list = Dir.glob("./files/*")
    if File.exist?(save_path) then
      p @message = "File is exist!"
    else
      File.open(save_path, 'wb') do |f|
        p params[:file][:tempfile]
        f.write params[:file][:tempfile].read
      end
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
