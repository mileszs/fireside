class Object
  # list methods which aren't in superclass
  def blank?(obj = self)
    obj.nil? || obj.empty?
  end
end
