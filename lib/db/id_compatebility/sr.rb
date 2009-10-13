# In SimpleDB, Mysql and Sqlite we use key as the attribute for uniquely identifying records. In ActiveRecord we have a key attribute in the tables. In SimpleDB we use the id which is already a UUID.

module SimpleRecord
  class Base
    def key
      self.id
    end
  
    def key=(v)
      self.id = v
    end
  
    def to_json
      fixed_attributes.to_json
    end
  
    def fixed_attributes
      fixed_attributes = {}
      @attributes.each {|k,v| fixed_attributes[k] = send(k) }
      return fixed_attributes
    end
  end
  
  class ResultsArray
    def to_json
      items.map {|i| i.fixed_attributes}.to_json
    end
  end
end