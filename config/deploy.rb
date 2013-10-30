require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2-p290'
set :rvm_type, :system

require 'bundler/capistrano'
load 'deploy/assets'

require 'capistrano/ext/multistage'
set :stages, %w(production staging)
set :default_stage, "staging"

set :application, "gls_portal"
set :repository,  "git@github.com:wids-eria/gls_portal.git"
set :branch, "master"

set :scm, :git

set :user, :deploy
ssh_options[:forward_agent] = true

role :web, "terrordome.discovery.wisc.edu"
role :app, "terrordome.discovery.wisc.edu"
role :db,  "terrordome.discovery.wisc.edu", :primary => true # This is where Rails migrations will run

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :normalize_asset_timestamps, false

# CALLBACKS #########

after 'deploy:finalize_update', 'deploy:symlink_db'

namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  #task :cold do       # Overriding the default deploy:cold
  #  update
  #  load_schema       # My own step, replacing migrations.
  #  start
  #end
end