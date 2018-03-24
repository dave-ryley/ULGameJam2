pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--------------------------------------------------------------
-- global parameters
--------------------------------------------------------------
mode = "menu"
lasttime = time()
deltatime = 0

function update_delta_time()
    local time = time()
    deltatime = time - lasttime
    lasttime = time
end

--------------------------------------------------------------
-- sfx parameters
--------------------------------------------------------------
eating =
{
    1, 2, 3
}
run = 5


rate_limiters = {}
--------------------------------------------------------------
-- global functions
--------------------------------------------------------------
function play_sound(sound, channel)
    if type(sound) == "table" then
        local soundindex = math.random(#sound)
        sfx(sound[soundindex], channel)
    else
        sfx(sound, channel)
    end
end

function play_rate_limited_sound(sound, channel, length)
    if not (rate_limiters[channel] and rate_limiters[channel] > 0) then
        rate_limiters[channel] = length
        play_sound(sound, channel)
    end
end

function update_rate_limited_audio()
    for i = 1, #rate_limiters do
        if rate_limiters[i] > 0 then
            rate_limiters[i] -= deltatime
        end
    end
end

--------------------------------------------------------------
-- main game jam parameters
--------------------------------------------------------------
jam = {}

jam_width = 100
jam_height = 100
jam_block_size = 6
jam_populated = false
jam_offset = 10
jam_sprite = 1
jam_score = 100

function jam_hash_func(vector)
    return (vector.x - jam_offset) % jam_block_size, (vector.y - jam_offset) % jam_block_size
end

function populate_jam()
    for y = 0, jam_height, jam_block_size do
        for x = 0, jam_width, jam_block_size do
            jam[x] = jam[x] or {}
            jam[x][y] = "full"
        end
    end
    jam_populated = true
end

function draw_jam()
    for y = 0, jam_height, jam_block_size do
        for x = 0, jam_width, jam_block_size do
            if jam[x][y] == "full" then
                spr(jam_sprite, x + jam_offset, y + jam_offset)
            end
        end
    end
end

--------------------------------------------------------------
-- main menu loop
--------------------------------------------------------------
function menuloop()
    cls()
    populate_jam()
    print('~ ul gamejam 2 ~');
    print('theme: simplicity');
    print('\n++ credits ++\n')
    print('dave\ndarren\nbrian\njono')
    if btn(4) or btn(5) then
        mode = "game"
        cls()
    end
end

function menudrawloop()

end

--------------------------------------------------------------
-- main game functions
--------------------------------------------------------------

speed = 5
player1x = 1
player1y = 1
player2x = 10
player2y = 10
topleftperameter = 5
bottomrightperameter = 20 -- dont know proper perameters yet 

--------------------------------------------------------------
-- game start
--------------------------------------------------------------

function game_start()
    jam_populated = false
    populate_jam()
end

--------------------------------------------------------------
-- main game loop
--------------------------------------------------------------

function clamp_move_topleft(pos, speed)
    pos += speed
    if(pos < topleftperameter ) then
        pos = topleftperameter
    end
    return pos
end

function clamp_move_bottomright(pos, speed)
    pos += speed
    if(pos > bottomrightperameter) then
        pos = bottomrightperameter
    end
    return pos
end

function gameloop()
    --player 1 movement
    if (btn(0,0) and player1x > topleftperameter) then player1x = clamp_move_topleft(player1x, -speed) end
    if (btn(1,0) and player1x < bottomrightperameter) then player1x = clamp_move_bottomright(player1x, speed) end
    if (btn(2,0) and player1y > topleftperameter) then player1y = clamp_move_topleft(player1y, -speed) end
    if (btn(3,0) and player1y < bottomrightperameter) then player1y = clamp_move_bottomright(player1y, speed) end

    local x, y = jam_hash_func(player1)
    if jam[x][y] == "full" then
        player1.score += jam_score
        jam[x][y] == "empty"
    end

    --player 2 movement
    
    if (btn(0,1) and player2x > topleftperameter) then player2x = clamp_move_topleft(player2x, -speed) end
    if (btn(1,1) and player2x < bottomrightperameter) then player2x = clamp_move_bottomright(player2x, speed) end
    if (btn(2,1) and player2y > topleftperameter) then player2y = clamp_move_topleft(player2y, -speed) end
    if (btn(3,1) and player2y < bottomrightperameter) then player2y = clamp_move_bottomright(player2y, speed) end
    
    x, y = jam_hash_func(player2)
    if jam[x][y] == "full" then
        player2.score += jam_score
        jam[x][y] == "empty"
    end

    -- if btn(4) then 
    --     mode = "end"
    -- end
end

function gamedrawloop()
    cls()
    draw_jam()
    spr(1,player1x,player1y)
    spr(2,player2x,player2y)
end
--------------------------------------------------------------
-- main update loops
--------------------------------------------------------------
function _update()
    
    update_delta_time()
    update_rate_limited_audio()

    if mode == "menu" then
        menuloop()
    elseif mode == "game" then
        gameloop()
    elseif mode == "end" then
        endloop()
    end
end

function _draw()
    if mode == "menu" then
        menudrawloop()
    elseif mode == "game" then
        gamedrawloop()
    elseif mode == "end" then
        -- enddrawloop()
    end
end