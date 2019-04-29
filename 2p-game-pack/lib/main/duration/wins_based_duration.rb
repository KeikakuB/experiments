require_relative 'duration'

module GamePack2P
  class WinsBasedDuration < Duration
    def initialize(games_to_win)
      super(:current_wins, games_to_win)
    end

    def status_message
      "#{@max_value - @current_value} more wins to end the round"
    end
  end
end