set(:user) { "prod" }
set(:domain) { "173.203.199.229" }
ssh_options[:port] = 45000
set :branch, "master"
# For merb this will make little difference for this project...
set :merb_env, 'staging'
