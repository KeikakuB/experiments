pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- pew pew
-- bill christian tyros

-- todo
-- implement basic ai for menu screen and gameplay
-- add delta time and time scale then slowdown time during state.victory instead of freezing it
-- print centered text
-- powerup (to encourage area control gameplay)
-- add music
-- iterate ...
-- playtest ..
-- test ...
-- ...

-- playtest 1 - things to try
-- Always thrust to avoid degenerate strategies ->This will free up a button for a shield or a teleport
-- End the game and restart the game after x kills
-- Reduce number of balls per player by limiting the amount per charge level (eg. maybe try one ball per charge level)
-- Reduce charge levels to three and increase charge times between the three
-- slowdown after each death (speed down instantly then go back to normal linearly)
--

--config
is_debug_mode = true
is_last_man_standing = false

--config

arena_width = 128
arena_height = 122

ui_y_height = 6
ui_score_initial_horizontal_buffer = 7
ui_score_horizontal_buffer = 16

arena_buffer = 8

-- player
player_count = 0

-- ship
ship_radius = 2
ship_length = 7
ship_half_width = 3

ship_turn_thrust = 0.0125
ship_thrust_start = 0.1
ship_thrust_end = 0.2
ship_thrust_charge_time = 0.05

ship_max_thrust = 2
ship_shoot_delay = 0.5
ship_base_angle = 0.25

ship_max_bullets = 3

ship_invicibility_flash_delay = 0.125
ship_invicibility_duration = 1

ship_bounciness = 0.25

sound = 
{
    shoot0 = 0,
    shoot1 = 1,
    shoot2 = 2,
    shoot3 = 3,
    shoot4 = 4,
    hit    = 5,
    fizzle = 6
}

-- bullet
bullet_charge_levels = 
{
    {level = 0, charge_time = 0   , speed = 4  , lifetime = 0.5, radius = 2, knockback_force = 0  , bounciness = 0.05, sound = sound.shoot0 },
    {level = 1, charge_time = 0.25, speed = 3  , lifetime = 2  , radius = 3, knockback_force = 0  , bounciness = 0.05, sound = sound.shoot1 },
    {level = 2, charge_time = 0.5 , speed = 2  , lifetime = 4  , radius = 5, knockback_force = 0  , bounciness = 0.05, sound = sound.shoot2 },
    {level = 3, charge_time = 0.75, speed = 1  , lifetime = 6  , radius = 7, knockback_force = 0  , bounciness = 0.05, sound = sound.shoot3 },
    {level = 4, charge_time = 1   , speed = 0.5, lifetime = 8  , radius = 9, knockback_force = 0  , bounciness = 0.05, sound = sound.shoot4 }
}

-- states
state_prep_timer_start = 0
state_prep_duration = 3

state_victory_timer_start = 0
state_victory_duration = 2.5

corners = 
{
    topleft =   { x = arena_buffer               , y = arena_buffer               , rot = -0.125 },
    botright =  { x = arena_width - arena_buffer , y = arena_height - arena_buffer, rot = 0.375 },
    topright =  { x = arena_width - arena_buffer , y = arena_buffer               , rot = 0.125 },
    botleft =   { x = arena_buffer               , y = arena_height - arena_buffer, rot = 0.625 },
    left =      { x = arena_buffer               , y = arena_height / 2           , rot = -0.25 },
    top =       { x = arena_width / 2            , y = arena_buffer               , rot = -0.5 },
    bot =       { x = arena_width / 2            , y = arena_height - arena_buffer, rot = -0.5 },
    right =     { x = arena_width - arena_buffer , y = arena_height / 2           , rot = 0.25 }
}

player_templates =
{
    {id = 0, color = 12},
    {id = 1, color = 8},
    {id = 2, color = 10},
    {id = 3, color = 11},
    {id = 4, color = 13},
    {id = 5, color = 7},
    {id = 6, color = 9},
    {id = 7, color = 5}
}

ship_templates =
{
    {id = 0, corner = corners.topleft,  color = 12},
    {id = 1, corner = corners.botright, color = 8},
    {id = 2, corner = corners.botleft,  color = 10},
    {id = 3, corner = corners.topright, color = 11},
    {id = 4, corner = corners.left,     color = 13},
    {id = 5, corner = corners.top,      color = 7},
    {id = 6, corner = corners.bot,      color = 9},
    {id = 7, corner = corners.right,    color = 5}
}

