case Panda::Config[:database]
when :simpledb
  class Profile < SimpleRecord::Base
    has_ints :width, :height
    has_attributes :category, :title, :extname, :command, :status
  end
when :mysql
  class Profile < ActiveRecord::Base
  end
when :sqlite
  class Profile < ActiveRecord::Base
  end
end

class Profile
  
  def self.find_all_enabled
    self.find(:all, :conditions => ["status != ?",'disabled'])
  end
  
  def encodings
    Encoding.find(:all, :conditions => ["profile_id = ?",self.id])
  end
end