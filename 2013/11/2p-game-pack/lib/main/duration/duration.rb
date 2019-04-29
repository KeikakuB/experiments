module GamePack2P
  class Duration
    def initialize(attribute_name, max_value)
      @attribute_name = attribute_name
      @max_value = max_value
    end

    def update(round, stats)
      @current_value = stats.send(@attribute_name)
      if @current_value >= @max_value
        round.is_over = true
      end
    end

    def status_message
      "#{@attribute_name.to_s}| Current: #{@current_value}, Max: #{@max_value}"
    end
  end
end