class Object
  def blank?(obj = self)
    obj.nil? || obj.empty?
  end
end
class Fixnum
  def blank?
    false
  end
end

class Float
  # list methods which aren't in superclass
  def blank?
    false
  end
end
