Things necessary for deployment to a server

Server:

  - Setup ssh
  - Install make
    1) sudo apt-get install make
  - Install git
    1) sudo apt-get install git
  - Install ruby
    1) sudo apt-get install ruby1.9.3
    2) sudo gem install rake
    3) sudo gem install bundler
  - Install/setup postgres
    1) sudo apt-get install postgresql
    2) sudo apt-get install libpq-dev
    3) Create db user
  - add deploy user
    1) sudo adduser deploy (adds both user and group as well as setting up users home dir)
    2) configure deploys authorized_keys in ~/.ssh
    3) sudo mkdir /var/rails
    4) sudo chown deploy:deploy /var/rails
  - Setup environment from client (note, capistrano/deploy needs to be set up in app at this point)
    1) bundle exec cap "#{environment}" deploy:setup
    2) move database.yml file to server
  - Install/setup nginx
    1) sudo apt-get install nginx
    2) create new config file for application in /etc/nginx/sites-available
    3) symlink config file to /etc/nginx/sites-enabled
    4) sudo chown deploy:deploy /var/rails

Client:

  - Setup capistrano
    1) capify .
    2) Add basic configurations to deploy.rb

    ```
    require 'bundler/capistrano'

    set :application, "app_name"
    set :repository, "git@..."
    set :scm, :git
    set :user, "deploy"
    set :deploy_via, :remote_cache #Investigate this more
    set :branch, "master" #not always the best option?
    set :keep_releases, 5

    #for password prompts from git
    default_run_options[:pty] = true
    #server should be setup so only deploy's permissions are needed
    set :use_sudo, false
    #for using local ssh keys
    ssh_options[:forward_agent] = true

    set :deploy_to "/var/rails/#{application}"

    task :production do
      set :rails_env, "production"
      server 'server_domain_goes_here', :app, :web, :db, :primary => true
    end

    namespace :deploy do
      desc "create shared directories"
      task :create_shared do
        run "mkdir -p #{shared_path}/tmp/pids"
        run "mkdir -p #{shared_path}/tmp/cache"
        run "mkdir -p #{shared_path}/tmp/sockets"
        run "mkdir -p #{shared_path}/tmp/sessions"
        run "mkdir -p #{shared_path}/config"
      end

      desc "make symlinks for shared resources"
      task :shared_symlink do
        run "ln -nfs #{shared_path}/log #{release_path}/log"
        run "rm -r #{release_path}/tmp"
        run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      end
    end

    after "deploy:create_symlink", "deploy:shared_symlink"
    after "deploy:setup", "deploy:create_shared"
    ```
