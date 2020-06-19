--  Class that manages the listening of a topic
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Utility = require(script.Parent:WaitForChild("Util"))

local TopicListener = {}
TopicListener.__index = TopicListener
TopicListener._cache = {}

local function GetSegment(UID)
    if not Utility.PacketSegments[UID] then
        Utility.PacketSegments[UID] = {
            Packets = {},
            Max = nil
        }
    end
    return Utility.PacketSegments[UID]
end

function TopicListener:_invokeAllCallback(isCompleted, ...)
    for _,callback in pairs(self._callBackTable) do
        if (callback.completeOnly and isCompleted) or not callback.completeOnly then
            callback.callback(...)
        end
    end
end

function TopicListener.new(topic, getIncomplete, callbackFunc)
    if TopicListener._cache[topic] then
        --  Check cache
        table.insert(TopicListener._cache[topic]._callBackTable, {
            completeOnly = not getIncomplete, callback = callbackFunc
        })
        return TopicListener._cache[topic]
    end
    local self = {}
    setmetatable(self, TopicListener)
    self.Signal = Signal.new()
    self._callBackTable = {
        {completeOnly = not getIncomplete, callback = callbackFunc}
    }
    self.Connection = MessagingService:SubscribeAsync(topic, function(package)
        local timeSent = package.Sent
        package = HttpService:JSONDecode(package.Data)
        for _,packet in pairs(package) do
            if packet["UID"] then
                -- Segment packet
                local segment = Utility.PacketSegments[packet.UID] or {}
                local order, max = string.split(packet.Order, "/"), nil
                order, max = tonumber(order[1]), tonumber(order[2])
                table.insert(segment, order, packet)
                Utility.PacketSegments[packet.UID] = segment
                if #Utility.PacketSegments[packet.UID]==max then
                    local buildPacket = ""
                    for _,pack in pairs(segment) do
                        buildPacket = buildPacket .. pack.Data
                    end
                    self:_invokeAllCallback(true, HttpService:JSONDecode(buildPacket), timeSent)
                end
            end
            if not packet["UID"] or getIncomplete then
                self:_invokeAllCallback(not packet["UID"], packet.Data, timeSent)
            end
        end
    end)
    return self
end

return TopicListener