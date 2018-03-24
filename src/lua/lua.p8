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
player1 = {} 
player1.speed = 5
player1.x = 1
player1.y = 1
player1.sprite = 1

player2 = {} 
player2.speed = 5
player2.x = 10
player2.y = 10
player2.sprite = 5

topleftperameter = 5
bottomrightperameter = 20 -- dont know proper perameters yet 

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
    if (btn(0,0) and player1.x > topleftperameter) then
         player1.x = clamp_move_topleft(player1.x, -player1.speed)
        player1.sprite = 4
    end
    if (btn(1,0) and player1.x < bottomrightperameter) then
        player1.x = clamp_move_bottomright(player1.x, player1.speed)
        player1.sprite = 2
    end
    if (btn(2,0) and player1.y > topleftperameter) then
        player1.y = clamp_move_topleft(player1.y, -player1.speed)
        player1.sprite = 1
    end
    if (btn(3,0) and player1.y < bottomrightperameter) then
        player1.y = clamp_move_bottomright(player1.y, player1.speed)
        player1.sprite = 3
    end
    --player 2 movement
    
    if (btn(0,1) and player2.x > topleftperameter) then
        player2.x = clamp_move_topleft(player2.x, -player2.speed)
        player2.sprite = 8
    end
    if (btn(1,1) and player2.x < bottomrightperameter) then
        player2.x = clamp_move_bottomright(player2.x, player2.speed)
        player2.sprite = 6
    end
    if (btn(2,1) and player2.y > topleftperameter) then
        player2.y = clamp_move_topleft(player2.y, -player2.speed)
        player2.sprite = 5
    end
    if (btn(3,1) and player2.y < bottomrightperameter) then
        player2.y = clamp_move_bottomright(player2.y, player2.speed)
        player2.sprite = 7
    end
    
    if btn(4) then 
        mode = "end"
    end
end

function gamedrawloop()
    cls()
    spr(player1.sprite,player1.x,player1.y)
    spr(player2.sprite,player2.x,player2.y)
end

<<<<<<< HEAD
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

=======
function endloop()
end

function enddrawloop()
>>>>>>> f4e3bd429e22779b920aafe180889c5256b2fc44
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
