Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.create(x,y,screen_width,screen_height,size,health,vx,vy)
   local asteroid = {}             -- our new object
   setmetatable(asteroid,Asteroid)  -- make Asteroid handle lookup
   asteroid.size = size
   asteroid.x = x      -- initialize our object
   asteroid.y = y
   asteroid.vx = vx
   asteroid.vy = vy
   asteroid.health = health
   asteroid.screen_width = screen_width
   asteroid.screen_height = screen_height
   asteroid.angle = math.random(360)
   asteroid.speed = math.random(0.2)
   return asteroid
end

function Asteroid:update()
   self.x = self.x + (self.speed * self.vx)
   self.y = self.y + (self.speed * self.vy)
   if self.x > self.screen_width then
      self.x = 0
   elseif self.x < 0 then
      self.x = self.screen_width
   elseif self.y > self.screen_height then
      self.y = 0
   elseif self.y < 0 then
      self.y = self.screen_height
   end
   self.angle = self.angle + 0.01
end

function Asteroid:collide(asteroid)
   vx = self.vx
   vy = self.vy
   self.vx = -asteroid.vx
   self.vy = -asteroid.vy
   asteroid.vx = -vx
   asteroid.vy = -vy
   self.speed = -self.speed
end
