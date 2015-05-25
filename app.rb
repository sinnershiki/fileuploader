# -*- coding: utf-8 -*-
require 'sinatra'

get '/' do
  @list = Dir.glob("./files/*").map{|f| f.split('/').last}
  #puts @list
  haml :index

end


post '/upload' do
  if params[:file]
    save_path = "./files/#{params[:file][:filename]}"
    File.open(save_path, 'wb') do |f|
      p params[:file][:tempfile]
      f.write params[:file][:tempfile].read
      @mes = "アップロード成功"
    end
  end
  haml :upload
  redirect '/'
end

get '/download/:filename' do |filename|
  send_file "./files/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end