players = {}
ships = {}
bullets = {}
particles = {}

key = 
{
    left = 0,
    right = 1,
    up = 2,
    down = 3,
    o = 4,
    x = 5
}

state =
{
    none = 0,
    intro = 1,
    prep = 2,
    play = 3,
    victory = 4
}

game_state = state.none

function reset()
    ships = {}
    bullets = {}
    particles = {}
end

function _init()
    menu_reset()
    camera( -(128 - arena_width) / 2, -(128 - arena_height + ui_y_height) / 2)
    local start_state = state.intro
    if(is_debug_mode) start_state = state.prep
    change_state(start_state)
    if(is_debug_mode) change_state(state.play)
end

function menu_reset()
    local msg_debug_mode = is_debug_mode and "debug mode: on" or "debug mode: off"
    local msg_last_man_standing = is_last_man_standing and "last man: on" or "last man: off"
    menuitem(1, msg_debug_mode, menu_toggle_debug_mode)
    menuitem(2, msg_last_man_standing, menu_toggle_last_man_standing)
end

function menu_toggle_debug_mode()
    is_debug_mode = not is_debug_mode
    menu_reset()

    if(is_debug_mode) then change_state(state.play) else change_state(state.intro) end
end

function menu_toggle_last_man_standing()
    is_last_man_standing = not is_last_man_standing
    menu_reset()
end

debug_eight_player_ui = false
function _update()
    for i = 0, 8 do
        if(not debug_eight_player_ui) then
            local no_such_player = true
            for p in all(players) do
                if(p.id == i) then
                    no_such_player = false
                    break
                end
            end
            if(no_such_player and any_btn_for(i)) new_player(i)
        else
            if(player_count < 8) new_player(i)
        end
    end
    foreach(players, player_update)
    if(game_state == state.intro) then
        if(any_btn() and player_count > 1) change_state(state.prep)
    elseif(game_state == state.prep) then
        if(time() - state_prep_timer_start > state_prep_duration) change_state(state.play)
    elseif(game_state == state.play) then
        if(is_last_man_standing
            and player_count > 1 
            and get_number_of_alive_players() == 1) then
            change_state(state.victory)
        end
        foreach(ships, ship_update)
        foreach(bullets, bullet_update)
        foreach(particles, particle_update)
        check_collisions()
    elseif(game_state == state.victory) then
        foreach(particles, particle_update)
        if(time() - state_victory_timer_start > state_victory_duration) then
            reset()
            foreach(players, player_spawn)
            change_state(state.prep)
        end
    end
end

function _draw()
    cls()
    rectfill(0, 0, arena_width, arena_height, 1)
    if(game_state == state.intro) then
    elseif(game_state == state.prep) then 
        print(max(0, state_prep_duration - -flr(-(time() - state_prep_timer_start))), 64, 64, 7)
        foreach(ships, ship_draw)
    elseif(game_state == state.play) then
        foreach(particles, particle_draw)
        foreach(bullets, bullet_draw)
        foreach(ships, ship_draw)
    elseif(game_state == state.victory) then
        foreach(particles, particle_draw)
        foreach(bullets, bullet_draw)
        foreach(ships, ship_draw)
    end
    draw_ui()
end

function draw_ui()
    if(game_state == state.intro) then
        local intro_left = 40
        local intro_height = 46
        print("pew pew", intro_left, intro_height, 7)
        print("\x8B \x91: turn", intro_left, intro_height + 8, 7)
        print("\x97: thrust", intro_left, intro_height + 8 * 2, 7)
        print("\x8E: shoot",intro_left, intro_height + 8 * 3, 7)
    else
        rectfill(0, -ui_y_height, 128, 0, 0)
        foreach(players, player_draw)
    end
end

function change_state(s)
    if(game_state == s) return
    printh("state changed " .. game_state .. " -> " .. s );
    game_state = s
    if(s == state.intro) then
        reset()
    elseif(s == state.prep) then
        reset()
        state_prep_timer_start = time()
    elseif(s == state.play) then
        foreach(ships, ship_set_invincible)
    elseif(s == state.victory) then
        state_victory_timer_start = time()
    end
