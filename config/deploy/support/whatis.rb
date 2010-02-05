namespace :whatis do
  task :current do
     stream "cd #{current_path}; echo ; git log -n1"
  end
end