require 'sinatra'
require_relative "1"

get '/api' do
	Database::getStatusCountAPI()
end

get '/' do
	File.read('index.html')
end