require 'sinatra'
require 'pg'
require 'redcarpet'
require 'pry'
require 'rails'


markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

get '/category/:id/:page' do
   category_id = params[:id]
   page_num = params[:page]

   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")
   categories = connection.exec("SELECT * FROM categories")
   @categories_array = []

   categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}"}
      @categories_array << hash
   end

#そのカテゴリーに属する記事を取得
   category_blog = result.select{|records| records['category_id'] == category_id}

   @html = markdown.render(category_blog[0]['content'])
   @title = category_blog[0]['title']
   @date = category_blog[0]['post_date']
   @time = category_blog[0]['post_time']
   @id   = category_blog[0]['id']

  if category_blog.length > 1 then
   @html2 = markdown.render(category_blog[1]['content'])
   @title2 = category_blog[1]['title']
   @date2 = category_blog[1]['post_date']
   @time2 = category_blog[1]['post_time']
   @id2   = category_blog[1]['id']
  end

  if category_blog.length > 2 then
   @html3 = markdown.render(category_blog[2]['content'])
   @title3 = category_blog[2]['title']
   @date3 = category_blog[2]['post_date']
   @time3 = category_blog[2]['post_time']
   @id3   = category_blog[2]['id']
  end

erb :home

end


get '/oldpost/:number' do


    connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
    result = connection.exec("SELECT * FROM blogs")
    categories = connection.exec("SELECT * FROM categories")

    @categories_array = []

    categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}"}
      @categories_array << hash
    end

     # データベースへのコネクションを切断する
     connection.finish

     ids = []

     result.each do |record|
        ids<<record['id'].to_i
     end

     smallest_id = ids.min

     latest_id = params[:number].to_i #urlに組み込んだパラメータが次のページの最初の記事のidになっている。

  unless latest_id.nil? then
     latest_blog = result.select{|records| records['id'] == latest_id.to_s}.first

     @html = markdown.render(latest_blog['content'])
     @title = latest_blog['title']
     @date = latest_blog['post_date']
     @time = latest_blog['post_time']
     @id   = latest_blog['id']


   unless latest_id == smallest_id then#この記事のidがデータベースで一番小さければ検索はやめる。

      second_id = latest_id - 1
      second_blog = result.select{|records| records['id'] == second_id.to_s}.first

      while second_blog == nil do
        second_id = second_id - 1
        second_blog = result.select{|records| records['id'] == second_id.to_s}.first
      end

   end

  end


   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
     @id2   = second_blog['id']

     unless second_id == smallest_id or second_id == nil then#この記事のidがデータベースで一番大きければ検索はやめる。

        third_id = second_id - 1
        third_blog = result.select{|records| records['id'] == third_id.to_s}.first

        while third_blog == nil do
          third_id = third_id - 1
          third_blog = result.select{|records| records['id'] == third_id.to_s}.first
        end

     end

   end


   unless third_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
     @id3   = third_blog['id']
   end

   @backnumber_link = false


   unless third_id == smallest_id or third_id == nil then #この記事のidがデータベースで一番大きければ検索はやめる。

       fourth_id = third_id.to_i - 1
       fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first

      while fourth_blog == nil do
         fourth_id = fourth_id - 1
         fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first
      end

      @backnumber_link = true
      @link = "/oldpost/#{fourth_id}"

   end

    erb :home
end

get '/edit/:id' do

  id = params[:id]

   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs")

   @all_categories = connection.exec("SELECT * FROM categories")

     # データベースへのコネクションを切断する
   connection.finish
   edit_blog = result.select{|records| records['id'] == id.to_s}.first

   @edit = true  #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
   @html = edit_blog['content']
   @title = edit_blog['title']
   @date = edit_blog['post_date']
   @time = edit_blog['post_time']
   @id   = edit_blog['id']
   @category_id = edit_blog['category_id']

   erb :post
end


post '/resubmit/:id' do

     delete = params[:Delete]
     id = params[:id]
     @password = params[:password]
     @title = params[:title]
     @content = params[:content]

     if @password == "swinhiroki" then

         connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
         result = connection.exec("DELETE FROM blogs WHERE id =#{id.to_i}")#パラメータのidを持つレコードを削除

         unless params[:delete] == "delete" then
            result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{id.to_i}')")#タイトルなどを入れなおして再インサート
            redirect'/posted'
         end

         redirect '/deleted'

     else
       @incorrect_pw = true
       @edit = true  #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
       @html = @content
       @title = @title
       @id   = params[:id]
       erb :post
     end
end


get '/post' do
  @edit = false #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
  connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
  @all_categories = connection.exec("SELECT * FROM categories")
  erb :post
end

post '/submit' do

     @password = params[:password]
     @title = params[:title]
     @content = params[:content]
     @category = params[:category]

     if @password == "swinhiroki" then

         connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
         result = connection.exec("SELECT * FROM blogs")

         # データベースへのコネクションを切断する
         ids = []
         result.each do |record|
           ids<<record['id'].to_i
         end

         latest_id = ids.max
         @new_id = latest_id+1


         result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{@new_id.to_i}','#{@category}')")
         redirect'/posted'
     else
         @incorrect_pw = true
         @edit = false  #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
         @html = @content
         @title = @title
         erb :post
     end
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
   categories = connection.exec("SELECT * FROM categories")


   @categories_array = []
   categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}"}
      @categories_array << hash
   end


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


     while second_blog == nil do
      second_id = second_id - 1
      second_blog = result.select{|records| records['id'] == second_id.to_s}.first
     end

   unless second_blog.nil? then
     @html2 = markdown.render(second_blog['content'])
     @title2 = second_blog['title']
     @date2 = second_blog['post_date']
     @time2 = second_blog['post_time']
     @id2   = second_blog['id']
   end


     third_id = second_id - 1
     third_blog = result.select{|records| records['id'] == third_id.to_s}.first

     while third_blog == nil do
      third_id = third_id - 1
      third_blog = result.select{|records| records['id'] == third_id.to_s}.first
     end

   unless third_blog.nil? then
     @html3 = markdown.render(third_blog['content'])
     @title3 = third_blog['title']
     @date3 = third_blog['post_date']
     @time3 = third_blog['post_time']
     @id3   = third_blog['id']
   end

   fourth_id = third_id - 1
   fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first

    while fourth_blog == nil do
      fourth_id = fourth_id - 1
      fourth_blog = result.select{|records| records['id'] == fourth_id.to_s}.first
    end

   @backnumber_link = false

    unless fourth_blog.nil? then
        @backnumber_link = true
        @link = "/oldpost/#{fourth_id}"
    end

    erb :home
end