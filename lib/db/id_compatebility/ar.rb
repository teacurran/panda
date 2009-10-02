class ActiveRecord::Base
  before_create :set_key
  
  def set_key
    self.key = UUID.new.generate
  end
end