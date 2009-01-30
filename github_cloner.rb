%w(logger pathname rubygems haml sass json git).each {|lib| require lib }
require 'sinatra'

configure do
	CLONE_DIR = "/home/mike/Development"
	LOGFILE = "log/cloner.log"
end

get '/' do
	@log = Pathname.new(LOGFILE).read
	erb :index
end

get '/test' do
	push = JSON.parse(File.open("test/test.json", "r") {|f| f.read })
	push['repository'].inspect
end

post '/raw_capture' do
	push = JSON.parse(params[:payload])
	data = {"push" => push }
	TEST_LOG.open("a") do |file|
		file.write(data.to_yaml)
	end
end

post '/clone' do
	log = Logger.new(LOGFILE, 'weekly')
	push = JSON.parse(params[:payload])
	repo_url = push["repository"]["url"].gsub(/^http\:\/\//, "git://")
	
	log.info "Received post-receive hook for repo: #{push["repository"]["name"]}"
	
end

get "/sass/:format/:file" do
	content_type 'text/css', :charset => 'utf-8'
	if params[:file] =~ /\.sass$/
		@file = Pathname.new("./views/sass/" + params[:file])
	else
		@file = Pathname.new("./views/sass/" + (params[:file] + ".sass"))
	end

	if @file.exist?
		@format = params[:format].intern
		@sass = Sass::Engine.new(@file.read, {:style => @format})
		@sass.render
	else
		raise not_found, "Sass stylesheet not found."
	end
end