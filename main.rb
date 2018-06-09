require 'sinatra'
require 'pg'
require 'redcarpet'


markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)


get '/' do
   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     connection.finish

     array = []
     dates = []
     #データベースの内容を配列に収納
     result.each do |record|
     array<<record['content']
     dates<<record['post_date']
     end

     put = array[1]
     date = dates[1]


     html = markdown.render(put)

  "#{date}#{html}"
end