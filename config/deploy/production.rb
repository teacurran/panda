set(:user) { "prod" }
set(:domain) { "209.20.71.35" }
ssh_options[:port] = 45001
set :branch, "master"
# For merb this will make little difference for this project...
set :merb_env, 'production'
