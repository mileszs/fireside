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
