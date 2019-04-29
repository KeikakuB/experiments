require_relative 'stats'
require_relative 'game'
require_relative 'duration/wins_based_duration'

module GamePack2P
  class Round
    attr_accessor :stats, :duration, :current_game, :is_over

    def initialize
    end

    def setup_round(games, duration)
      @stats = GamePack2P::Stats.new(self) #stats should be update after every match
      @duration = duration
      @stats.add_observer(@duration)
      @games = games
      @current_game_index = 0
      @is_over = false
    end

    def current_game
      @games[@current_game_index]
    end

    def next_game
      raise if @is_over
      if @current_game_index == @games.length - 1
        @current_game_index = 0
      else
        @current_game_index += 1
      end
    end
  end
end