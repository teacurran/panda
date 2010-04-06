set(:user) { "prod" }
set(:domain) { "173.203.199.229" }
ssh_options[:port] = 45000
set :branch, "master"

set :immortalize_cmd, "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize" # note 2009.10
set :merb_env, 'staging' # For merb this will make little difference for this project...
set :merb_cmd, "/opt/ruby-enterprise-1.8.7-2009.10/bin/merb"
