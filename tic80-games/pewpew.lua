-- title:  PewPew
-- author: BillOhReally (Bill Christian Tyros)
-- desc:   short description
-- script: lua
-- input:  gamepad
-- saveid: BillOhReally.PewPew


-- todo
-- implement basic ai for menu screen and gameplay
-- add delta time and time scale then slowdown time during state.victory instead of freezing it
-- print centered text
-- powerup (to encourage area control gameplay)
-- add music
-- iterate ...
-- playtest ..
-- ...

--config
is_debug_mode = true
is_last_man_standing = false

--config

-- util

pi_2 = math.pi * 2

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

ship_turn_thrust = 0.0125 * 0.5 * pi_2
ship_thrust_start = 0.05
ship_thrust_end = 0.1
ship_thrust_charge_time = 0.05

ship_max_thrust = 1
ship_shoot_delay = 0.5
ship_base_angle = 0.25 * pi_2

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
    topleft =   { x = arena_buffer               , y = arena_buffer               , rot = -0.125 * pi_2 },
    botright =  { x = arena_width - arena_buffer , y = arena_height - arena_buffer, rot = 0.375  * pi_2 },
    topright =  { x = arena_width - arena_buffer , y = arena_buffer               , rot = 0.125  * pi_2 },
    botleft =   { x = arena_buffer               , y = arena_height - arena_buffer, rot = 0.625  * pi_2 },
    left =      { x = arena_buffer               , y = arena_height / 2           , rot = -0.25  * pi_2 },
    top =       { x = arena_width / 2            , y = arena_buffer               , rot = -0.5   * pi_2 },
    bot =       { x = arena_width / 2            , y = arena_height - arena_buffer, rot = -0.5   * pi_2 },
    right =     { x = arena_width - arena_buffer , y = arena_height / 2           , rot = 0.25   * pi_2 }
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

player_max_number = 1

players = {}
ships = {}
bullets = {}
particles = {}

key =
{
    left = 2,
    right = 3,
    up = 0,
    down = 1,
    y = 6,
    x = 7,
    a = 4,
    b = 5
}

key_number = 8

state =
{
    none = 0,
    intro = 1,
    prep = 2,
    play = 3,
    victory = 4
}

game_state = state.none

has_inited = false
function TIC()
    if(not has_inited) then
        has_inited = true
        _init()
    end
    _update()
    _draw()
end

function get_time()
    return (1 / time()) * 60
end

function reset()
    ships = {}
    bullets = {}
    particles = {}
end

function _init()
    --camera( -(128 - arena_width) / 2, -(128 - arena_height + ui_y_height) / 2)
    local start_state = state.intro
    if(is_debug_mode) then start_state = state.prep end
    change_state(start_state)
    if(is_debug_mode) then change_state(state.play) end
end

debug_eight_player_ui = false
function _update()
    for i = 0, player_max_number do
        if(not debug_eight_player_ui) then
            local no_such_player = true
            for k, p in pairs(players) do
                if(p.id == i) then
                    no_such_player = false
                    break
                end
            end
            if(no_such_player and any_btn_for(i)) then new_player(i) end
        else
            if(player_count < player_max_number) then new_player(i) end
        end
    end
    foreach(players, player_update)
    if(game_state == state.intro) then
        if(any_btn() and player_count > 1) then change_state(state.prep) end
    elseif(game_state == state.prep) then
        if(get_time() - state_prep_timer_start > state_prep_duration) then change_state(state.play) end
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
        if(get_time() - state_victory_timer_start > state_victory_duration) then
            reset()
            foreach(players, player_spawn)
            change_state(state.prep)
        end
    end
end

function _draw()
    cls()
    rect(0, 0, arena_width, arena_height, 1)
    if(game_state == state.intro) then
    elseif(game_state == state.prep) then
        print(max(0, state_prep_duration - -math.floor(-(get_time() - state_prep_timer_start))), 64, 64, 7)
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
        rect(0, -ui_y_height, 128, 0, 0)
        foreach(players, player_draw)
    end
end

function change_state(s)
    if(game_state == s) then return end
    trace("state changed " .. game_state .. " -> " .. s );
    game_state = s
    if(s == state.intro) then
        reset()
    elseif(s == state.prep) then
        reset()
        state_prep_timer_start = get_time()
    elseif(s == state.play) then
        foreach(ships, ship_set_invincible)
    elseif(s == state.victory) then
        state_victory_timer_start = get_time()
    end
end

-- player
function new_player(id)
    trace("new player " .. id)
    local player =
    {
        id = id,
        score = 0,
        color = player_templates[id + 1].color,
        is_dead = false
    }
    table.insert(players, player)
    player_count = player_count + 1
    return player
