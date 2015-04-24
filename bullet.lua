Bullet = {}
Bullet.__index = Bullet

function Bullet.create(x,y,screen_width,screen_height,angle)
   local bullet = {}             -- our new object
   setmetatable(bullet,Bullet)  -- make Bullet handle lookup
   bullet.x = x      -- initialize our object
   bullet.y = y
   bullet.screen_width = screen_width
   bullet.screen_height = screen_height
   bullet.angle = angle
   bullet.speed = 4
   bullet.size = 4
   bullet.health = 150
   return bullet
end

function Bullet:update()
   self.x = self.x + (self.speed * math.cos(self.angle))
   self.y = self.y + (self.speed * math.sin(self.angle))
   self.health = self.health - 1
end
