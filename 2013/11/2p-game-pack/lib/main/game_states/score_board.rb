require_relative '../game_pack'
require_relative 'super_game_state'

module GamePack2P
  class ScoreBoard < SuperGameState
    def initialize
      super
      status = round.duration.status_message
      unless round.is_over
        info_msg = '(Enter for next game)'
        if p1.wins > p2.wins
          msg = "P1 is leading by #{p1.wins - p2.wins} with #{p1.wins} wins!"
        elsif p2.wins > p1.wins
          msg = "P2 is leading by #{p2.wins - p1.wins} with #{p2.wins} wins!"
        else
          msg = "P1 and P2 are tied at #{p1.wins} each!"
        end
      else
        info_msg = '(Enter to return to menu)'
        if p1.wins > p2.wins
          msg = 'P1 wins the round!'
        elsif p2.wins > p1.wins
          msg = 'P2 wins the round!'
        else
          msg = 'P1 and P2 are tied!'
        end
      end
      @popup = Chingu::Text.new(msg,
                                :factor_x => 5, :factor_y => 12,
                                :zorder => 55, :color => Gosu::Color::WHITE)
      @popup1 = Chingu::Text.new(info_msg,
                                 :factor_x => 5, :factor_y => 12,
                                 :zorder => 55, :color => Gosu::Color::WHITE)
      @popup2 = Chingu::Text.new(status,
                                 :factor_x => 5, :factor_y => 12,
                                 :zorder => 55, :color => Gosu::Color::WHITE)
    end

    def setup
      super
      @popup.x = $window.width/2 - (@popup.width / 2.0).round
      @popup.y = $window.height * 0.3 - (@popup.height / 2.0).round
      @popup1.x = $window.width/2 - (@popup1.width / 2.0).round
      @popup1.y = $window.height* 0.7 - (@popup1.height / 2.0).round
      @popup2.x = $window.width/2 - (@popup2.width / 2.0).round
      @popup2.y = $window.height* 0.5 - (@popup2.height / 2.0).round
    end

    def button_up(id)
      super(id)
      if id == Gosu::KbReturn
        unless round.is_over
          round.next_game
          $window.pop_game_state
          round.current_game.start
        end
      end
    end

    def draw
      super
      previous_game_state.draw # Draw prev game state onto screen (in this case our level)
      @popup.draw
      @popup1.draw
      @popup2.draw unless round.is_over
    end
  end
end