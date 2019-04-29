require 'rubygems'
require 'gosu'
require 'chingu'

require_relative '../../main/game_pack'
require_relative 'path'
require_relative '../../general/position'

module GamePack2P
  class Burner < Chingu::GameObject
    BURNER_SPEED = (((GamePack.instance.window.width + GamePack.instance.window.height) / 2.0) * 0.008).round
    module Direction
      LEFT = 1
      UP = 2
      RIGHT = 3
      DOWN = 4
      FROM_DIRECTION_TO_OPPOSITE = {LEFT => RIGHT, RIGHT => LEFT, UP => DOWN, DOWN => UP}
    end

    FROM_DIRECTION_TO_MOVE_SYMBOLS = {Direction::LEFT => :move_left,
                                      Direction::RIGHT => :move_right,
                                      Direction::UP => :move_up,
                                      Direction::DOWN => :move_down}

    FROM_DIRECTION_TO_MOVE_PARAMS = {Direction::LEFT => {:angle => 180, :vx => -BURNER_SPEED, :vy => 0},
                                     Direction::RIGHT => {:angle => 0, :vx => BURNER_SPEED, :vy => 0},
                                     Direction::UP => {:angle => 270, :vx => 0, :vy => -BURNER_SPEED},
                                     Direction::DOWN => {:angle => 90, :vx => 0, :vy => BURNER_SPEED}}

    trait :bounding_box, :scale => 0.95
    trait :collision_detection
    trait :velocity
    trait :timer

    attr_reader :path

    def initialize(options, starting_direction = Direction::LEFT, color = Gosu::Color.new(0xffff0000))
      super(options.merge({:center_x => 0, :center_y => 0.5}))
      @direction = starting_direction
      @color = color
      @path = BurnerPath.new(self, color)
      @new_angle = @angle
      initial_move
    end

    def draw
      super
      @path.draw
    end

    def update
      super
      @path.update
      @angle = @new_angle
    end

    def initial_move
      if FROM_DIRECTION_TO_MOVE_SYMBOLS.has_key? @direction
        send(FROM_DIRECTION_TO_MOVE_SYMBOLS[@direction], false)
      else
        send(:move_left, false)
      end
    end

    def force_move(direction)
      @path.add_pivot_point(@x, @y)
      params = FROM_DIRECTION_TO_MOVE_PARAMS[direction]
      @direction = direction
      @new_angle = params[:angle]
      @velocity_x = params[:vx]
      @velocity_y = params[:vy]
    end

    def try_to_move(direction)
      is_same_direction = (@direction == direction)
      is_opposite_direction = (@direction == Direction::FROM_DIRECTION_TO_OPPOSITE[direction])
      force_move(direction) if !is_same_direction && !is_opposite_direction
    end

    def move_left(try_to = true)
      move_fun = if try_to then
                   :try_to_move
                 else
                   :force_move
                 end
      send(move_fun, Direction::LEFT)
    end

    def move_right(try_to = true)
      move_fun = if try_to then
                   :try_to_move
                 else
                   :force_move
                 end
      send(move_fun, Direction::RIGHT)
    end

    def move_up(try_to = true)
      move_fun = if try_to then
                   :try_to_move
                 else
                   :force_move
                 end
      send(move_fun, Direction::UP)
    end

    def move_down(try_to = true)
      move_fun = if try_to then
                   :try_to_move
                 else
                   :force_move
                 end
      send(move_fun, Direction::DOWN)
    end
  end
end