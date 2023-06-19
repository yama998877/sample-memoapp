require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pp'
require 'securerandom'
set :enviroment, :production

# def store_name(filename, title, datail)
#   File.open(filename, 'a+') do |file|
#     file.puts(title, datail)
#   end
# end

def store_name(filename, title, detail)
  File.open(filename, 'a+') do |file|
    file.puts(title, detail)
  end
  
end

def store_name2(filename, data)
  File.open(filename, 'a+') do |file|
    file.puts(data)
  end
  File.open(filename).close
end

def read_names
  return [] unless Dir.exist?('database')

  Dir.open('./database').each_child do |f|
    File.read("./database/#{f}").split
  end
  
end

get '/' do
  params
  @title = params['title']
  @detail = params['detail']
  @names = read_names
  json_files = []
  @memo_path = Dir.children('./database/').sort_by{ |f| File.mtime("./database/#{f}") }
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
  p @url_titles = @memo_path.zip(@titles)
  # store_name('names.txt', @email, @message)
  erb :index
end

post '/' do
  p params['test']
  # p "#{SecureRandom.uuid}.json"
  params
  JSON.dump(params)
  params.to_json.class
  @title = params['title']
  @detail = params['detail']
  store_name2("./database/#{SecureRandom.uuid}.json", params.to_json)
  @names = read_names
  pp @names
  @memo_path = Dir.children('./database/').sort_by{ |f| File.mtime("./database/#{f}") }
  #test----------

  json_files = []
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
  p @url_titles = @memo_path.zip(@titles)
  # @memo_path.each do |file|
  #   @titles << file
  #   hashs.each do |t|
  #     @titles << t['title']
  #   end
  # end
  # p @titles
  # hashs.each do |t|
  #   @titles << t['title']
  #   @memo_path.each do |file|
  #     @titles << file
  #   end
  # end
  redirect '/'
  erb :index
end

get '/new' do
  erb :new
end

get '/monstas' do
  p params
  p @name = params['name']
  p @names = read_names
  # store_name('names.txt', @name, @test)
  erb :monstas
end

post '/monstas' do
  p @name = params['name']
  # store_name('public/names.txt', @name, @test)
  redirect "/monstas?name=#{@name}"
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
  p params[:file]
  p 'aaaaaaaaaaaa'
end

not_found do
  '404 Not Found'
end

new_page = '/new'
#   erb :new
# get new_page  do
# end
get '/about' do

erb :about
end
post '/confirm' do

  @email = params[:email]
  @message = params[:message]
  @name = params[:name]
  p params
  p @email
  p @message
  erb :confirm
end


