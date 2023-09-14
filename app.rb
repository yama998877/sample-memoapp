# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'rack/utils'
set :enviroment, :production

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def save_memo(filename, data)
  File.open(filename, 'w') do |file|
    file.puts(data)
  end
  # File.open(filename).close
end

def read_memo
  # ファイルがあるか確認して一覧表示する
  return [] unless Dir.exist?('./database')

  Dir.open('./database').each_child do |f|
    File.read("./database/#{f}").split
  end
end

get '/' do
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
    @titles << t['title']
  end
  @url_titles = @memo_path.zip(@titles) # URLとメモのタイトルを同じ配列に入れる
  erb :index
end

post '/' do
  memo_hash = {}
  @title = params['title']
  @title << 'タイトルがありません' if @title.strip.empty?
  memo_hash['title'] = h(params['title'])
  memo_hash['detail'] = h(params['detail'])
  save_memo("./database/#{SecureRandom.uuid}.json", memo_hash.to_json)
  @names = read_memo
  @memo_path = Dir.children('./database/').sort_by { |f| File.mtime("./database/#{f}") }
  redirect '/'
  erb :index
end

patch '/' do
  new_memo_hash = {}
  params['title'] << 'タイトルがありません' if params['title'].strip.empty?
  new_memo_hash['title'] = h(params['title'])
  new_memo_hash['detail'] = h(params['detail'])
  update_file = params['json']
  changing_content = new_memo_hash.to_json
  save_memo("./database/#{update_file}", changing_content)

  redirect '/'
end

delete '/' do
  params
  delete_file = params['json']
  File.delete("./database/#{delete_file}")
  redirect '/'
end

get '/new' do
  erb :new
end

get '/:file' do
  @json_file = params[:file]
  Dir.children('./database/').include?(@json_file)
  @json_file.to_json
  @memo_detail = JSON.parse(File.read("./database/#{@json_file}"))
  @memo_detail['title']
  erb :detail
end

get '/new/:file' do
  @file_name = params[:file]
  @memo = JSON.parse(File.read("./database/#{@file_name}"))
  @memo['title']
  @memo['detail']
  erb :new_detail
end

not_found do
  '404 Not Found'
end
