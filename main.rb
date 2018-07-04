require 'sinatra'
require 'pg'
require 'redcarpet'
require 'pry'

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)


post '/comment/:id' do
   post_id = params[:id].to_i
   comment = params[:comment]
   user = params[:user]
   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM comments")

   ids = []
   result.each do |record|
     ids<<record['id'].to_i
   end

   new_id = ids.max + 1

   unless comment.nil? and user.nil?
         result = connection.exec("INSERT INTO comments VALUES('#{post_id}','#{comment}','#{user}',current_time(0),current_date,'#{new_id}')")
         redirect'/posted'
   else
         redirect'/'#フォームの入力が完全でない場合redirect先のフォームに入れておいた文字をパラメータに渡す。
   end
end

get '/category/:id/:page' do
   category_id = params[:id].to_i
   page_num = params[:page].to_i

   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs ORDER BY id DESC")
   categories = connection.exec("SELECT * FROM categories")
   @categories_array = []

   categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}","id" => "#{category['id']}"}
      @categories_array << hash
   end

#そのカテゴリーに属する記事を取得
       category_blog = result.select{|records| records['category_id'] == category_id.to_s}

    #ページネーションが1以上だった時の処理。
       @category_title = "カテゴリ: #{categories.select{|records| records['id'] == category_id.to_s}.first['category']}"



       @html = markdown.render(category_blog[3 * page_num]['content'])
       @title = category_blog[3 * page_num]['title']
       @date = category_blog[3 * page_num]['post_date']
       @time = category_blog[3 * page_num]['post_time']
       @id   = category_blog[3 * page_num]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments = comments_all.select{|records| records['post_id'] == @id.to_s}

      if category_blog.length - 1 > 3 * page_num  then
       @html2 = markdown.render(category_blog[3*page_num + 1]['content'])
       @title2 = category_blog[3 * page_num + 1]['title']
       @date2 = category_blog[3 * page_num + 1]['post_date']
       @time2 = category_blog[3 * page_num + 1]['post_time']
       @id2   = category_blog[3 * page_num + 1]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments2 = comments_all.select{|records| records['post_id'] == @id2.to_s}
      end

      if category_blog.length - 1 > 3 * page_num + 2 then
       @html3 = markdown.render(category_blog[3 * page_num + 2]['content'])
       @title3 = category_blog[3 * page_num + 2]['title']
       @date3 = category_blog[3 * page_num + 2]['post_date']
       @time3 = category_blog[3 * page_num + 2]['post_time']
       @id3   = category_blog[3 * page_num + 2]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments3 = comments_all.select{|records| records['post_id'] == @id3.to_s}
      end

      if category_blog.length - 1 > 3*page_num + 3 then
       @backnumber_link = true
       @link = "/category/#{category_id}/#{page_num+1}"
      end

      if page_num > 0 then
        @fowerd_link = "/oldpost/#{page_num-1}"
      end

connection.finish
erb :home

end


get '/oldpost/:number' do

    page_num = params[:number].to_i

    connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
    result = connection.exec("SELECT * FROM blogs ORDER BY id DESC")
    categories = connection.exec("SELECT * FROM categories")

    @categories_array = []

    categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}","id" => "#{category['id']}"}
      @categories_array << hash
    end

       @html = markdown.render(result[3 * page_num]['content'])
       @title = result[3 * page_num]['title']
       @date = result[3 * page_num]['post_date']
       @time = result[3 * page_num]['post_time']
       @id   = result[3 * page_num]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments = comments_all.select{|records| records['post_id'] == @id.to_s}

        ids = []
        result.each do |record|
          ids<<record['id'].to_i
        end


      if ids.length - 1 > 3 * page_num  then   #result.lengthが使えないので、代わりにidの個数を長さとして扱う
       @html2 = markdown.render(result[3*page_num + 1]['content'])
       @title2 = result[3 * page_num + 1]['title']
       @date2 = result[3 * page_num + 1]['post_date']
       @time2 = result[3 * page_num + 1]['post_time']
       @id2   = result[3 * page_num + 1]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments2 = comments_all.select{|records| records['post_id'] == @id2.to_s}
      end

      if ids.length - 1 > 3 * page_num + 2 then
       @html3 = markdown.render(result[3 * page_num + 2]['content'])
       @title3 = result[3 * page_num + 2]['title']
       @date3 = result[3 * page_num + 2]['post_date']
       @time3 = result[3 * page_num + 2]['post_time']
       @id3   = result[3 * page_num + 2]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments3 = comments_all.select{|records| records['post_id'] == @id3.to_s}
      end

      if ids.length - 1 > 3*page_num + 3 then
       @backnumber_link = true
       @link = "/oldpost/#{page_num+1}"
      end

      if page_num > 0 then
        @fowerd_link = "/oldpost/#{page_num-1}"
      end

    connection.finish
    erb :home
