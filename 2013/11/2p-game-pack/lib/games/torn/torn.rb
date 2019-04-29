require 'rubygems'
require 'gosu'
require 'chingu'

require_relative '../../main/game_pack'
require_relative 'burner'
require_relative '../../main/game_states/game_play'
require_relative '../../main/game'

module GamePack2P
  class TornGamePlay < GamePlay
    SPAWN_BUFFER_X = 65
    SPAWN_BUFFER_Y = 65

    def initialize
      super
    end

    def setup
      super
      @wall = nil
      @burner1 = nil
      @burner2 = nil
      PathSegment.destroy_all
      Path.destroy_all
      Burner.destroy_all
      tl = Position.new(3, 3)
      @wall = WallPath.new(Gosu::Color::RED, 3,
                           [Position.new(tl.x, tl.y),
                            Position.new($window.width - tl.x * 2, tl.y),
                            Position.new($window.width, $window.height - tl.y * 2),
                            Position.new(tl.x, $window.height),
                            Position.new(tl.x, tl.y)])
      @burner1 = Burner.create({:image => Gosu::Image['torn/player1.png'],
                                :x => SPAWN_BUFFER_X,
                                :y => SPAWN_BUFFER_Y},
                               Burner::Direction::RIGHT, p1.color)
      @burner1.x = SPAWN_BUFFER_X
      @burner1.y = SPAWN_BUFFER_Y
      p1_controls = p1.controls
      @burner1.input = {p1_controls[:left_key] => :move_left,
                        p1_controls[:right_key] => :move_right,
                        p1_controls[:up_key] => :move_up,
                        p1_controls[:down_key] => :move_down}
      @burner2 = Burner.create({:image => Gosu::Image['torn/player2.png'],
                                :x => $window.width - SPAWN_BUFFER_X,
                                :y => $window.height - SPAWN_BUFFER_Y},
                               Burner::Direction::LEFT, p2.color)

      @burner2.x = $window.width - SPAWN_BUFFER_X
      @burner2.y = $window.height - SPAWN_BUFFER_Y
      p2_controls = p2.controls
      @burner2.input = {p2_controls[:left_key] => :move_left,
                        p2_controls[:right_key] => :move_right,
                        p2_controls[:up_key] => :move_up,
                        p2_controls[:down_key] => :move_down}
      #todo: reset objects?
    end

    def draw
      super
      @wall.draw
    end

    def update
      super
      b1 = false
      b2 = false

      @burner1.path.segments.each do |segment|
        break if b1 && b2
        b1 = true if !b1 && ( (@burner1.bounding_box_collision? segment) && !@burner1.path.head_segments.include?(segment))
        b2 = true if !b2 && (@burner2.bounding_box_collision? segment)
      end

      @burner2.path.segments.each do |segment|
        break if b1 && b2
        b1 = true if !b1 && (@burner1.bounding_box_collision? segment)
        b2 = true if !b2 && ( (@burner2.bounding_box_collision? segment) && !@burner2.path.head_segments.include?(segment))
      end

      @wall.segments.each do |segment|
        break if b1 && b2
        b1 = true if !b1 && (@burner1.bounding_box_collision? segment)
        b2 = true if !b2 && (@burner2.bounding_box_collision? segment)
      end

      if b1 && b2
        game_over( GameResult::TIE )
      elsif b2
        game_over( GameResult::P1_WIN )
      elsif b1
        game_over( GameResult::P2_WIN )
      end
    end
    def finalize
      #todo: do something?
    end
  end
end
