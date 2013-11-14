require File.expand_path('ui.rb', File.dirname(__FILE__))

desc "Initializes the working copy"
task :bootstrap do

  title "Updating submodules"
  sh 'git submodule update --init --recursive'

  title "Installing gem bundle"
  sh 'bundle install'
end

desc "Prepares the working copy"
task :pull do

  title "Pulling submodules"
  sh "git submodule foreach git pull origin master"

  title "Installing gem bundle"
  sh 'bundle install'
end
