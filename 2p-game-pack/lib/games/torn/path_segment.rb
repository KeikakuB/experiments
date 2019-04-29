require 'rubygems'
require 'gosu'
require 'chingu'

module GamePack2P
  class PathSegment < Chingu::BasicGameObject
    SEGMENT_BUFFER = 3

    attr_writer :x, :y, :width, :height
    trait :collision_detection

    def initialize(p1, p2, thickness, color)
      super({})
      @is_parent_burner_path = @parent_path.is_a?(BurnerPath)
      @thickness = thickness
      params = get_segment_params(p1, p2)
      @rect = Chingu::Rect.new(params[:x], params[:y], params[:width], params[:height])
      @color = color
    end


    def draw
      super
      $window.fill_rect(@rect, @color, 1)
    end

    def bounding_box
      @rect
    end

    def set_rect(p1, p2)
      params = get_segment_params(p1, p2,)
      @rect.x = params[:x]
      @rect.y = params[:y]
      @rect.width = params[:width]
      @rect.height = params[:height]
    end

    def get_segment_params(p1, p2)
      length = Math.sqrt((p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2)
      width = if p1.x != p2.x then
                length
              else
                @thickness
              end
      height = if p1.y != p2.y then
                 length
               else
                 @thickness
               end
      x = if p1.x <= p2.x then
            p1.x
          else
            p2.x
          end
      y = if p1.y <= p2.y then
            p1.y
          else
            p2.y
          end
      x = x - SEGMENT_BUFFER if @is_parent_burner_path
      y = y - SEGMENT_BUFFER if @is_parent_burner_path
      {:x => x, :y => y, :width => width, :height => height}
    end
  end
end