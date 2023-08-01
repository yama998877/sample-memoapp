require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'rack/utils'
set :enviroment, :production

# def store_name(filename, title, datail)
#   File.open(filename, 'a+') do |file|
#     file.puts(title, datail)
#   end
# end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def save_memo(filename, data)
  File.open(filename, 'w') do |file|
    file.puts(data)
  end
  File.open(filename).close
end

def read_memo
# ファイルがあるか確認して一覧表示する
  return [] unless Dir.exist?('./database')

  Dir.open('./database').each_child do |f|
    File.read("./database/#{f}").split
  end
end

get '/' do
  print "\e[32m"
  print "\e[0m"

  json_files = []
  @memo_path = Dir.children('./database/').sort_by { |f| File.mtime("./database/#{f}") }
  @memo_path.each do |file|
    json_files << File.read("./database/#{file}")
  end

  hashs = []
  json_files.each do |json|
    hashs << JSON.parse(json)
  end

  @titles = []
  hashs.each do |t|
    @titles << h(t['title'])
  end
  p @url_titles = @memo_path.zip(@titles) # URLとメモのタイトルを同じ配列に入れる
  erb :index
end

post '/' do
  print "\e[32m"
  p params['test']
  p params

  p JSON.dump(params)
  p '------------'
  p h(params).to_json
  p h(params)
  p
  p params.to_json
  p @title = params['title'].class
  p @detail = params['detail']
  save_memo("./database/#{SecureRandom.uuid}.json", h(params).to_json)
  @names = read_memo
  @memo_path = Dir.children('./database/').sort_by{ |f| File.mtime("./database/#{f}") }
  print "\e[0m"
  redirect '/'
  erb :index
end

patch '/' do
  p params
  p params['title']
  p params['detail']
  p params['json']
  p params.slice('title', 'detail').to_json
  p update_file = params['json']
  p changing_content = params.slice('title', 'detail').to_json
  save_memo("./database/#{update_file}", changing_content)

  redirect '/'
end

delete '/' do
  print "\e[31m"
  p params
  p delete_file = params['json']
  p File.delete("./database/#{delete_file}")
  p '削除しました！削除しました！'
  print "\e[0m"
  redirect '/'
end

get '/new' do
  erb :new
end

get '/:file' do
  @json_file = params[:file]
  Dir.children('./database/').include?(@json_file)
    p @json_file.to_json
    p @memo_detail = JSON.parse(File.read("./database/#{@json_file}"))
    p @memo_detail['title']
    p @memo_detail['detail'].gsub(/\r\n/, '<br>')
  erb :detail
end

get '/new/:file' do
  p @file_name = params[:file]
  p @memo = JSON.parse(File.read("./database/#{@file_name}"))
  p @memo['title']
  p @memo['detail']
  erb :new_detail
end

not_found do
  '404 Not Found'
end
