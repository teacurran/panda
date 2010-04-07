set(:user) { "prod" }
set(:domain) { 
  # ec2-174-129-132-36.compute-1.amazonaws.com
  "panda.iremix.org" 
}
ssh_options[:port] = 45001
set :branch, "master"

set :immortalize_cmd, "/opt/ruby-enterprise-1.8.7-2010.01/bin/immortalize" # note 2010.01
set :merb_env, 'production' # For merb this will make little difference for this project...
set :merb_cmd, "/opt/ruby-enterprise-1.8.7-2010.01/bin/merb"
