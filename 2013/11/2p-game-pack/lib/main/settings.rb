class Settings
  attr_accessor :color, :controls

  def initialize(color, controls)
    @color = color
    @controls = controls
  end
end