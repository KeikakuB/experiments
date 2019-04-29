require_relative 'game_states/score_board'

module GamePack2P
  class Game
    attr_reader :gamestate

    def initialize(gamestate)
      @gamestate = gamestate
    end

    def start
      $window.push_game_state(@gamestate)
    end

    def end
      $window.push_game_state(ScoreBoard.new)
    end
  end
end