require 'singleton'
require 'gosu'
require 'chingu'

require_relative 'settings'
require_relative 'player'
require_relative 'round'
require_relative 'game_pack_window'

module GamePack2P
  module GameResult
    P1_WIN = 1
    P2_WIN = 2
    TIE = 3
  end

  class GamePack
    SCREEN_WIDTH = 640 * 2
    SCREEN_HEIGHT = 480 * 2
    include Singleton

    attr_accessor :window, :p1, :p2, :round

    def initialize
      @width = SCREEN_WIDTH
      @height = SCREEN_HEIGHT
      @p1 = Player.new(Settings.new(Gosu::Color::GREEN, {:left_key => :a, :right_key => :d, :up_key => :w, :down_key => :s}))
      @p2 = Player.new(Settings.new(Gosu::Color::BLUE, {:left_key => :left, :right_key => :right, :up_key => :up, :down_key => :down}))
      @round = Round.new
      @window = GamePackWindow.new(@width, @height, false)
    end

    def set_new_round(games, duration)
      @round.setup_round(games, duration)
    end

    def play(game_state)
      @window.push_game_state(game_state)
      @window.show
    end

    def game_over(result, time_spent_in_ms)
      case result
        when GameResult::P1_WIN then
          @p1.wins += 1
        when GameResult::P2_WIN then
          @p2.wins += 1
        when GameResult::TIE then
          #no change?
      end
      max_wins = [@p1.wins, @p2.wins].max
      @round.stats.set_current_wins max_wins if @round.stats.current_wins < max_wins
      @round.stats.increment_games_played
      @round.stats.increase_time_played_by time_spent_in_ms
      @round.current_game.end
    end
  end
end