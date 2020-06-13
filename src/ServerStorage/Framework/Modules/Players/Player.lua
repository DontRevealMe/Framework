--[[
    Name: Player.lua
    Author: DontRevealMe
    Description: Provides player class
--]]

local Player = {}
Player.__index = Player

function Player.new(playerInstance)
    local self = {}
    self.Instance = playerInstance
    self.Name = playerInstance.Name
    self.UserId = playerInstance.UserId
    self.Tags = {}

    return self
end

return Player 