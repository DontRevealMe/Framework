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
function Queue:SetUpdater(handleRemoval, func)
    self.Updater = func
    self._handleRemoval = handleRemoval or true
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
    The status of the coroutine loop.
    @returns [t:string] status
**--]]
function Queue:Status()
    return coroutine.status(self._updateCoroutine)
end

--[[**
    Deletes the queue and stops everything.
    @returns [t:void]
**--]]
function Queue:Destroy()
    self._wakeUpCon:Disconnect()
    self.Queue = {}
    self._updateCoroutine = nil
    self.WakeUp:Destroy()
    self = nil
end

--[[**
    Creates a new queue class
    @returns [t:Queue]
**--]]
function Queue.new()
    local self = {}
    setmetatable(self, Queue)
    self.WakeUp = Signal.new()
    self.Queue = {}
    self._handleRemoval = true
    self._updateCoroutine = coroutine.create(function()
        while true do 
            if self==nil or #self.Queue == 0 or self["Updater"]==nil then 
                coroutine.yield()
            else
                local current = self.Queue[#self.Queue]
                local succ, err = pcall(self.Updater, current)
                if not succ then
                    warn(string.format("An unexpected error occoured at queue index %s. %q", #self.Queue, err))
                elseif self._handleRemoval then
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