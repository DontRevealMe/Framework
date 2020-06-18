--  Contains utlity variables and functions
--  @author DontRevealme

local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Queue = require("Queue")

local Util = {
    PacketQueue = Queue.new(),
    PublishQueue = Queue.new()
}

function Util:GetSize(...)
    local size = 0
    for _,v in pairs({...}) do
        size = size + (typeof(v)=="table" and (v["Size"] or HttpService:JSONEncode(v):len())) or (typeof(v)=="string" and v:len())
    end
    return size
end

return Util