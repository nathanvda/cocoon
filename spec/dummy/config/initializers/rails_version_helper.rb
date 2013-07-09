module Rails

  def self.rails4?
    Rails.version.start_with? '4'
  end
end