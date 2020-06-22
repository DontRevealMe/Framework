--  Contains utlity variables and functions
--  @author DontRevealme

local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Queue = require("Queue")
local Signal = require("Signal")
local Configuration = require("Settings").MessagingService

local Util = {
    PacketQueue = Queue.new(),
    PublishQueue = Queue.new(),
    PacketBuffer = {},
    CurrentlyBoxing = {},
    PacketSegments = {},
    SubChannel = {
        OnPackedRecieved = Configuration.UseSubChannels and Signal.new(),
        Listeners = {},
        Connections = {}
    }
    Cache = {
        ChannelListener = {},
        SubChannelChannelManager = {}
    }
}

function Util:GetSize(...)
    local size = 0
    for _,v in pairs({...}) do
        size = size + (typeof(v)=="table" and HttpService:JSONEncode(v):len()) or (typeof(v)=="string" and v:len())
    end
    return size
end

return Util