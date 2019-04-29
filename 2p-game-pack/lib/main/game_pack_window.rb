require 'rubygems'
require 'gosu'
require 'chingu'

module GamePack2P
  class GamePackWindow < Chingu::Window
    def initialize(width, height, fullscreen = false)
      super(width, height, fullscreen)
    end
  end
end