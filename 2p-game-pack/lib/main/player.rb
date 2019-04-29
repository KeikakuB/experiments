require 'forwardable'

module GamePack2P
  class Player
    extend Forwardable

    attr_accessor :wins
    def_delegators :@settings, :color, :controls

    def initialize(settings)
      @settings = settings
      @wins = 0
    end
  end
end