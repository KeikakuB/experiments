require_relative '../lib/main/game_pack'
require_relative '../lib/main/game_states/menu'
require_relative '../lib/games/torn/torn'
require_relative '../lib/main/duration/games_based_duration'
require_relative '../lib/main/duration/wins_based_duration'
require_relative '../lib/main/duration/time_based_duration'

module GamePack2P
  gp = GamePack.instance
  gp.set_new_round([Game.new(TornGamePlay.new)], TimeBasedDuration.new(60))
  gp.play(Menu.new)
end