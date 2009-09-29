case Panda::Config[:database]
when :simpledb
  class Profile < SimpleRecord::Base
    has_ints :width, :height
    has_attributes :category, :title, :extname, :command
    has_dates :updated_at, :created_at
  end
when :mysql
  class Profile < ActiveRecord::Base
  end
end

class Profile
  
end