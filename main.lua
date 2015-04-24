require "asteroid"
require "bullet"

local width = love.graphics.getWidth()
local height = love.graphics.getHeight() - 32
local max_asteroids = 10
local asteroids = {}
local bullets = {}
local fullscreen = false

function AddAsteroid(x,y,size,health,vx,vy)
   return table.insert(asteroids,Asteroid.create(x,y,width,height,size,health,vx,vy))
end

function CreateBullet(x,y)
   return table.insert(bullets,Bullet.create(x,y,width,height,angle))
end

function CheckCollisionBox(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function CheckCollisionCircle(x1,y1,radius1, x2,y2,radius2)
  return math.sqrt( ( x2-x1 ) * ( x2-x1 )  + ( y2-y1 ) * ( y2-y1 ) ) < ( radius1 + radius2 )
end

function CheckAsteroidCollision(asteroid1, asteroid2)
   return CheckCollisionCircle(asteroid1.x,asteroid1.y,asteroid1.size,asteroid2.x,asteroid2.y,asteroid2.size)
end

function CheckShipCollision(asteroid)
   return CheckCollisionCircle(x,y+20,24,asteroid.x,asteroid.y,asteroid.size)
end

function love.keypressed(key)
   if key == "f" then
      fullscreen = not fullscreen
      love.window.setFullscreen(fullscreen,"desktop")
      width = love.graphics.getWidth()
      height = love.graphics.getHeight() - 32
      if love.system.getOS() == "OS X" then
         love.window.toPixels(width,height)
      end
   elseif key == "escape" then
      love.event.quit()
   end
end

function restart()
   lives = 3
   pos = 1
   for key, bullet in ipairs(bullets) do
      table.remove(bullets,pos)
      pos = pos + 1
   end
   pos = 1
   for key, asteroid in ipairs(asteroids) do
      table.remove(asteroids,pos)
      pos = pos + 1
   end
   x, y = width/2, height/2
end

function love.load()
   x, y = width/2, height/2
   friction = 0.05
   acceleration_rate = 0.2
   speed = 0
   turn_rate = 0.06
   max_speed = 3
   angle = 0
   lives = 3
   shoot = true
   score = 0

   font = love.graphics.newFont("VT323.ttf",30)
   font:setFilter("nearest","nearest",-1)
   love.graphics.setFont(font)
end

function love.update()

   if lives <= 0 then
      restart()
   end

   -- deaccelerate
   speed = speed - friction

   if speed > max_speed then
      speed = max_speed
   elseif speed < 0 then
      speed = 0
   end
   -- convert angular movement to (x,y)
   x = x + (speed * math.cos(angle))
   y = y + (speed * math.sin(angle))

   -- update the asteroids and check their collisions
   pos = 1
   for key, asteroid in ipairs(asteroids) do
      asteroid:update()
      for key, asteroid2 in ipairs(asteroids) do
         if CheckAsteroidCollision(asteroid,asteroid2) then
            asteroid:collide(asteroid2)
         end
      end
      if CheckShipCollision(asteroid) then
         lives = lives - 1
         table.remove(asteroids,pos)
      end

      bpos = 1
      for key, bullet in ipairs(bullets) do
         if CheckAsteroidCollision(bullet,asteroid) then
            table.remove(asteroids,pos)
            table.remove(bullets,bpos)
            if asteroid.health == 3 then
               score = score + 100
               for i=0,1 do
                  AddAsteroid(asteroid.x+math.random(100)-50,asteroid.y+math.random(100)-50,math.random(5)+10,1,math.random(5.0)-2.5,math.random(5.0)-2.5)
               end
            else
               score = score + 10
            end
         end
         bpos = bpos + 1
      end
      pos = pos + 1
   end

   -- update all the bullet positions
   pos = 1
   for key, bullet in ipairs(bullets) do
      if bullet.health < 0 then
         table.remove(bullets,pos)
      end
      bullet:update()
      if bullet.x > bullet.screen_width then
         bullet.x = 0
      elseif bullet.x < 0 then
         bullet.x = width
      elseif bullet.y > bullet.screen_height then
         bullet.y = 0
      elseif bullet.y < 0 then
         bullet.y = height
      end
      pos = pos + 1
   end
   -- rotate the ship
   if love.keyboard.isDown("left") then
      angle = angle - turn_rate
   elseif love.keyboard.isDown("right") then
      angle = angle + turn_rate
   end

   -- accelerate the ship
   if love.keyboard.isDown("up") then
      speed = speed + acceleration_rate
   end

   if love.keyboard.isDown("z") then
      if shoot == true then
         CreateBullet(x,y)
         shoot = false
      end
   elseif not love.keyboard.isDown("z") then
      shoot = true
   end

   -- loop the ship around the screen
   if x > width then
      x = 0
   elseif x < 0 then
      x = width
   elseif y > height then
      y = 0
   elseif y < 0 then
      y = height
   end

   -- create asteroids
   if table.getn(asteroids) < max_asteroids then
      if math.random(1) == 1 then
         AddAsteroid(math.random(width),math.random(height),math.random(15)+25,3,math.random(3.0)-1.5,math.random(3.0)-1.5)
      end
   end

end

function love.draw()

   -- draw the ship
   love.graphics.setColor(255,255,255)
   love.graphics.push()
   love.graphics.translate(x,y)
   love.graphics.rotate(angle)
   love.graphics.translate(-x,-y)
   local verticies = {x,y-10,x,y+10,x+25,y}
   love.graphics.polygon("fill",verticies)
   love.graphics.pop()

   -- draw the asteroids
   for key, asteroid in ipairs(asteroids) do
      love.graphics. push()
      love.graphics.translate(asteroid.x,asteroid.y)
      love.graphics.rotate(asteroid.angle)
      love.graphics.translate(-asteroid.x,-asteroid.y)
      love.graphics.circle("fill",asteroid.x,asteroid.y,asteroid.size*1.2,5)
      love.graphics.pop()
   end

   -- draw the bullets
   for key, bullet in ipairs(bullets) do
      love.graphics. push()
      love.graphics.translate(bullet.x,bullet.y)
      love.graphics.rotate(bullet.angle)
      love.graphics.translate(-bullet.x,-bullet.y)
      love.graphics.circle("fill",bullet.x,bullet.y,bullet.size,3)
      love.graphics.pop()
   end

   love.graphics.setColor(188,188,188)
   love.graphics.polygon("fill",{0,height,width,height,width,height+32,0,height+32})
   love.graphics.setColor(0,0,0)
   love.graphics.print("SCORE: " .. score,8,height)
   love.graphics.print("LIVES: " .. lives,width-108,height)
   love.graphics.print("ASTEROIDS",width/2-54,height)

end
