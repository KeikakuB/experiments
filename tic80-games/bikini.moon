-- title: Bikini
-- author: BillOhReally (Bill Christian Tyros)
-- desc:   short description
-- script: moon
-- input:  gamepad
-- saveid: BillOhReally.Bikini
local God, Weeb, HeartSpawner, HatSpawner, Obstacle


TILE_INDEX_OBSTACLE = 1


PLAYER_SPRITES = {32, 64}
PLAYER_CONTROLS = {
    left: 2
    right: 3
    jump: 4
    attack: 5
    }


TILE_DEFAULT = 9
TILE_WIDTH = 8
TILE_HEIGHT = 8

ROOM_WIDTH = 30
ROOM_HEIGHT = 17

SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136
rooms = {}
for x = 0,240-ROOM_WIDTH,ROOM_WIDTH do
    for y = 0,136-ROOM_HEIGHT,ROOM_HEIGHT do
        table.insert(rooms, {x,y})

export generate_maptile_callback = (is_setup) ->
    return (tile, x, y) ->
        helper_sprite = (index, size, callback) ->
            if tile == index
                if is_setup then callback!
                return true
            if size >= 2 and ( (tile == index + 1) or (tile == index + 16) or (tile == index + 17) )
                return true
            if size >= 3 and ( (tile == index + 2) or (tile == index + 18) or (tile == index + 32) or (tile == index + 33) or (tile == index + 34))
                return true
            return false
        if helper_sprite(1, 1, -> Obstacle(x * TILE_WIDTH, y * TILE_HEIGHT)) then return TILE_DEFAULT
        if helper_sprite(32, 2, -> Weeb(1, x * TILE_WIDTH, y * TILE_HEIGHT)) then return TILE_DEFAULT
        if helper_sprite(64, 2, -> Weeb(2, x * TILE_WIDTH, y * TILE_HEIGHT)) then return TILE_DEFAULT
        if helper_sprite(160, 2, -> HatSpawner(x * TILE_WIDTH, y * TILE_HEIGHT)) then return TILE_DEFAULT
        if helper_sprite(192, 2, -> HeartSpawner(x * TILE_WIDTH, y * TILE_HEIGHT)) then return TILE_DEFAULT
        return tile

--returns the room by index (1-64)
export rget = (i, callback) ->
    return rooms[i][1],rooms[i][2],ROOM_WIDTH,ROOM_HEIGHT,0,0,0,1,callback


class God
    @t = 0
    @gos = {}
    @room_index = -1
    @id_counter = 0

    add_go: (go) =>
        trace "adding #{go}"
        table.insert(@@gos, go)

    show_room: (index) =>
        should_init = @@room_index ~= index
        @@room_index = index
        if should_init
            God\_destroy_gos(false)
        map(rget(index, generate_maptile_callback(should_init)))

    next_id: =>
        prev = @@id_counter
        @@id_counter += 1
        return prev

    update: =>
        -- destroy marked game objects
        God\_destroy_gos(true)
        -- update remaining game objects
        for g in *@@gos do
            g\update!

    draw: =>
        table.sort(@@gos, (a, b) -> return a.sort_order < b.sort_order)
        for g in *@@gos do
            g\draw!

    @_destroy_gos: (only_marked) =>
        -- destroy game objects
        ids_to_remove = {}
        i = 1
        for g in *@@gos do
            if not only_marked or g.marked_for_destruction then
               trace "removing #{g}"
               table.insert(ids_to_remove, i)
            i += 1
        for index in *ids_to_remove
            table.remove(@@gos, index)

class GameObject
    new: (@x, @y, @w, @h, @sort_order) =>
        @marked_for_destruction = false
        @id = God\next_id!
        God\add_go(self)
        @vx = 0
        @vy = 0
    update: =>
        @x += @vx
        @y += @vy
        -- wrap
        @x = @x % SCREEN_WIDTH
        @y = @y % SCREEN_HEIGHT
    draw: =>

    destroy: =>
        @marked_for_destruction = true


export pbtn = (key_index, player_id) ->
    return btn(key_index + (player_id - 1) * 8)

