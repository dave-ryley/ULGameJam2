pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--------------------------------------------------------------
-- global parameters
--------------------------------------------------------------
mode = "menu"
lasttime = time()
deltatime = 0
game_started = false
ended_game = false

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
    1, 2, 3, 4, 5, 6, 7, 8
}


rate_limiters = {}
buttonPress = 0
--------------------------------------------------------------
-- global functions
--------------------------------------------------------------
function play_sound(sound, channel)
    if type(sound) == "table" then
        local soundindex = flr(rnd(#sound) + 1)
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
    if buttonPress > 0 then
        buttonPress -= deltatime
    end
end

--------------------------------------------------------------
-- main game jam parameters
--------------------------------------------------------------
jam = {}

jam_width = 100
jam_height = 72
jam_block_size = 8
jam_populated = false
jam_offset_y = 24
jam_offset_x = 8
jam_sprites = {16, 17, 18, 19}
jam_score = 100

function jam_hash_func(vector)
    return flr((vector.x - jam_offset_x) / jam_block_size), flr((vector.y - jam_offset_y) / jam_block_size)
end

function populate_jam()
    if jam_populated then return end
    for y = 1, flr(jam_height/jam_block_size) do
        for x = 1, flr(jam_width/jam_block_size) do
            jam[x] = jam[x] or {}
            jam[x][y] = flr(rnd(4)) + 1
        end
    end
    jam_populated = true
end

function draw_jam()
    local no_jam_left = true
    for y = 1, flr(jam_height/jam_block_size) do
        for x = 1, flr(jam_width/jam_block_size) do
            if jam[x][y] ~= "empty" then
                no_jam_left = false
                spr(jam_sprites[jam[x][y]], x * jam_block_size + jam_offset_x, y * jam_block_size + jam_offset_y)
            end
        end
    end
    if no_jam_left then
        ended_game = true
        mode = "end"
    end
end

--------------------------------------------------------------
-- main menu loop
--------------------------------------------------------------
function menuloop() 
    if not jam_populated then
        music(5, 300, 3)
        populate_jam()
    end
    if btn(4) or btn(5) and buttonPress <= 0 then
        mode = "game"
        game_started = false
    end
end

function menudrawloop()
    cls()
    spr(64, 36, 36, 56, 28)
    print('~ ul gamejam 2 ~');
    print('theme: simplicity');
    print('\n++ credits ++\n')
    print('dave\ndarren\nbrian\njono')
end

--------------------------------------------------------------
-- main game functions
--------------------------------------------------------------
player1 = {} 
player1.speed = 5
player1.x = 1
player1.y = 1
player1.sprite = 1
player1.score = 0

player2 = {} 
player2.speed = 5
player2.x = 10
player2.y = 10
player2.sprite = 5
player2.score = 0

top_parameter = 36
bottom_parameter = 100
right_parameter = 108
left_parameter = 20 

--------------------------------------------------------------
-- game start
--------------------------------------------------------------

function game_start()
    sfx(9)
    music(0, 300, 3)
    jam_populated = false
    populate_jam()
    player1.score = 0
    player2.score = 0
    player1.x = flr(rnd(right_parameter - left_parameter) + left_parameter)
    player1.y = flr(rnd (bottom_parameter - top_parameter) + top_parameter)
    player2.x = flr(rnd(right_parameter - left_parameter) + left_parameter)
    player2.y = flr(rnd (bottom_parameter - top_parameter) + top_parameter)
    game_started = true
end

--------------------------------------------------------------
-- main game loop
--------------------------------------------------------------

function clamp_move(pos, speed, param)
    pos += speed
    if(param == left_parameter or param == top_parameter) then
        if(pos < param ) then
            pos = param
        end
    else
        if(pos > param) then
            pos = param
        end
    end
    return pos
end

function gameloop()
    if not game_started then
        game_start()
    end
    --player 1 movement
    if (btn(0,0) and player1.x > left_parameter) then
         player1.x = clamp_move(player1.x, -player1.speed,left_parameter)
        player1.sprite = 4
    end
    if (btn(1,0) and player1.x < right_parameter) then
        player1.x = clamp_move(player1.x, player1.speed, right_parameter)
        player1.sprite = 2
    end
    if (btn(2,0) and player1.y > top_parameter) then
        player1.y = clamp_move(player1.y, -player1.speed, top_parameter)
        player1.sprite = 1
    end
    if (btn(3,0) and player1.y < bottom_parameter) then
        player1.y = clamp_move(player1.y, player1.speed, bottom_parameter)
        player1.sprite = 3
    end

    local x, y = jam_hash_func(player1)
    if jam[x] and jam[x][y] ~= "empty" then
        play_rate_limited_sound(eating, 1, 0.3)
        player1.score += jam_score
        jam[x][y] = "empty"
    end
    
    --player 2 movement
    
    if (btn(0,1) and player2.x > left_parameter) then
        player2.x = clamp_move(player2.x, -player2.speed,left_parameter)
        player2.sprite = 8
    end
    if (btn(1,1) and player2.x < right_parameter) then
        player2.x = clamp_move(player2.x, player2.speed, right_parameter)
        player2.sprite = 6
    end
    if (btn(2,1) and player2.y > top_parameter) then
        player2.y = clamp_move(player2.y, -player2.speed, top_parameter)
        player2.sprite = 5
    end
    if (btn(3,1) and player2.y < bottom_parameter) then
        player2.y = clamp_move(player2.y, player2.speed, bottom_parameter)
        player2.sprite = 7
    end
    
    x, y = jam_hash_func(player2)
    if jam[x] and jam[x][y] ~= "empty" then
        play_rate_limited_sound(eating, 2, 0.3)
        player2.score += jam_score
        jam[x][y] = "empty"
    end
end

function gamedrawloop()
    cls()
    draw_jam()
    spr(player1.sprite,player1.x - 4,player1.y - 4)
    spr(player2.sprite,player2.x - 4,player2.y - 4)
    map(0,0,0,0,16,14)
end

--------------------------------------------------------------
-- main end screen loop
--------------------------------------------------------------
function endloop()
    if ended_game then
        ended_game = false
        music(-1)
    end
    if btn(4) or btn(5) then
        jam_populated = false
        mode = "menu"
        buttonPress = 300
    end
end

function enddrawloop()
    cls()
    winner={}
    if player1.score > player2.score then
        winner = player1
    elseif player2.score > player1.score then
        winner = player2
    end
    textlabels={"game over","wins!","score".." "..winner.score,"press button for menu"};
    print(textlabels[1],hcenter(textlabels[1]),vcenter(textlabels[1])-12,rnd(3)+7)
    spr(winner.sprite,hcenter(textlabels[2])-6,vcenter(textlabels[2]))
    print(textlabels[2],hcenter(textlabels[2])+6,vcenter(textlabels[2]),rnd(3)+7)
    print(textlabels[3],hcenter(textlabels[3]),vcenter(textlabels[3])+12,11)
    print(textlabels[4],hcenter(textlabels[4]),vcenter(textlabels[3])+24,12)
    color(7) -- reset color to white
end

--------------------------------------------------------------
-- main update loops
--------------------------------------------------------------
function _update()
    update_rate_limited_audio()
    update_delta_time()
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
        enddrawloop()
    end
end

--------------------------------------------------------------
-- helper functions
--------------------------------------------------------------

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
 
function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end