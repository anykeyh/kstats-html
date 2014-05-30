set :application, "kstats-html"

set :repository,  "https://github.com/anykeyh/kstats-html.git"
set :branch, "master"

set :git_enable_submodules, 1

set :rvm_type, :system
set :rvm_ruby_string, "2.0.0@#{application}"
set :rvm_path_source, "/usr/local/rvm/bin/rvm"
set :rvm_path, "/usr/local/rvm"

ssh_options[:forward_agent] = true
set :default_shell, '/bin/bash -l'
set :use_sudo, false
set :user, "www-data"

set :deploy_to, "/var/www/#{application}"

role :web, "kosmogo.tv"                          # Your HTTP server, Apache/etc
role :app, "kosmogo.tv"                          # This may be the same as your `Web` server
role :db,  "kosmogo.tv", :primary => true # This is where Rails migrations will run
role :db,  "kosmogo.tv"

def rb_exec cmd
  run "source #{rvm_path_source} && cd #{release_path} && #{cmd}"
end

task :configure, :roles => :web do
  %w(config sockets log pids).each do |dir|
    run "test -e #{shared_path}/#{dir} || mkdir -p #{shared_path}/#{dir}"
  end

  run "rm -rf #{current_release}/log; ln -s #{shared_path}/log #{current_release}/log"

  capture("ls -1 #{shared_path}/config/").split(/\n/).each do |file|
    filename = file.split(/\//)[-1]
    run("rm -f #{current_release}/config/#{filename} ; ln -s #{shared_path}/config/#{filename} #{current_release}/config/#{filename}")
  end

  run "test -e #{shared_path}/bundler_gems || mkdir -p #{shared_path}/bundler_gems"
  run "rm -f #{current_release}/.bundle  ; ln -s #{shared_path}/bundler_gems #{current_release}/.bundle"

  rb_exec([
    "bundle install",
    "--gemfile #{release_path}/Gemfile",
    "--path #{shared_path}/bundler_gems",
    "--deployment",
    "--without development test",
    ].join(" "))
end


namespace :deploy do
  desc "Start unicorn"
  task :start do
    run "source #{rvm_path_source} && cd #{release_path} && bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end

  desc "Stop unicorn"
  task :stop do
    run "source #{rvm_path_source} && cd #{release_path} && kill -QUIT `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc "Restart unicorn"
  task :restart do
    run "test -e #{shared_path}/pids/unicorn.pid && (source #{rvm_path_source} && cd #{release_path} && kill -QUIT `cat #{shared_path}/pids/unicorn.pid`); true"
    run "source #{rvm_path_source} && cd #{release_path} && bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end
end

after 'deploy:update_code', :configure
after 'deploy:update_code', 'deploy:compile_assets'
after 'deploy:update_code', 'deploy:migrate'
after 'deploy:restart', 'deploy:cleanup'


namespace :deploy do
  task :migrate, :roles => :db do
    rake 'db:migrate'
  end

  task :seed, :roles => :db do
    rake 'db:seed'

  end

  task :compile_assets do
    rake 'assets:clean'
    rake 'assets:precompile'
  end
end

def rake(task)
  run [
    "source #{rvm_path_source} &&",
    "cd #{release_path} &&",
    "RAILS_ENV=production rake #{task}",
  ].join(" ")
end