WEEB_STATE = {
    none: 0, idle: 1, moving: 2, jumping: 3, clinging: 4
}
WEEB_FACING = {
    none: 0, left: 1, right: 2
}
WEEB_OFFSET_HORIZONTAL = {
    none: 0, left: 1, right: 2
}
WEEB_OFFSET_VERTICAL = {
    none: 0, top: 1, bot: 2
}
WEEB_DIRECTION = {
    none: 0, left: 1, top: 2, right: 3, bot: 4
}
WEEB_HORIZONTAL_SPEED = 1
class Weeb extends GameObject
    new: (@player_id, @x, @y) =>
        super @x, @y, 2, 2, 1
        @state = WEEB_STATE.idle
        @facing = if @player_id == 1 then WEEB_FACING.right else WEEB_FACING.left

    update: =>
        is_pressing_left = pbtn(PLAYER_CONTROLS.left, @player_id)
        is_pressing_right = pbtn(PLAYER_CONTROLS.right, @player_id)
        if is_pressing_left then
            @facing = WEEB_FACING.left
        if is_pressing_right then
            @facing = WEEB_FACING.right
        if @is_grounded! then
            @vx = 0
            if is_pressing_left
                @vx = -WEEB_HORIZONTAL_SPEED
            if is_pressing_right
                @vx = WEEB_HORIZONTAL_SPEED
            if pbtn(PLAYER_CONTROLS.jump, @player_id)
                @vy = -1
        if @is_airborn! then
            @vy = 1
        else
            @vy = 0
            --gravity ?
        super update

    draw: =>
        super draw
        hori_flip = if @facing == WEEB_FACING.right then 0 else 1
        spr PLAYER_SPRITES[@player_id], @x, @y, 0, 1, hori_flip, 0, @w, @h
        if @player_id == 1
            print "is_grounded: #{@is_grounded!}", 50, 50, 5, true
            coords_l = @get_map_coords(WEEB_OFFSET_HORIZONTAL.left, WEEB_OFFSET_VERTICAL.bot)
            coords_r = @get_map_coords(WEEB_OFFSET_HORIZONTAL.right, WEEB_OFFSET_VERTICAL.bot)
            print "bot map coords l: (#{coords_l.x},#{coords_l.y})", 50, 60, 5, true
            print "bot map coords r: (#{coords_r.x},#{coords_r.y})", 50, 70, 5, true

    get_map_coords: (horizontal_offset=WEEB_OFFSET_HORIZONTAL.left, vertical_offset=WEEB_OFFSET_VERTICAL.top) =>
        off_x = 0
        if horizontal_offset == WEEB_OFFSET_HORIZONTAL.right
            off_x = @w
        off_y = 0
        if vertical_offset == WEEB_OFFSET_VERTICAL.bot
            off_y = @h
        map_x = math.floor((math.floor(@x) / TILE_WIDTH) + off_x)
        map_y = math.floor((math.floor(@y) / TILE_HEIGHT) + off_y)
        return {x: map_x, y: map_y}

    is_obstacle_in_direction: (direction) =>
        a_h = WEEB_OFFSET_HORIZONTAL.left
        a_v = WEEB_OFFSET_VERTICAL.top
        b_h = WEEB_OFFSET_HORIZONTAL.left
        b_v = WEEB_OFFSET_VERTICAL.bot
        switch direction
            when WEEB_DIRECTION.left
                a_h = WEEB_OFFSET_HORIZONTAL.left
                a_v = WEEB_OFFSET_VERTICAL.top
                b_h = WEEB_OFFSET_HORIZONTAL.left
                b_v = WEEB_OFFSET_VERTICAL.bot

            when WEEB_DIRECTION.top
                a_h = WEEB_OFFSET_HORIZONTAL.left
                a_v = WEEB_OFFSET_VERTICAL.top
                b_h = WEEB_OFFSET_HORIZONTAL.right
                b_v = WEEB_OFFSET_VERTICAL.top

            when WEEB_DIRECTION.right
                a_h = WEEB_OFFSET_HORIZONTAL.right
                a_v = WEEB_OFFSET_VERTICAL.top
                b_h = WEEB_OFFSET_HORIZONTAL.right
                b_v = WEEB_OFFSET_VERTICAL.bot

            when WEEB_DIRECTION.bot
                a_h = WEEB_OFFSET_HORIZONTAL.left
                a_v = WEEB_OFFSET_VERTICAL.bot
                b_h = WEEB_OFFSET_HORIZONTAL.right
                b_v = WEEB_OFFSET_VERTICAL.bot

        coords_a = @get_map_coords(a_h,a_v)
        coords_b = @get_map_coords(b_h,b_v)
        return mget(coords_a.x,coords_a.y) == TILE_INDEX_OBSTACLE or mget(coords_b.x, coords_b.y) == TILE_INDEX_OBSTACLE

    is_grounded: =>
        return @is_obstacle_in_direction(WEEB_DIRECTION.bot)

    is_airborn: =>
        return not @is_grounded!

    __tostring: =>
        "Weeb(id:#{@id}, x:#{@x}, y:#{@y})"

class HatSpawner extends GameObject
    new: (@x, @y) =>
        super @x, @y, 2, 2, 2

    update: =>
        -- spawn hats in a certain interval
        super update

    draw: =>
        super draw
        spr 160, @x, @y, 0, 1, 0, 0, @w, @h

    __tostring: =>
        "HatSpawner(id:#{@id}, x:#{@x}, y:#{@y})"

class HeartSpawner extends GameObject
    new: (@x, @y) =>
        super @x, @y, 2, 2, 3

    update: =>
        -- spawn heart in a certain interval
        super update

    draw: =>
        super draw
        spr 192, @x, @y, 0, 1, 0, 0, @w, @h

    __tostring: =>
        "HeartSpawner(id:#{@id}, x:#{@x}, y:#{@y})"

class Obstacle extends GameObject
    new: (@x, @y) =>
        super @x, @y, 1, 1, 99

    draw: =>
        super draw
        spr 1, @x, @y, 0, 1, 0, 0, @w, @h

    __tostring: =>
        "Obstacle(id:#{@id}, x:#{@x}, y:#{@y})"


export TIC=->
    God\update!
    cls 0
    God\show_room(1)
    God\draw!
    God.t+=1