end

-- player
function new_player(id)
    printh("new player " .. id)
    local player =
    {
        id = id,
        score = 0,
        color = player_templates[id + 1].color,
        is_dead = false
    }
    add(players, player)
    player_count += 1
    return player
end

function player_update(player)
    local ship = find_ship(player.id)
    if(not player.is_dead 
        and not ship) then
        printh("new ship " .. player.id)
        state_prep_timer_start = time()
        local s = player_spawn(player)
        ship_set_invincible(s)
    end
end

function player_spawn(player)
    player.is_dead = false
    return new_ship(ship_templates[player.id + 1])
end

function player_respawn(player)
    local ship = player_spawn(player)
    local rnd_spawn_location = ship_templates[flr(rnd(8) + 1)]
    ship.x = rnd_spawn_location.corner.x
    ship.y = rnd_spawn_location.corner.y
    ship.rot = rnd_spawn_location.corner.rot
    ship.vx = 0
    ship.vy = 0
    ship_set_invincible(ship)
end


function player_draw(player)
    print(player.score, ui_score_initial_horizontal_buffer + player.id * ui_score_horizontal_buffer, -ui_y_height, player.color)
end

function get_number_of_alive_players()
    local count = 0
    for p in all(players) do
        if(not p.is_dead) count += 1
    end
    return count
end
-- ship
function new_ship(parms)
    local ship =
    {
        guid = get_guid(),
        id = parms.id,
        corner = parms.corner,
        x = parms.corner.x,
        y = parms.corner.y,
        rot = parms.corner.rot,
        radius = ship_radius,
        vx = 0,
        vy = 0,
        color = parms.color,
        is_thrusting = false,
        thrusting_since = 0,
        last_shot_time = -999,
        is_charging = false,
        charging_since = 0,
        is_invicible = false,
        invicibility_start_time = 0,
        bullets = {},
        bullet_count = 0
    }
    add(ships, ship)
    return ship
end

function destroy_ship(ship)
    foreach(ship.bullets, destroy_bullet)
    del(ships, ship)
end

function ship_update(ship)
    if(ship.is_invicible
        and time() - ship.invicibility_start_time > ship_invicibility_duration) then
        ship.is_invicible = false
    end
    -- turn
    local rotsign = 0
    if(btn(key.left, ship.id)) then
        rotsign = -1
    elseif(btn(key.right, ship.id)) then
        rotsign = 1
    end
    ship.rot += rotsign * ship_turn_thrust
    -- acceleration
    if(btn(key.x, ship.id)
        and not btn(key.o, ship.id)) then
        if(not ship.is_thrusting) then
            ship.is_thrusting = true
            ship.thrusting_since = time()
        end
        local thrusting_time = min(time() - ship.thrusting_since, ship_thrust_charge_time);
        local t = thrusting_time / ship_thrust_charge_time
        spawn_fx_ship_thrust(ship, t)
        local thrust_factor = lerp(ship_thrust_start, ship_thrust_end, t)

        local direction = get_ship_direction(ship)
        ship.vx += direction.x * thrust_factor
        ship.vy += direction.y * thrust_factor
    else
        ship.is_thrusting = false
    end
    -- shooting
    if(not ship.is_invicible) then
        if(not ship.is_charging
            and btn(key.o, ship.id)) then
            ship.is_charging = true
            ship.charging_since = time()
        end
        if(not btn(key.o, ship.id)
            and ship.is_charging
            and (time() - ship.last_shot_time > ship_shoot_delay)) then
            local charge_level = get_ship_charge_level(ship)
            sfx(charge_level.sound, 0)
            local info = get_ship_charged_bullet_info(ship)
            local b = new_bullet(
                        {
                            level = charge_level.level,
                            origin = ship.id,
                            color = ship.color,
                            radius = charge_level.radius,
                            lifetime = charge_level.lifetime,
                            bounciness = charge_level.bounciness,
                            x = info.x,
                            y = info.y,
                            vx = info.vx,
                            vy = info.vy
                        }
                    )
            ship_add_bullet(ship, b)
            local direction = get_ship_direction(ship)
            ship.vx += direction.x * charge_level.knockback_force
            ship.vy += direction.y * charge_level.knockback_force
            ship.is_charging = false
            ship.last_shot_time = time()
        end
    end

    ship.vx = max(-ship_max_thrust, min(ship.vx, ship_max_thrust))
    ship.vy = max(-ship_max_thrust, min(ship.vy, ship_max_thrust))

    ship.x += ship.vx
    ship.y += ship.vy

    wrap(ship)

    if(ship.bullet_count > ship_max_bullets) then
        destroy_bullet(ship.bullets[1])
    end