end

function player_update(player)
    local ship = find_ship(player.id)
    if(not player.is_dead
        and not ship) then
        trace("new ship " .. player.id)
        state_prep_timer_start = get_time()
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
    local rnd_spawn_location = ship_templates[math.random(8)]
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
    for k, p in pairs(players) do
        if(not p.is_dead) then count = count + 1 end
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
    table.insert(ships, ship)
    return ship
end

function destroy_ship(ship)
    foreach(ship.bullets, destroy_bullet)
    del(ships, ship)
end

function ship_update(ship)
    if(ship.is_invicible
        and get_time() - ship.invicibility_start_time > ship_invicibility_duration) then
        ship.is_invicible = false
    end
    -- turn
    local rotsign = 0
    if(get_button(key.left, ship.id)) then
        rotsign = 1
    elseif(get_button(key.right, ship.id)) then
        rotsign = -1
    end
    ship.rot = ship.rot + rotsign * ship_turn_thrust
    -- acceleration
    if(get_button(key.a, ship.id)
        and not get_button(key.b, ship.id)) then
        if(not ship.is_thrusting) then
            ship.is_thrusting = true
            ship.thrusting_since = get_time()
        end
        local thrusting_time = math.min(get_time() - ship.thrusting_since, ship_thrust_charge_time);
        local t = thrusting_time / ship_thrust_charge_time
        spawn_fx_ship_thrust(ship, t)
        local thrust_factor = lerp(ship_thrust_start, ship_thrust_end, t)

        local direction = get_ship_direction(ship)
        ship.vx = ship.vx + direction.x * thrust_factor
        ship.vy = ship.vy + direction.y * thrust_factor
    else
        ship.is_thrusting = false
    end
    -- shooting
    if(not ship.is_invicible) then
        if(not ship.is_charging
            and get_button(key.b, ship.id)) then
            ship.is_charging = true
            ship.charging_since = get_time()
        end
        if(not get_button(key.b, ship.id)
            and ship.is_charging
            and (get_time() - ship.last_shot_time > ship_shoot_delay)) then
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
            ship.vx = ship.vx + direction.x * charge_level.knockback_force
            ship.vy = ship.vy + direction.y * charge_level.knockback_force
            ship.is_charging = false
            ship.last_shot_time = get_time()
        end
    end

    ship.vx = math.max(-ship_max_thrust, math.min(ship.vx, ship_max_thrust))
    ship.vy = math.max(-ship_max_thrust, math.min(ship.vy, ship_max_thrust))

    ship.x = ship.x + ship.vx
    ship.y = ship.y + ship.vy

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
        or get_time() - ship.invicibility_flash_start_time > ship_invicibility_flash_delay
        )) then
        ship.invicibility_flash_start_time = get_time()
        color, alt_color = alt_color, color
    end

    local tip = get_ship_tip(ship)
    local left = get_ship_base_left(ship)
    local right = get_ship_base_right(ship)
    line(left.x, left.y, tip.x, tip.y, color)
    line(right.x, right.y, tip.x, tip.y, color)

    line(left.x, left.y, ship.x, ship.y, color)
    line(right.x, right.y, ship.x, ship.y, color)

    pix(tip.x, tip.y, alt_color)
    if(game_state == state.play
        and ship.is_charging) then
        local info = get_ship_charged_bullet_info(ship)
        circb(info.x, info.y, info.radius, ship.color)
    end
end

function ship_add_bullet(ship, bullet)
    ship.bullet_count = ship.bullet_count + 1
    table.insert(ship.bullets, bullet)
end
function ship_remove_bullet(ship, bullet)
    del(ship.bullets, bullet)
    ship.bullet_count = ship.bullet_count - 1
end

function ship_set_invincible(ship)
    ship.is_invicible = true
    ship.invicibility_start_time = get_time()
    ship.is_charging = false
    ship.charging_since = get_time()
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
    if(not ship.is_charging) then return bullet_charge_levels[1] end
    local charge_time = get_time() - ship.charging_since
    local previous_charge_level = bullet_charge_levels[1]
    for k, level in pairs(bullet_charge_levels) do
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
    if(not rotation_offset) then rotation_offset = 0 end
    return
    {
        x = math.sin(ship.rot + rotation_offset),
        y = math.cos(ship.rot + rotation_offset)
    }
end

