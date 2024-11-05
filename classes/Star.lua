-- classes/Star.lua
Star = {}
Star.__index = Star

function Star:new()
    local self = setmetatable({}, Star)
    self.x = math.random(20, screenWidth - 20)
    self.y = math.random(20, screenHeight - 20)
    self.radius = 15
    self.spawnTime = love.timer.getTime()
    return self
end

function Star:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end
