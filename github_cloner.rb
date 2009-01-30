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
	repo_name = push["repository"]["name"]
	repo_url = push["repository"]["url"].gsub(/^http\:\/\//, "git://")
	local_clone = File.join(CLONE_DIR, repo_name)
	log.info "Received post-receive hook for repo: #{repo_name}"
	
	if FileTest.exist?(local_clone)
		log.info "Clone exists, pulling latest from Github..."
		clone = Git.open(local_clone)
		clone.chdir do
			clone.pull('origin', 'master')
		end
	else
		log.info "Cloning #{repo_url} to #{local_clone}"
		clone = Git.clone(repo_url, local_clone)
	end
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