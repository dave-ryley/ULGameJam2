pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
cls()
print('~ ul gamejam 2 ~');
print('theme: simplicity');
print('\n++ credits ++\n')
print('dave\ndarren\nbrian\njono')

-- Brian's Code

speed = 5
playerX = 1
playerY = 1
topRightPerameter = 0 
bottomLeftPerameter = 0 -- dont know perameters yet 

if (btn(0) and playerX > bottomLeftPerameter then playerX -= speed end
if (btn(1) and plyerX < topRightPerameter) then playerX += speed end
if (btn(2) and playerY < topRightPerameter) then playerY += speed end
if (btn(3) and playerY > bottomLeftPerameter) then playerY -= speed end