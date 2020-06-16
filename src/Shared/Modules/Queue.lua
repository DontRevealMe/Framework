--[[
    Name: Queue.lua
    Author: DontRevealMe
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")

local Queue = {}
Queue.__index = Queue
Queue.ClassName = "Queue"

--[[**
    The function that will be called upon when the next item in queue is ready.
    @param [t:Function] function
    @returns [t:void]
**--]]
function Queue:SetUpdater(func)
    self.Updater = func
end

--[[**
    Add an item to the queue.
    @param [t:Variant] data
    @returns [t:void]
**--]]
function Queue:Enqueue(data)
    table.insert(self.Queue, 1, data)
    if #self.Queue == 1 then 
        self._wakeUp:Fire()
    end
end

--[[**
    Removes an item from the queue
    @param [t:Number] index
    @returns [t:void]
**--]]
function Queue:Dequeue(index)
    table.remove(self.Queue, index or #self.Queue)
end

--[[**
    Wether or not the queue is running or not.
    @returns [t:void]
**--]]
function Queue:IsSleeping()
    return coroutine.status(self._updateCoroutine) == "suspended" or coroutine.status(self._updateCoroutine) == "dead"
end

--[[**
    Creates a new queue class
    @returns [t:Queue]
**--]]
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