end

function ship_draw(ship)
    local color = ship.color
    local alt_color = (ship.color + 1) % 16

    if(ship.is_invicible
        and 
            (not ship.invicibility_flash_start_time
            or time() - ship.invicibility_flash_start_time > ship_invicibility_flash_delay 
            )) then
        ship.invicibility_flash_start_time = time()
        color, alt_color = alt_color, color
    end

    local tip = get_ship_tip(ship)
    local left = get_ship_base_left(ship)
    local right = get_ship_base_right(ship)
    line(left.x, left.y, tip.x, tip.y, color)
    line(right.x, right.y, tip.x, tip.y, color)

    line(left.x, left.y, ship.x, ship.y, color)
    line(right.x, right.y, ship.x, ship.y, color)

    pset(tip.x, tip.y, alt_color)
    if(game_state == state.play
        and ship.is_charging) then 
        local info = get_ship_charged_bullet_info(ship)
        circ(info.x, info.y, info.radius, ship.color)
    end
end

function ship_add_bullet(ship, bullet)
    ship.bullet_count += 1
    add(ship.bullets, bullet)
end
function ship_remove_bullet(ship, bullet)
    del(ship.bullets, bullet)
    ship.bullet_count -= 1
end

function ship_set_invincible(ship)
    ship.is_invicible = true
    ship.invicibility_start_time = time()
    ship.is_charging = false
    ship.charging_since = time()
end

function get_ship_charged_bullet_info(ship)
    local tip = get_ship_tip(ship)
    local forward = get_ship_direction(ship)
    local charge_level = get_ship_charge_level(ship)
    return 
    {
        x = tip.x + forward.x * (charge_level.radius + 1),
        y = tip.y + forward.y * (charge_level.radius + 1),
        vx = forward.x * charge_level.speed,
        vy = forward.y * charge_level.speed,
        radius = charge_level.radius
    }
end

function get_ship_charge_level(ship)
    if(not ship.is_charging) return bullet_charge_levels[1]
    local charge_time = time() - ship.charging_since
    local previous_charge_level = bullet_charge_levels[1]
    for level in all(bullet_charge_levels) do
        if(level.charge_time > charge_time) then
            return previous_charge_level
        end
        previous_charge_level = level
    end
    return previous_charge_level
end

function get_ship_tip(ship)
    local direction = get_ship_direction(ship) 
    local dx = ship_length * direction.x
    local dy = ship_length * direction.y
    return 
    {
        x = ship.x + dx - direction.x * (ship_length / ship_half_width),
        y = ship.y + dy - direction.y * (ship_length / ship_half_width)
    }
end

function get_ship_base(ship, rotation_offset)
    local forward = get_ship_direction(ship) 
    local direction = get_ship_direction(ship, rotation_offset) 
    local dx = ship_half_width * direction.x
    local dy = ship_half_width * direction.y
    return 
    {
        x = ship.x + dx - forward.x * (ship_length / ship_half_width),
        y = ship.y + dy - forward.y * (ship_length / ship_half_width)
    }
end

function get_ship_base_right(ship)
    return get_ship_base(ship, -0.25)
end

function get_ship_base_left(ship)
    return get_ship_base(ship, 0.25)
end

function get_ship_direction(ship, rotation_offset)
    if(not rotation_offset) rotation_offset = 0
    return 
    {
        x = sin(ship.rot + rotation_offset),
        y = cos(ship.rot + rotation_offset)
    }
end

