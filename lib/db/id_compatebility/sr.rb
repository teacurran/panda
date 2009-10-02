# In SimpleDB, Mysql and Sqlite we use key as the attribute for uniquely identifying records. In ActiveRecord we have a key attribute in the tables. In SimpleDB we use the id which is already a UUID.

class SimpleRecord::Base
  def key
    self.id
  end
  
  def key=(v)
    self.id = v
  end
end