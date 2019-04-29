require 'rubygems'
require 'gosu'
require 'chingu'

require_relative '../../general/position'
require_relative 'path_segment'

module GamePack2P
  class Path < Chingu::BasicGameObject
    attr_reader :segments

    def initialize(color, thickness = 5)
      super({})
      @color, @thickness = color, thickness
      @segments = []
    end

    def draw
      super
      @segments.each do |s|
        s.draw
      end
    end

    def add_pivot_point(x, y)
      new_pivot = Position.new(x, y)
      @latest_pivot = new_pivot if @latest_pivot.nil?
      add_segment(@latest_pivot, new_pivot)
      @latest_pivot = new_pivot
    end

    def add_segment(p1, p2)
      @segments << get_segment(p1, p2)
    end

    def get_segment(p1, p2)
      return PathSegment.new(p1, p2, @thickness, @color)
    end
  end

  class BurnerPath < Path
    NUMBER_OF_HEAD_SEGMENTS = 3

    attr_reader :head, :segments, :head_segments

    def initialize(head, color, thickness = 5)
      super(color, thickness)
      @head = head
      @head_segments = []
      @latest_pivot = Position.new(@head.x, @head.y)
      add_segment(@latest_pivot, @latest_pivot)
    end

    def update
      super
      @head_segments.last.set_rect(@latest_pivot, @head)
    end

    def add_segment(p1, p2)
      head_segment = get_segment(p1, p2)
      @head_segments.shift if @head_segments.size >= NUMBER_OF_HEAD_SEGMENTS
      @head_segments << head_segment
      @segments << head_segment
    end
  end

  class WallPath < Path
    def initialize(color, thickness = 5, preset_pivots = [])
      super(color, thickness)
      preset_pivots.each do |p|
        add_pivot_point(p.x, p.y)
      end
    end
  end
end
