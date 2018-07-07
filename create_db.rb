require 'pg'
require 'dotenv'

Dotenv.load
correct_pw = ENV["password"]
db_host    = ENV["db_host"]
db_user    = ENV["db_user"]
db_pw      = ENV["db_pw"]
db_port    = ENV["db_port"].to_i

connection = PG::connect(:host => "#{db_host}", :user => "#{db_user}", :password => "#{db_pw}", :dbname => "blog2",:port=>"#{db_port}")

result1 = connection.exec("CREATE TABLE blogs (
    title           varchar(100),
    content         text,
    post_date       date,
    post_time       time,
    id              integer,
    category_id     integer
);")

p result1

result2 = connection.exec("CREATE TABLE categories (
    id              integer,
    category        varchar(100)
);")

p result2

result3 = connection.exec("CREATE TABLE comments (
    post_id          integer,
    comment          text,
    user_name        varchar(50),
    post_time        time,
    post_date        date,
    id               integer
);")


result5 = connection.exec("INSERT INTO categories VALUES('1','Ruby');")
result6 = connection.exec("INSERT INTO categories VALUES('2','GoLang');")
result7 = connection.exec("INSERT INTO categories VALUES('3','Java');")
result4 = connection.exec("INSERT INTO categories VALUES('0','未分類');")


