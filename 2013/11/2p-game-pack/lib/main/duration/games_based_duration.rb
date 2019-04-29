require_relative 'duration'

module GamePack2P
  class GamesBasedDuration < Duration
    def initialize(games_to_play)
      super(:games_played, games_to_play)
    end

    def status_message
      "#{@max_value - @current_value} games left."
    end
  end
end