end



get '/edit/:id' do

  id = params[:id]

   connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
   result = connection.exec("SELECT * FROM blogs ORDER BY id DESC")

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
     @category = params[:category]

     if @password == "swinhiroki" then

         connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
         result = connection.exec("DELETE FROM blogs WHERE id =#{id.to_i}")#パラメータのidを持つレコードを削除

         unless params[:delete] == "delete" then
            result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{id.to_i}','#{@category}')")#タイトルなどを入れなおして再インサート
            redirect'/posted'
         end

         redirect '/deleted'

     else
       connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
       @all_categories = connection.exec("SELECT * FROM categories")

       @incorrect_pw = true
       @edit = true  #editと新規投稿は同じhtmlを用いるので判別用にbooleanの変数をviewに送っておく。
       @html = @content
       @title = @title
       @id   = params[:id]
       @category_id = params[:category]
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
     @image    = params[:image]

     image_file = @image[:tempfile]
     image_name = @image[:filename]

     if @password == "swinhiroki" then

         connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
         result = connection.exec("SELECT * FROM blogs")

         # データベースへのコネクションを切断する
         ids = []
         result.each do |record|
           ids<<record['id'].to_i
         end

         if ids.length == 0 then#この投稿が最初の投稿だった場合。
           @new_id = 0
         else
           latest_id = ids.max
           @new_id = latest_id+1
         end

         #画像の保存プロセス/ここから
         dirPath = "./public/img/#{@new_id}/"
         FileUtils.mkdir_p(dirPath) unless FileTest.exist?(dirPath)

         filePath = "./public/img/#{@new_id}/#{image_name}"
         open(filePath, 'w+b') do |output|
             output.write(image_file.read)
         end
         #画像の保存プロセス/ここまで

         #送信されたmarkdownの[image1]を実際の画像へのファイルパスに置き換える。
         @content.sub!("[image1]", "![image1](/img/#{@new_id}/#{image_name})")

         result = connection.exec("INSERT INTO blogs VALUES('#{@title}','#{@content}',current_date,current_time(0),'#{@new_id.to_i}','#{@category}')")
         redirect'/posted'
     else

         connection = PG::connect(:host => "localhost", :user => "postgres", :password => "takahama0613", :dbname => "blog",:port=>"5432")
         @all_categories = connection.exec("SELECT * FROM categories")

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

   result = connection.exec("SELECT * FROM blogs ORDER BY id DESC")
   categories = connection.exec("SELECT * FROM categories")


   @categories_array = []
   categories.each do |category|
      num_blogs = result.select{|records| records['category_id'] == category['id']}.length#このカテゴリーのidをもつレコ―ドの数を数える。
      hash = {}
      hash = {"count" => "#{num_blogs}", "name" => "#{category['category']}","id" => "#{category['id']}"}
      @categories_array << hash
   end

        page_num = 0

      ids = []

      unless result.nil?
        result.each do |record|
          ids<<record['id'].to_i
        end
      end

      unless ids.length == 0 then
       @html = markdown.render(result[3 * page_num]['content'])
       @title = result[3 * page_num]['title']
       @date = result[3 * page_num]['post_date']
       @time = result[3 * page_num]['post_time']
       @id   = result[3 * page_num]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments = comments_all.select{|records| records['post_id'] == @id.to_s}
      end


      if ids.length - 1 > 3 * page_num  then   #result.lengthが使えないので、代わりにidの個数を長さとして扱う
       @html2 = markdown.render(result[3*page_num + 1]['content'])
       @title2 = result[3 * page_num + 1]['title']
       @date2 = result[3 * page_num + 1]['post_date']
       @time2 = result[3 * page_num + 1]['post_time']
       @id2   = result[3 * page_num + 1]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments2 = comments_all.select{|records| records['post_id'] == @id2.to_s}
      end

      if ids.length - 1 > 3 * page_num + 2 then
       @html3 = markdown.render(result[3 * page_num + 2]['content'])
       @title3 = result[3 * page_num + 2]['title']
       @date3 = result[3 * page_num + 2]['post_date']
       @time3 = result[3 * page_num + 2]['post_time']
       @id3   = result[3 * page_num + 2]['id']
       comments_all = connection.exec("SELECT * FROM comments")
       @comments3 = comments_all.select{|records| records['post_id'] == @id3.to_s}
      end

      if ids.length - 1 > 3*page_num + 3 then
       @backnumber_link = true
       @link = "/oldpost/#{page_num+1}"
      end

     if page_num > 0 then
        @fowerd_link = "/oldpost/#{page_num-1}"
     end


    connection.finish
    erb :home

end