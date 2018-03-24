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
__gfx__
00000000003993000900900009999990000900900071170001001000011111100001001077777777dddddddd0000000000000000000000000000000000000000
00000000009aa9009999990099aaaa9900999999001cc1001111110011cccc110011111177777777dddddddd0000000000000000000000000000000000000000
00700700099aa9909aaaa99309aaaa90399aaaa9011cc1101cccc11701cccc10711cccc177777777dddddddd0000000000000000000000000000000000000000
0007700099aaaa999aaaaaa909aaaa909aaaaaa911cccc111cccccc101cccc101cccccc177777777dddddddd0000000000000000000000000000000000000000
0007700009aaaa909aaaaaa999aaaa999aaaaaa901cccc101cccccc111cccc111cccccc177777777dddddddd0000000000000000000000000000000000000000
0070070009aaaa909aaaa993099aa990399aaaa901cccc101cccc117011cc110711cccc177777777dddddddd0000000000000000000000000000000000000000
0000000099aaaa9999999900009aa9000099999911cccc1111111100001cc1000011111177777777dddddddd0000000000000000000000000000000000000000
00000000099999900900900000399300000900900111111001001000007117000001001077777777dddddddd0000000000000000000000000000000000000000
8888888e888888e88e8e8888888e8888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e8e8e8888e8e8e88888e8eee88888e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888e88e88888e88eeee88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e88e88e8eeee888e8e8e88888ee8888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888e888888e888888888e888e88e8e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e8e88888e88888e888e8ee8888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888e8e888e88e8888e888888e8e88e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e88e8888888e88e8888888e88888ee88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000288800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000002288800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000002288800000000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000288880000008888888000000000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000228e80000088888e888000000888e8888008888000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002888800008e8828888000008e888888888888e800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002288800008882222888000088888888e888888880000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002888800088820028880000888822888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002888800088220008880000e88220288882288880000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000028888000882000088880008880002e8882228880000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000288e80008822000888800088800028882002e880000000000000000000000000000000000000000000000000000000000000000000000000000000
88800000002888800088820008888000888000288820028880000000000000000000000000000000000000000000000000000000000000000000000000000000
88800000008888800088820088888000888200282220028880000000000000000000000000000000000000000000000000000000000000000000000000000000
e880000000888880088e888888e88000888200222000088880000000000000000000000000000000000000000000000000000000000000000000000000000000
888800000888882008888888888888008e822000000008e820000000000000000000000000000000000000000000000000000000000000000000000000000000
88888808888e82200888888888888800888820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000
8e8e8888888882008888822222888880888820000000888820000000000000000000000000000000000000000000000000000000000000000000000000000000
28888888888822008888200002288e80288822000000e88820000000000000000000000000000000000000000000000000000000000000000000000000000000
228e88888882200088e8000000288888228882000000888200000000000000000000000000000000000000000000000000000000000000000000000000000000
0222888822220008888800000022888802e822000000888200000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222200000088888000000028882022220000000888208e80000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000008888200000002222200000000000028220e880000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000022220000000000220000000000000222088820000000000000000000000000000000000000000000000000000000000000000000000000000
00000006660000000000000000000000000000000000000082220000000000000000000000000000000000000000000000000000000000000000000000000000
0006666cccc066000000066666600000666600066000000022066600000000000000000000000000000000000000000000000000000000000000000000000000
006cccccccc1cc00066016ccccc00006cccc0016cc006606606ccc00000000000000000000000000000000000000000000000000000000000000000000000000
00ccc1cc1101cc001cc01ccc1100001cc110006c1c01cc6cc1cc1000000000000000000000000000000000000000000000000000000000000000000000000000
001111cc0001cc666cc01ccccc00001cc1cc01c10c01ccccc1cccc00000000000000000000000000000000000000000000000000000000000000000000000000
000001cc0001ccccccc011cc1000001cc11c06ccccc1c1c1c1cc1000000000000000000000000000000000000000000000000000000000000000000000000000
000001cc0001cc111cc601cc6666001ccccc1cc11cc1c1c1c1ccccc0000000000000000000000000000000000000000000000000000000000000000000000000
000001cc0001cc000ccc01cccccc0011cccc1cc01cc1c011c11cccc0000000000000000000000000000000000000000000000000000000000000000000000000
00000111000111000111011111100001111011101111100110111100000000000000000000000000000000000000000000000000000000000000000000000000

__gff__

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0a0a0a0a0a0a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000090b00000000000000000b091c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009090b00000000000000000b09090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a090b000000000000000000000b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a090b0000000000000000001c0b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a090b00000000001c1c1c1c1c0b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a090b001c1c1c1c1c1c1c1c1c0b090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a09090909090909090909090909092a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
01020000060500605007050090500b0500d05011050120501305013050130501305011050100500c0500705003050010500000000000000000000000000000000000000000000000000000000000000000000000
01020000010700b07007070010700a07007070030700f070080700a07007070010700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000307006070090700e0700107004070090700e0700000005070080700e0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000317002170021700317005170081700c1700f170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000000002170051700717009170081700417001170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000000000061700a1700c170051700a1700d170041700b1700d17000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000055700a5700e57007570055700c5700857001570135700757007570005000050000500005000050000400004000040000000000000000000000000000000000000000000000000000000000000000000
01020000025700457006570085700a5700c5700e5700c570095700357001570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000857006570025700a57004570015700957005570015700a700067000270001700000000b7000870006700027000170000000000000000000000000000000000000000000000000000000000000000000
01020000077500e75005750167500a750187500c7501b7500e7501c7501d7500d7501e7500f750227502375023750237500000000000000000000000000000000000000000000000000000000000000000000000
00020000287501375023750137501e750107501a7500b750157500a750127500875010750067500d750047500a750017500675001750000000000000000000000000000000000000000000000000000000000000
010f0000181311a1311c1311d1311f1311a131181311d000200002200023000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01160000107031c5001a5001c50010003000000000000000100030000000000000001000300000000000000010003000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001950019500185001750000000185003450016500385000000015500000000000000000155000000000000000001550000000155000000015500155001450014500155001550015500165001650016500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019000000000000000000000000000000000000000000000000000000000000000
01220000150501305011050100500e05010050150441505200000150521505200000150501305011050100500e050100501105411052000001105211052000000000000000000000000000000000000000000000
0110000c0e0650e063000031706517063000031006510063000031706517063000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000c1c0501a050000001c0501a050000002305023050000002405023050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110010d000001a0451a0451a0451a04500000170451a0451a0451a0451a045000031704500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800101a3221c3221d322000001c322000001a3221a3211c3231c3221d322213221c3221d3221a3220000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800100573300000057330000005733000000573300000057330000005733000000573300000057330000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180010181311a1311c1311d1311f131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110010d0000018065180651806518065000001506518065180651806518065000001506500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110002017060000001a0601a0600000000000230602306000000000001f0601f060000001a542000000000017060000001a0601a0600000000000230602306000000000001f0601f06000000000000000000000
001000000000000000000000000000000000001a0601a06000000000002406024060000001a06000000000000000000000170601706000000000000e0600e0600000000000130601306000000000000000000000
001000001a0600000023060000002306000000230600000023060000002406024060000002606000000000001a0600000023060000002306000000230600000023060000001f0601f06000000000000000000000
001000000000000000170600000000000000001706000000000000000018542185420000000000000000000000000000001706000000000000000017060000000000000000130601306000000000000000000000

__music__
00 1d214344
01 1d211f40
02 1d1f2544
00 41424344
03 22236444
01 41262768
02 41282944