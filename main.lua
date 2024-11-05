-- main.lua
require("classes.Player")
require("classes.Star")
require("classes.Game")

function love.load()
    screenWidth, screenHeight = 800, 600
    accelerationRate, decelerationRate, multiplierThreshold = 50, 30, 200
    game = Game:new()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("Collect the Stars with OOP")
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if key == "r" and game.gameOver then
        game = Game:new()
    end
end