class Hash
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def except(*keys)
    dup.except!(*keys)
  end
end