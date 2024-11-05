-- classes/Player.lua
Player = {}
Player.__index = Player

function Player:new()
    local self = setmetatable({}, Player)
    self.x = screenWidth / 2
    self.y = screenHeight / 2
    self.width = 40
    self.height = 40
    self.baseSpeed = 250
    self.acceleration = 0
    self.tail = {}
    return self
end

function Player:update(dt, multiplier)
    if love.keyboard.isDown("space") then
        self.acceleration = self.acceleration + accelerationRate * dt
    else
        self.acceleration = math.max(self.acceleration - decelerationRate * dt, 0)
    end

    local effectiveSpeed = self.baseSpeed * multiplier

    if love.keyboard.isDown("left") then
        self.x = self.x - effectiveSpeed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + effectiveSpeed * dt
    end
    if love.keyboard.isDown("up") then
        self.y = self.y - effectiveSpeed * dt
    elseif love.keyboard.isDown("down") then
        self.y = self.y + effectiveSpeed * dt
    end

    self.x = math.max(0, math.min(screenWidth - self.width, self.x))
    self.y = math.max(0, math.min(screenHeight - self.height, self.y))

    self:updateTail(dt, effectiveSpeed)
end

function Player:updateTail(dt, speed)
    table.insert(self.tail, 1, { x = self.x, y = self.y, opacity = 1.0 })

    for i, segment in ipairs(self.tail) do
        segment.opacity = segment.opacity - dt * speed / 300
        if segment.opacity <= 0 then
            table.remove(self.tail, i)
        end
    end
end

function Player:draw()
    for _, segment in ipairs(self.tail) do
        love.graphics.setColor(0, 0, 1, segment.opacity)
        love.graphics.rectangle("fill", segment.x, segment.y, self.width, self.height)
    end

    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end