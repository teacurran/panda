set(:user) { "prod" }
set(:domain) { 
  # ec2-174-129-132-36.compute-1.amazonaws.com
  "panda.iremix.org" 
}
ssh_options[:port] = 45001
set :branch, "master"
# For merb this will make little difference for this project...
set :merb_env, 'production'
