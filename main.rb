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
     titles = []
     #データベースの内容を配列に収納
     result.each do |record|
     array<<record['content']
     dates<<record['post_date']
     titles<<record['title']
     end

     put = array[0]
     @html = markdown.render(put)
     @title = titles[0]
     @date = dates[0]

    erb :home
end


get '/oldpost/:number' do

   number = params[:number].to_i
   
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

     put = array[number]
     date = dates[number]

     html = markdown.render(put)

  "#{date}#{html}"
end


get '/post' do

erb :post

end

post '/submit' do

  @password = params[:password]

     @title = params[:title]
     @content = params[:content]

     connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")

     result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0))")
     "データベースに追記しました。"

end