require 'rubygems'
require 'git'

task :deploy do
	%x(rsync -avzr --exclude=.git ./ mike-server:Development/github-cloner/)
end

namespace :git do
	
	task :commit do
		repo = Git.open(File.dirname(__FILE__))
		print "Commit Message: "
		msg = $stdin.gets
		
		repo.chdir do
			repo.add
			repo.commit(msg)
		end
	end
	
	task :push do
		repo = Git.open(File.dirname(__FILE__))
		repo.chdir do
			repo.push('origin', 'master')
		end
	end
	
end