require_relative '../game_pack'
require_relative 'super_game_state'

module GamePack2P
  class GamePlay < SuperGameState
    def setup
      super
      @ti = Time.now.to_f
    end

    def game_over(result)
      @tf = Time.now.to_f
      GamePack.instance.game_over(result, ((@tf - @ti) * 1000).round)
    end
  end
end