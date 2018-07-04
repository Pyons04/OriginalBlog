require 'pg'
require 'pry'
require 'sinatra'
require 'rails'



connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")

result = connection.exec("SELECT image FROM image WHERE id=5").first

send_data(result [:filename => image.jpg])



