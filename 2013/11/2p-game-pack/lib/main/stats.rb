require 'observer'

module GamePack2P
  class Stats
    include Observable

    attr_reader :round, :current_wins, :time_played_in_ms, :games_played

    def initialize(round)
      @round = round
      @current_wins = 0
      @time_played_in_ms = 0
      @games_played = 0
    end

    def set_current_wins(wins)
      @current_wins = wins
      updated
    end

    def increment_games_played
      @games_played += 1
      updated
    end

    def increase_time_played_by(time_delta)
      @time_played_in_ms += time_delta
      updated
    end

    def updated
      changed
      notify_observers(round, self)
    end
  end
end