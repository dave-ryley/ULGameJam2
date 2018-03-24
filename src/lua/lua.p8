pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--------------------------------------------------------------
-- global parameters
--------------------------------------------------------------
mode = "menu"
lastTime = time()
deltaTime = 0

function update_delta_time()
    local time = time()
    deltaTime = time - lastTime
    lastTime = time
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
        local soundIndex = math.random(#sound)
        sfx(sound[soundIndex], channel)
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
            rate_limiters[i] -= deltaTime
        end
    end
end

--------------------------------------------------------------
-- main menu loop
--------------------------------------------------------------
function menuloop()
    cls()
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
-- main game loop
--------------------------------------------------------------

speed = 5
playerx = 1
playery = 1
toprightperameter = 200
bottomleftperameter = 0 -- dont know perameters yet 

function gameloop()
    
    if (btn(0) and playerx > bottomleftperameter) then playerx -= speed end
    if (btn(1) and playerx < toprightperameter) then playerx += speed end
    if (btn(2) and playery < toprightperameter) then playery += speed end
    if (btn(3) and playery > bottomleftperameter) then playery -= speed end
    -- draw a sprite
    if btn(4) then 
        mode = "end"
    end
end

function gamedrawloop()
    cls()
    spr(1,playerx,playery)
end

--------------------------------------------------------------
-- main end screen loop
--------------------------------------------------------------
function endloop()
    cls()
    print("game over");
    if btn(4) or btn(5) then
        mode = "menu"
        cls()
    end
end

function enddrawloop()

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
        enddrawloop()
    end
end