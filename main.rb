require 'sinatra'
require 'pg'
require 'redcarpet'
require 'pry'
require 'rails'


markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)


get '/oldpost/:number' do

    connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     connection.finish

     ids = []
     result.each do |record|
     ids<<record['id'].to_i
     end


     param = params[:number].to_i*3
     latest_id = ids.max.to_i - param  #最新の記事のidから3つ前のidの記事を持ってくる,2ページ目以降はパラメータの値*3つ分古い記事を持ってくる。

  unless latest_id.nil? then
     latest_blog = result.select{|records| records['id'] == latest_id.to_s}.first

     @html = markdown.render(latest_blog['content'])
     @title = latest_blog['title']
     @date = latest_blog['post_date']
     @time = latest_blog['post_time']
     @id   = latest_blog['id']

     second_id = latest_id - 1 #なぜかlatest_idがstringになってしまっているため、Integerに戻さないと計算できない。（バグ）
     second_blog = result.select{|records| records['id'] == second_id.to_s}.first
  end

   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
     @id2   = second_blog['id']

   end


     third_id = latest_id - 2
     third_blog = result.select{|records| records['id'] == third_id.to_s}.first

   unless second_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
     @id3   = third_blog['id']

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

get '/edit/:id' do
  id = params[:id]

  connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
   connection.finish
   edit_blog = result.select{|records| records['id'] == id.to_s}.first

   @edit = true  #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
   @html = edit_blog['content']
   @title = edit_blog['title']
   @date = edit_blog['post_date']
   @time = edit_blog['post_time']
   @id   = edit_blog['id']

   erb :post
end


post '/resubmit/:id' do
     id = params[:id]
"ここでpost viewから送られてきたidのレコードを削除し、同じidで再インサートする。 編集するレコードのidは#{id}"
     @password = params[:password]
     @title = params[:title]
     @content = params[:content]

     connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
     result = connection.exec("DELETE FROM blogs WHERE id =#{id.to_i}")#パラメータのidを持つレコードを削除

     result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{id.to_i}')")#タイトルなどを入れなおして再インサート
end


get '/post' do
  @edit = false #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
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
     ids<<record['id'].to_i
     end

     latest_id = ids.max

     @new_id = latest_id+1


     result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{@new_id.to_i}')")


     redirect'/posted'
end

get '/*' do

     if params['splat'] == ["cancel"] then
       @status = "cancel"
     elsif params['splat'] == ["posted"] then
       @status = "posted"
     elsif params['splat'] == ["deleted"] then
       @status = "deleted"
     end

   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

     # データベースへのコネクションを切断する
     connection.finish

     ids = []
     result.each do |record|
     ids<<record['id'].to_i
     end
     latest_id = ids.max

     latest_blog = result.select{|records| records['id'] == latest_id.to_s}.first

     @html = markdown.render(latest_blog['content'])
     @title = latest_blog['title']
     @date = latest_blog['post_date']
     @time = latest_blog['post_time']
     @id   = latest_blog['id']

     second_id = latest_id - 1 #なぜかlatest_idがstringになってしまっているため、Integerに戻さないと計算できない。（バグ）
     second_blog = result.select{|records| records['id'] == second_id.to_s}.first

   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
     @id2   = second_blog['id']
   end


     third_id = latest_id - 2
     third_blog = result.select{|records| records['id'] == third_id.to_s}.first

   unless second_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
     @id3   = third_blog['id']
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