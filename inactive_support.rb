class Object
  # list methods which aren't in superclass
  def blank?(obj = self)
    obj.nil? || obj.empty?
  end
end
class Fixnum
  # list methods which aren't in superclass
  def blank?
    false
  end
end
