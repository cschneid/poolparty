class Symbol
  def to_string(pre="")
    "#{pre}#{self.to_s}"
  end
  def sanitize
    self.to_s.sanitize
  end
end