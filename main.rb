require 'sinatra'
require 'pg'
require 'redcarpet'
require 'pry'
require 'rails'


markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)


get '/' do
   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     connection.finish

     ids = []
     result.each do |record|
     ids<<record['id']
     end
     latest_id = ids.max.to_i

     latest_blog = result.select{|records| records['id'] == latest_id.to_s}.first

     @html = markdown.render(latest_blog['content'])
     @title = latest_blog['title']
     @date = latest_blog['post_date']
     @time = latest_blog['post_time']

     second_id = latest_id - 1 #なぜかlatest_idがstringになってしまっているため、Integerに戻さないと計算できない。（バグ）
     second_blog = result.select{|records| records['id'] == second_id.to_s}.first

   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
   end


     third_id = latest_id - 2
     third_blog = result.select{|records| records['id'] == third_id.to_s}.first

   unless second_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
   end

   fourth_id = latest_id - 3
   fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first

    @backnumber_link = false

    unless fourth_blog.nil? then
        @backnumber_link = true
        @link = "/oldpost/1"
    end

    erb :home
end


get '/oldpost/:number' do

    connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     connection.finish

     ids = []
     result.each do |record|
     ids<<record['id']
     end


     param = params[:number].to_i*3
     latest_id = ids.max.to_i - param  #最新の記事のidから3つ前のidの記事を持ってくる,2ページ目以降はパラメータの値*3つ分古い記事を持ってくる。

  unless latest_id.nil? then
     latest_blog = result.select{|records| records['id'] == latest_id.to_s}.first

     @html = markdown.render(latest_blog['content'])
     @title = latest_blog['title']
     @date = latest_blog['post_date']
     @time = latest_blog['post_time']

     second_id = latest_id - 1 #なぜかlatest_idがstringになってしまっているため、Integerに戻さないと計算できない。（バグ）
     second_blog = result.select{|records| records['id'] == second_id.to_s}.first
  end

   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
   end


     third_id = latest_id - 2
     third_blog = result.select{|records| records['id'] == third_id.to_s}.first

   unless second_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
   end

   fourth_id = latest_id - 3
   fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first

    @backnumber_link = false

    unless fourth_blog.nil? then
        @backnumber_link = true
        link = params[:number].to_i+1
        @link = "/oldpost/#{link}"
    end

    erb :home


end


get '/post' do
  erb :post
end

post '/submit' do

     @password = params[:password]

     @title = params[:title]
     @content = params[:content]

     connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
     result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     ids = []
     result.each do |record|
     ids<<record['id']
     end
     latest_id = ids.max.to_i

     @id = latest_id+1


     result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{@id.to_i}')")


     redirect'/'
end