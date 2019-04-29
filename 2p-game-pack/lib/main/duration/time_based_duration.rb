require_relative 'duration'

module GamePack2P
  class TimeBasedDuration < Duration
    def initialize(time_to_play_in_s)
      super(:time_played_in_ms, time_to_play_in_s * 1000)
    end

    def status_message
      "#{ (@max_value/1000).round - (@current_value/1000).round}s left."
    end
  end
end