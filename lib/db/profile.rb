case Panda::Config[:database]
when :simpledb
  class Profile < SimpleRecord::Base
    has_ints :width, :height
    has_attributes :category, :title, :extname, :command
  end
when :mysql
  class Profile < ActiveRecord::Base
  end
when :sqlite
  class Profile < ActiveRecord::Base
  end
end

class Profile
  
  def self.writeable_attributes
    [:width, :height, :category, :title, :extname, :command]
  end
end