class ActiveRecord::Base
  set_primary_key "key"
  before_create :set_key
  
  set_create_column :create
  set_update_column :update
  
  def set_key
    self.key = UUID.new.generate
  end
end