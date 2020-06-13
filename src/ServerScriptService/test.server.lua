--[[local framework = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))


local Network = framework.Server.Network


Network:Listen({
    Client = {
        Class = "RemoteEvent",
        Run = function()

        end
    }
}, )--]]
--[[local maze = require(script.Parent:WaitForChild("MazeGenerator"))
local gen = maze:Init(100,100)
gen:Generate()--]]
--[[
local module = require(script.Parent:WaitForChild("TerrainGeneration"))
module.new(100, 50, 100)--]]
--[[
local mazeGen = require(script.Parent.MazeGenerator)
local maze = mazeGen:Init(50, 50)

for _,player in pairs(game:GetService("Players"):GetPlayers()) do 
    local character = player.Character or player.CharacterAdded:Wait()
    character:MoveTo(Vector3.new(100,100,100))
end--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Ambassador = require("Ambassador")
local DataStoreService = require("DataStoreService")

local newEvent = Ambassador.new("test123", "RemoteFunction")
newEvent:Connect(function(...)
    print("Server got", ...)
    return "Hello, world!"
end)
--[[
local DataStore = DataStoreService.new("testing123", "testing123", nil, nil, "OrderedBackups")
DataStore:BindToPlayer(game.Players:WaitForChild("DontRevealMe"))
local a,value,v = DataStore:GetAsync(tostring(math.random(1000, 9999))):await()
print(value, "before")
DataStore:Set(tostring(math.random(1000, 9999)))
print(DataStore:Get(), "after")
--]]