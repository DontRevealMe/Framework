--  Class that manages the listening of a topic
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Utility = require(script.Parent:WaitForChild("Util"))

local TopicListener = {}
TopicListener.__index = TopicListener

local function GetSegment(UID)
    if not Utility.PacketSegments[UID] then
        Utility.PacketSegments[UID] = {
            Packets = {},
            Max = nil
        }
    end
    return Utility.PacketSegments[UID]
end

function TopicListener.new(topic, getIncomplete, callbackFunc)
    local self = {}
    setmetatable(self, TopicListener)
    self.Connection = MessagingService:SubscribeAsync(topic, function(package, timeSent)
        package = HttpService:JSONDecode(package)
        print("Delay was " .. tostring(os.time() - timeSent))
        for _,packet in pairs(package.Packets) do
            if packet["UID"] then
                -- Segment packet
                local segment = GetSegment(packet.UID)
                table.insert(segment.Packets, packet.Order, packet.Data)
                Utility.PacketSegments[packet.UID] = segment
                if Utility
            end
            if not packet["UID"] or getIncomplete then
                self._callBack(packet.Data, timeSent)
            end
        end
    end)
    self.Signal = Signal.new()
    self._callBack = callbackFunc
    return self
end

return TopicListener