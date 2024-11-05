-- classes/Game.lua
Game = {}
Game.__index = Game

function Game:new()
    local self = setmetatable({}, Game)
    self.player = Player:new()
    self.stars = {}
    self.score = 0
    self.gameTime = 60
    self.gameOver = false
    self.highestMultiplierReached = 1
    self.starSpawnInterval = 5
    self.starTimer = 0
    self.boosterPhases = 3
    self.boosterPhaseCount = 0
    self.boosterActive = false
    self.boosterDuration = 1
    self.boosterTimer = 0
    self.nextBoosterTime = math.random(10, 20)
    return self
end

function Game:update(dt)
    if self.gameOver then return end

    self.gameTime = self.gameTime - dt
    if self.gameTime <= 0 then
        self.gameTime = 0
        self.gameOver = true
        self:calculateFinalScore()
    end

    local multiplier = math.floor(self.player.acceleration / multiplierThreshold) + 1
    self.highestMultiplierReached = math.max(self.highestMultiplierReached, multiplier)
    self.player:update(dt, multiplier)

    if self.boosterActive then
        self.boosterTimer = self.boosterTimer + dt
        if self.boosterTimer >= self.boosterDuration then
            self.boosterActive = false
            self.boosterPhaseCount = self.boosterPhaseCount + 1
            self.nextBoosterTime = self.gameTime - math.random(5, 10)
            self.boosterTimer = 0
            self.stars = {}
        end
    else
        self.starTimer = self.starTimer + dt
        if self.starTimer >= self.starSpawnInterval then
            self.starTimer = 0
            self.stars = {}
            table.insert(self.stars, Star:new())
        end

        if self.boosterPhaseCount < self.boosterPhases and self.gameTime <= self.nextBoosterTime then
            self:startBoosterPhase()
        end
    end

    for i = #self.stars, 1, -1 do
        local star = self.stars[i]
        if self:checkCollision(self.player, star) then
            self.score = self.score + self:calculateStarScore(multiplier, star.spawnTime)
            table.remove(self.stars, i)
            if not self.boosterActive then
                table.insert(self.stars, Star:new())
            end
        end
    end
end

function Game:draw()
    if self.gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Game Over! Final Score: " .. self.score, 0, screenHeight / 2 - 20, screenWidth, "center")
        love.graphics.printf("Highest Multiplier Reached: x" .. self.highestMultiplierReached, 0, screenHeight / 2 + 20, screenWidth, "center")
        love.graphics.printf("Press 'R' to Play Again", 0, screenHeight / 2 + 60, screenWidth, "center")
    else
        self.player:draw()

        for _, star in ipairs(self.stars) do
            star:draw()
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Score: " .. self.score, 10, 10, screenWidth, "left")
        love.graphics.printf("Time: " .. math.ceil(self.gameTime), 10, 30, screenWidth, "left")
        love.graphics.printf("Multiplier: x" .. math.floor(self.player.acceleration / multiplierThreshold) + 1, 0, screenHeight / 2 - 20, screenWidth, "center")

        self:drawAccelerationBar()
    end
end

function Game:drawAccelerationBar()
    local barWidth = 200
    local barHeight = 20
    local barX = screenWidth - barWidth - 20
    local barY = 20

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    local fillWidth = (self.player.acceleration % multiplierThreshold) / multiplierThreshold * barWidth
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", barX, barY, fillWidth, barHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)

    local multiplier = math.floor(self.player.acceleration / multiplierThreshold) + 1
    love.graphics.print("x" .. multiplier, barX + barWidth + 10, barY)
end

function Game:startBoosterPhase()
    self.boosterActive = true
    self.boosterDuration = math.random(1, 3)
    self.stars = {}
    local starCount = math.random(1, 10)
    for i = 1, starCount do
        table.insert(self.stars, Star:new())
    end
end

function Game:calculateFinalScore()
    self.score = self.score + self.highestMultiplierReached * 50
end

function Game:calculateStarScore(multiplier, spawnTime)
    local timeBonus = math.max(1, 3 - (love.timer.getTime() - spawnTime)) * 10
    return 100 * multiplier + timeBonus
end

function Game:checkCollision(a, b)
    local distance = math.sqrt((a.x + a.width / 2 - b.x)^2 + (a.y + a.height / 2 - b.y)^2)
    return distance < b.radius + a.width / 2
end