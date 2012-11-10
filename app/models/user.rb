class User < AWS::Record::Base

  set_domain_name Panda::Application.config.sdb_users_domain
  string_attr :password
  string_attr :email
  string_attr :salt
  string_attr :crypted_password
  string_attr :api_key
  string_attr :updated_at
  string_attr :created_at

  attr_accessor :password, :password_confirmation
  
  def login
    id
  end

  def login=(v)
    id = v
  end

  def self.authenticate(login, password)
    begin
      u = self.find(login) # Login is the key of the SimpleDB object
    rescue
      return nil
    else
      puts "#{u.crypted_password} | #{encrypt(password, u.salt)}"
      u && (u.crypted_password == encrypt(password, u.salt)) ? u : nil
    end
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def set_password(password)
    return if password.blank?
    salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.key}--")
    self.salt = salt
    self.crypted_password = self.class.encrypt(password, salt)
  end
end