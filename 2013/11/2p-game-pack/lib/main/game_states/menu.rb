require_relative '../game_pack'
require_relative 'super_game_state'

module GamePack2P
  class Menu < SuperGameState
    def initialize
      super
      @color = Gosu::Color::BLACK
      @popup = Chingu::Text.new('Press Enter to start playing!',
                                :x => 0, :y => 0,
                                :factor_x => 5, :factor_y => 12,
                                :zorder => 55, :color => Gosu::Color::WHITE)
    end

    def setup
      super
      @popup.x = $window.width/2 - (@popup.width / 2.0).round
      @popup.y = $window.height/2 - (@popup.height / 2.0).round
    end

    def button_up(id)
      super(id)
      if id == Gosu::KbReturn
        GamePack.instance.round.current_game.start
      end
    end

    def draw
      super
      @popup.draw
    end
  end
end