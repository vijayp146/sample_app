require 'bundler/capistrano'

set :application, "sample_app"
set :repository, "git@github.com:AdamFerguson/sample_app.git"
set :scm, :git
set :user, "deploy"
set :deploy_via, :remote_cache
set :branch, "master"
set :keep_releases, 5

default_run_options[:pty] = true
set :use_sudo, false
ssh_options[:forward_agent] = true

set :deploy_to, "/var/rails/#{application}"

# role :web, "aws.adam-ferguson.com"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

task :production do
  set :rails_env, "production"
  server 'aws.adam-ferguson.com', :app, :web, :db, :primary => true
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
