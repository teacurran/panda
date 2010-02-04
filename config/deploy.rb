Dir['config/deploy/support/**/*'].each { |f| eval IO.read(f) }

## multistage
set :stages, %w(staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :application, "rw-panda"
set :repository,  "git@github.com:dyn/panda.git"
set(:deploy_to) { "/home/#{user}/public_html/#{application}" }
set :deploy_via, :remote_cache

set :symlinks, {
  "config/panda_init.rb" => "config/panda_init.rb",
  "config/mailer.rb" => "config/mailer.rb",
  "config/error_messages.yml" => "config/error_messages.yml"
}

set :use_sudo, false

## ssh options
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

## source control
set :branch, "master"
set :git_enable_submodules, 1
set :revision, ENV['REV'] || 'HEAD'
set :scm, "git"
set :scm_verbose, true

after "deploy:setup", "create_shared_config"
after "deploy:update", "deploy:install_gems"
after "deploy:update", "deploy:bootstrap"

role(:app) { domain }
role(:web) { domain }
role(:db, :primary => true) { domain }

# mac os x issues
on(:start) { `ssh-add` }
