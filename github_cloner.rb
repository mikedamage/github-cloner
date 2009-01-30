%w(logger pathname rubygems haml sass json git).each {|lib| require lib }
require 'sinatra'

configure do
	
end

get '/' do
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
	push = JSON.parse(params[:payload])
end

# = Sinatra Action: Sass Stylesheet Compressor/Renderer
#
# == Summary
# Renders Sass stylesheets in the specified format.
# Valid formats are: extended, expanded, compact, compressed
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