-- bullet
function new_bullet(parms)
    local bullet = 
        {
            guid = get_guid(),
            spawn_time = time(),
            level = parms.level,
            origin = parms.origin,
            color = parms.color,
            radius = parms.radius,
            lifetime = parms.lifetime,
            bounciness = parms.bounciness,
            x = parms.x,
            y = parms.y,
            vx = parms.vx,
            vy = parms.vy
        }
    add(bullets, bullet)
    return bullet
end

function destroy_bullet(bullet)
    spawn_fx_bullet_fizzle(bullet)
    local ship = find_ship(bullet.origin)
    if(ship) then
        ship_remove_bullet(ship, bullet)
    end
    del(bullets, bullet)
end

function bullet_update(bullet)
    if(time() - bullet.spawn_time > bullet.lifetime) then
        sfx(sound.fizzle, 3)
        destroy_bullet(bullet)
        return
    end
    bullet.x += bullet.vx
    bullet.y += bullet.vy
    wrap(bullet)
end

function bullet_draw(bullet)
    circfill(bullet.x, bullet.y, bullet.radius, bullet.color)
end

-- particles
function new_particle(parms)
    local p =
    {
        spawn_time = time(),
        start_delay = parms.start_delay,
        duration = parms.duration,
        x = parms.x,
        y = parms.y,
        vx = parms.vx,
        vy = parms.vy,
        color = parms.color
    }
    add(particles, p)
    return p
end

function destroy_particle(particle)
    del(particles, particle)
end

function particle_update(particle)
    if(has_particle_ended(particle)) then
        destroy_particle(particle)
        return
    end
    if(has_particle_started(particle)) then
        particle.x += particle.vx
        particle.y += particle.vy
    end
end

function particle_draw(particle)
    if(has_particle_started(particle)) then
        pset(particle.x, particle.y, particle.color)
    end
end

function has_particle_started(particle)
    return time() - particle.spawn_time > particle.start_delay
end

function has_particle_ended(particle)
    return time() - particle.spawn_time - particle.start_delay > particle.duration
end

function spawn_fx_ship_explosion(x, y, color)
    for i = 0, 1, 0.15 do
        local rnd_i = i + flr(rnd(1) - 1) * rnd(1) * 0.025
        local dx = sin(rnd_i)
        local dy = cos(rnd_i)
        new_particle
        (
            {
                start_delay = 0.01,
                duration = 0.25,
                x = x,
                y = y,
                vx = dx,
                vy = dy,
                color = color
            }
        )
    end
    for i = 0, 1, 0.15 do
        local rnd_i = i + flr(rnd(1) - 1) * rnd(1) * 0.025
        local dx = sin(rnd_i)
        local dy = cos(rnd_i)
        new_particle
        (
            {
                start_delay = 0.125,
                duration = 0.125,
                x = x,
                y = y,
                vx = dx,
                vy = dy,
                color = color
            }
        )
    end
end

function spawn_fx_bullet_fizzle(bullet)
    local duration = 0.25
    new_particle
    (
        {
            start_delay = 0,
            duration = duration,
            x = bullet.x,
            y = bullet.y,
            vx = 0,
            vy = 0,
            color = bullet.color
        }
    )
    for i = 0, 1, 0.25 do
        local dx = sin(i) * bullet.radius
        local dy = cos(i) * bullet.radius
        new_particle
        (
            {
                start_delay = 0,
                duration = duration,
                x = bullet.x + dx,
                y = bullet.y + dy,
                vx = 0,
                vy = 0,
                color = bullet.color
            }
        )
    end
    for i = 0.125, 1, 0.25 do
        local dx = sin(i) * bullet.radius
        local dy = cos(i) * bullet.radius
        new_particle
        (
            {
                start_delay = duration * 0.5,
                duration = duration,
                x = bullet.x + dx,
                y = bullet.y + dy,
                vx = 0,
                vy = 0,
                color = bullet.color
            }
        )
    end
end

function spawn_fx_ship_thrust(ship, force_modifier)
    local forward = get_ship_direction(ship)
    local backward = {}
    backward.x = -forward.x * rnd(1) * force_modifier * 1
    backward.y = -forward.y * rnd(1) * force_modifier * 1
    new_particle(
        {
            start_delay = 0.01,
            duration = 0.05 + rnd(1) * 0.25,
            x = ship.x - forward.x * 0.05,
            y = ship.y - forward.y * 0.05,
            vx = backward.x,
            vy = backward.y,
            color = ship.color
        }
    )
