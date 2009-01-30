require 'rubygems'
require 'rack'
require 'sinatra'

set :env, :production
disable :run

require 'github_cloner'

run Sinatra.application