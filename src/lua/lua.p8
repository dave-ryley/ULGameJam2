pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

mode = "menu"
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
function gameloop()
    speed = 5
    playerx = 1
    playery = 1
    toprightperameter = 0 
    bottomleftperameter = 0 -- dont know perameters yet 

    if (btn(0) and playerx > bottomleftperameter) then playerx -= speed end
    if (btn(1) and plyerx < toprightperameter) then playerx += speed end
    if (btn(2) and playery < toprightperameter) then playery += speed end
    if (btn(3) and playery > bottomleftperameter) then playery -= speed end
    -- draw a sprite
    if btn(4) then 
        mode = "end"
    end
end

function gamedrawloop()

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