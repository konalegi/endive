class String
  def camelize
    self.split("_").each {|s| s.capitalize! }.join("")
  end

  def camelize!
    self.replace(self.split("_").each {|s| s.capitalize! }.join(""))
  end

  def underscore
    self.scan(/[A-Z][a-z]*/).join("_").downcase
  end

  def underscore!
    self.replace(self.scan(/[A-Z][a-z]*/).join("_").downcase)
  end
end