pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

mode = "menu"
--------------------------------------------------------------
-- Main Menu Loop
--------------------------------------------------------------
function menuLoop()
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

--------------------------------------------------------------
-- Main Game Loop
--------------------------------------------------------------
function gameLoop()
    speed = 5
    playerX = 1
    playerY = 1
    topRightPerameter = 0 
    bottomLeftPerameter = 0 -- dont know perameters yet 

    if (btn(0) and playerX > bottomLeftPerameter) then playerX -= speed end
    if (btn(1) and plyerX < topRightPerameter) then playerX += speed end
    if (btn(2) and playerY < topRightPerameter) then playerY += speed end
    if (btn(3) and playerY > bottomLeftPerameter) then playerY -= speed end
    -- Draw a sprite
    if btn(4) then 
        mode = "end"
    end
end

--------------------------------------------------------------
-- Main End Screen Loop
--------------------------------------------------------------
function endLoop()
    cls()
    print("Game Over");
    if btn(4) or btn(5) then
        mode = "menu"
        cls()
    end
end

--------------------------------------------------------------
-- Main Update Loop
--------------------------------------------------------------
function _update()
    if mode == "menu" then
        menuLoop()
    elseif mode == "game" then
        gameLoop()
    elseif mode == "end" then
        endLoop()
    end
end