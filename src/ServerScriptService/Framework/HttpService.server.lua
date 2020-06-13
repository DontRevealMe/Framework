--[[
    Name: HttpService.server.lua
    Author: DontRevealMe
    Description: Updates queue
--]]
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Module = require("HttpService")

Module._queueData.wakeQueue.Event:Connect(function()
    while #Module._queueData.queue > 0 do
        if tick() - Module._queueData.lastReset >= 60 then 
            Module._queueData.totalRequests = 0
        end
        if Module._queueData.totalRequests < 500 then
            local current = Module._queueData.queue[#Module._queueData.queue]
            local succ, response = pcall(function()
                return HttpService:RequestAsync(current.Data)
            end)
            table.remove(Module._queueData.queue, #Module._queueData.queue)
            current.Response(succ, response)
            Module._queueData.requestsMade = Module._queueData.requestsMade + 1
        end
    end
end)