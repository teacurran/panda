class String
  def to_bool
    return true if self == true || self =~ /^true$/i
    return false if self == false || self.nil? || self =~ /^false$/i
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class NilClass
  def to_bool
    false
  end
end