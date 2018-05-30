require 'sinatra'
require 'pg'


get '/' do
   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")
     # データベースへのコネクションを切断する
     connection.finish

     array = []
     #データベースの内容を配列に収納
     result.each do |record|
     array<<record['content']
     end

     p array
  'hello'
end