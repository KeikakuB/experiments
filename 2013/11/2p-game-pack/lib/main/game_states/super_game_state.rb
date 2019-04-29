require 'rubygems'
require 'gosu'
require 'chingu'

module GamePack2P
  class SuperGameState < Chingu::GameState
    def round
      GamePack.instance.round
    end

    def p1
      GamePack.instance.p1
    end

    def p2
      GamePack.instance.p2
    end
  end
end