-- bullet
function new_bullet(parms)
    local bullet =
    {
        guid = get_guid(),
        spawn_time = get_time(),
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
    table.insert(bullets, bullet)
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
    if(get_time() - bullet.spawn_time > bullet.lifetime) then
        sfx(sound.fizzle, 3)
        destroy_bullet(bullet)
        return
    end
    bullet.x = bullet.x + bullet.vx
    bullet.y = bullet.y + bullet.vy
    wrap(bullet)
end

function bullet_draw(bullet)
    circ(bullet.x, bullet.y, bullet.radius, bullet.color)
end

-- particles
function new_particle(parms)
    local p =
    {
        spawn_time = get_time(),
        start_delay = parms.start_delay,
        duration = parms.duration,
        x = parms.x,
        y = parms.y,
        vx = parms.vx,
        vy = parms.vy,
        color = parms.color
    }
    table.insert(particles, p)
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
        particle.x = particle.x + particle.vx
        particle.y = particle.y + particle.vy
    end
end

function particle_draw(particle)
    if(has_particle_started(particle)) then
        pix(particle.x, particle.y, particle.color)
    end
end

function has_particle_started(particle)
    return get_time() - particle.spawn_time > particle.start_delay
end

function has_particle_ended(particle)
    return get_time() - particle.spawn_time - particle.start_delay > particle.duration
end

function spawn_fx_ship_explosion(x, y, color)
    for i = 0, 1 * pi_2, 0.15 * pi_2 do
        local rnd_i = i + math.floor(math.random() - 2) * math.random() * 0.025
        local dx = math.sin(rnd_i)
        local dy = math.cos(rnd_i)
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
    for i = 0, 1 * pi_2, 0.15 * pi_2 do
        local rnd_i = i + math.floor(math.random() - 2) * math.random() * 0.025
        local dx = math.sin(rnd_i)
        local dy = math.cos(rnd_i)
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
    for i = 0, 1 * pi_2, 0.25 * pi_2 do
        local dx = math.sin(i) * bullet.radius
        local dy = math.cos(i) * bullet.radius
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
    for i = 0.125 * pi_2, 1 * pi_2, 0.25 * pi_2 do
        local dx = math.sin(i) * bullet.radius
        local dy = math.cos(i) * bullet.radius
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
    backward.x = -forward.x * math.random() * force_modifier * 1
    backward.y = -forward.y * math.random() * force_modifier * 1
    new_particle(
    {
        start_delay = 0.01,
        duration = 0.05 + math.random() * 0.25,
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
    for k1, s1 in pairs(ships) do
        for k2, s2 in pairs(ships) do
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
    for k1, s in pairs(ships) do
        for k2, b in pairs(bullets) do
            if(not s.is_invicible
                and check_collision(s, b)
                and s.id ~= b.origin) then
                sfx(sound.hit, 1)
                local dead_player = find_player(s.id)
                dead_player.is_dead = true
                local shooting_player = find_player(b.origin)
                spawn_fx_ship_explosion(s.x, s.y, shooting_player.color)
                shooting_player.score = shooting_player.score + 1
                destroy_ship(s)
                destroy_bullet(b)
                if(not is_last_man_standing) then
                    player_respawn(dead_player)
                end
            end
        end
    end
    -- bullets / bullets
    for k1, b1 in pairs(bullets) do
        for k2, b2 in pairs(bullets) do
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
    return ( math.sqrt( ( c2.x-c1.x ) * ( c2.x-c1.x )  + ( c2.y-c1.y ) * ( c2.y-c1.y ) ) < ( c1.radius + c2.radius ) )
end

--utils
function find_player(id)
    for k, p in pairs(players) do
        if(p.id == id) then return p end
    end
    return nil
end
function find_ship(id)
    for k, s in pairs(ships) do
        if(s.id == id) then return s end
    end
    return nil
end
function bump(p1, p2, bounciness1, bounciness2)
    local bump_delay = 0.1
    if(p1.last_bump_time
        and p2.last_bump_time
        and
        (
        get_time() - p1.last_bump_time < bump_delay
        or get_time() - p2.last_bump_time < bump_delay
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
    local now = get_time()
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

function get_button(b, id)
    return btn(b + key_number * id)
end

function any_btn_for(id)
    return btn(key.left + key_number * id)
    or btn(key.right + key_number * id)
    or btn(key.up + key_number * id)
    or btn(key.down + key_number * id)
    or btn(key.x + key_number * id)
    or btn(key.y + key_number * id)
    or btn(key.a + key_number * id)
    or btn(key.b + key_number * id)
end

function any_btn()
    for i = 0, player_max_number do
        if(any_btn_for(i)) then return true end
    end
    return false
end

guid_counter = 0
function get_guid()
    local new_guid = guid_counter + 1
    guid_counter = guid_counter + 1
    return new_guid
end

function foreach(ls, fun)
    for k, v in pairs(ls) do
        fun(v)
    end
end

function del(ls, a)
    for k, v in pairs(ls) do
        if(v == a) then
            table.remove(ls, k)
            break
        end
    end
end
