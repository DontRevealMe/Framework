--[[
    Name: Queue.lua
    Author: DontRevealMe
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")

local Queue = {}
Queue.__index = Queue

function Queue:SetUpdater(func)
    self.Updater = func
end

function Queue:Enqueue(data)
    table.insert(self.Queue, 1, data)
    if #self.Queue == 1 then 
        self._wakeUp:Fire()
    end
end

function Queue:Dequeue(index)
    table.remove(self.Queue, index or #self.Queue)
end

function Queue.new()
    local self = {}
    setmetatable(self, Queue)
    self._wakeUp = Signal.new()
    self.Queue = {}
    self._updateCoroutine = coroutine.create(function()
        while true do 
            if #self.Queue == 0 or self["Updater"]==nil then 
                coroutine.yield()
            else
                local current = self.Queue[#self.Queue]
                local succ, err = pcall(self.Updater, current)
                if not succ then
                    warn(string.format("An unexpected error occoured at queue index %s. %q", #self.Queue, err))
                else
                    table.remove(self.Queue)
                end
            end
        end
    end)
    self._wakeUpCon = self._wakeUp.Event:Connect(function()
        coroutine.resume(self._updateCoroutine)
    end)
    return self
end

return Queue