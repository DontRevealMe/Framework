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

function TopicListener:_invokeAllCallback(...)
    for _,callback in pairs(self._callBackTable) do
        callback(...)
    end
end

function TopicListener.new(topic, getIncomplete, callbackFunc)
    if TopicListener._cache[topic] then
        --  Check cache
        table.insert(TopicListener._cache[topic]._callBackTable, callbackFunc)
        return TopicListener._cache[topic]
    end
    local self = {}
    setmetatable(self, TopicListener)
    self.Connection = MessagingService:SubscribeAsync(topic, function(package, timeSent)
        package = HttpService:JSONDecode(package)
        print("Delay was " .. tostring(os.time() - timeSent))
        for _,packet in pairs(package.Packets) do
            if packet["UID"] then
                -- Segment packet
                local segment = Utility.PacketSegments[packet.UID] or {
                    Packets = {},
                    Max = nil
                }
                local order, max = string.split(packet.Order)
                order, max = tonumber(order), tonumber(max)
                table.insert(segment.Packets, packet.Order, packet.Data)
                Utility.PacketSegments[packet.UID] = segment
                if #Utility.PacketSegments[packet.UID].Segments==max then
                    self:_invokeAllCallback(packet.Data, timeSent)
                end
            end
            if not packet["UID"] or getIncomplete then
                self:_invokeAllCallback(packet.Data, timeSent)
            end
        end
    end)
    self.Signal = Signal.new()
    self._callBackTable = {callbackFunc}
    return self
end

return TopicListener