end

-- collisions
function check_collisions()
    -- ship / ship
    for s1 in all(ships) do
        for s2 in all(ships) do
            if(
                s1.id ~= s2.id 
                and not s1.is_invicible
                and not s2.is_invicible
                and check_collision(s1, s2)) then
                bump(s1, s2, ship_bounciness, ship_bounciness)
            end
        end
    end
    -- ship / bullets
    for s in all(ships) do
        for b in all(bullets) do
            if(not s.is_invicible
                and check_collision(s, b)
                and s.id ~= b.origin) then
                sfx(sound.hit, 1)
                local dead_player = find_player(s.id)
                dead_player.is_dead = true
                local shooting_player = find_player(b.origin)
                spawn_fx_ship_explosion(s.x, s.y, shooting_player.color)
                shooting_player.score += 1
                destroy_ship(s)
                destroy_bullet(b)
                if(not is_last_man_standing) then
                    player_respawn(dead_player)
                end
            end
        end
    end
    -- bullets / bullets
    for b1 in all(bullets) do
        for b2 in all(bullets) do
            if(b1.guid ~= b2.guid
                and check_collision(b1, b2)) then
                if(b1.origin ~= b2.origin) then
                    sfx(sound.fizzle, 3)
                    if(b1.level == b2.level) then
                        destroy_bullet(b1)
                        destroy_bullet(b2)
                    elseif(b1.level > b2.level) then
                        destroy_bullet(b2)
                    elseif(b1.level < b2.level) then
                        destroy_bullet(b1)
                    end
                else
                    bump(b1, b2, b1.bounciness, b2.bounciness)
                end
            end
        end
    end
end

function check_collision(c1, c2)
    return ( sqrt( ( c2.x-c1.x ) * ( c2.x-c1.x )  + ( c2.y-c1.y ) * ( c2.y-c1.y ) ) < ( c1.radius + c2.radius ) )
end

--utils
function find_player(id)
    for p in all(players) do
        if(p.id == id) return p
    end
    return nil
end
function find_ship(id)
    for s in all(ships) do
        if(s.id == id) return s
    end
    return nil
end
function bump(p1, p2, bounciness1, bounciness2)
    local bump_delay = 0.1
    if(p1.last_bump_time
        and p2.last_bump_time
        and 
            (
                time() - p1.last_bump_time < bump_delay
                or time() - p2.last_bump_time < bump_delay
            )) then
        return
    end
    local d1 = 
    {
        dx = bounciness1 * (p2.x - p1.x) * 2, 
        dy = bounciness1 * (p2.y - p1.y) * 2 
    }
    local d2 = 
    {
        dx = bounciness2 * (p2.x - p1.x) * 2, 
        dy = bounciness2 * (p2.y - p1.y) * 2 
    }
    p1.vx = -d1.dx
    p1.vy = -d1.dy
    p2.vx = d2.dx
    p2.vy = d2.dy
    local now = time()
    p1.last_bump_time = now
    p2.last_bump_time = now
end
function wrap(position)
    position.x = position.x % arena_width
    position.y = position.y % arena_height
end

function lerp(v0, v1, t)
    return (1 - t) * v0 + t * v1;
end

function any_btn_for(id)
    return btn(key.left, id) 
        or btn(key.right, id) 
        or btn(key.up, id) 
        or btn(key.down, id) 
        or btn(key.o, id) 
        or btn(key.x, id)
end

function any_btn()
    for i = 0, 8 do
        if(any_btn_for(i)) return true
    end
    return false
end

guid_counter = 0
function get_guid()
    local new_guid = guid_counter + 1
    guid_counter += 1
    return new_guid
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f0300b03009030070300603005030050300503006030070300a0300c0300f03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0400b04009040070400604005040050400504006040070400a0400c0400f04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0500b05009050070500605005050050500505006050070500a0500c0500f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0600b06009060070600606005060050600506006060070600a0600c0600f06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0700b07009070070700607005070050700507006070070700a0700c0700f07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a25013250112500f2500d2500d2500c2500b2500c2500e2500b2000d2001020013200162001920000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c3500a350093500935009350093500a3500b3500d3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

