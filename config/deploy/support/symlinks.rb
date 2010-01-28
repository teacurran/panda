set :symlinks, []

namespace :deploy do
  desc "Symlinks all entries in symlinks from \#{shared_path}/\#{symlink} to \#{current_path}/\#{symlink}."
  task :symlink_extras, :except => { :no_release => true } do
    if symlinks.is_a?(Array)
      symlinks.each do |symlink|
        run "rm -f #{current_path}/#{symlink} && ln -nfs #{shared_path}/#{symlink} #{current_path}/#{symlink}"
      end 
    elsif symlinks.is_a?(Hash)
      symlinks.each_pair do |target, dest|
        run "rm -f #{current_path}/#{dest} && ln -nfs #{shared_path}/#{target} #{current_path}/#{dest}"
      end
    else
      raise "symlink must be set to an Array or Hash"
    end
  end
  after "deploy:symlink", "deploy:symlink_extras"
end
