--[[
    Name: Queue.lua
    Author: DontRevealMe
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")

local Queue = {}
Queue.__index = Queue

function Queue:SetUpdater()

end

function Queue:Enqueue(data)

end

function Queue:Dequeue(index)

end

function Queue.new()
    local self = {}
    setmetatable(self, Queue)
    self._wakeUp = Signal.new()
    self.Updater = coroutine.create(function(current)
        while true do 

        end
    end)
    self._wakeUpCon = self._wakeUp.Event:Connect(function()
        
    end)
    return self
end

return Queue