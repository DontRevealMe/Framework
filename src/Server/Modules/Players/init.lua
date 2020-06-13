--[[
    Name: Players.lua
    Author: DontRevealMe
    Description: Adds more to Roblox's player service such as data binded to players.
--]]
local Players = game:GetService("Players")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local playerClass = require(script:WaitForChild("Player"))
local Ambassador = require("Ambassador")

local Module = {}
Module._bindedInfo = {}
Module._ambassadors = {}
-- Create initial remotes
Module._ambassadors.getBindedInfo = Ambassador.new("Framework.Server.Players.GetBindedInfo", "RemoteFunction")

Module._ambassadors.getBindedInfo:Connect(function(player, request)
    if player==players[tostring(request)] then 
        
    else 
        warn(player.Name, "may be exploiting")
    end
end)

return Module