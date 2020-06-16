--[[
    Name: Queue.lua
    Author: DontRevealMe
--]]

local Queue = {}
Queue.__index = Queue


function Queue.new()
    local self = {}
    setmetatable(self, Queue)

    return self
end

return Queue