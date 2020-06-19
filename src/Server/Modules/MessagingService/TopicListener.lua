--  Class that manages the listening of a topic
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")
local Utility = require(script.Parent:WaitForChild("Util"))

local TopicListener = {}
TopicListener.__index = TopicListener
TopicListener._cache = {}

function TopicListener:Destroy()
    self._maid:DoCleaning()
    Utility.TopicListenerCache[self.Topic] = nil
    self = nil
end

function TopicListener:Connect(getCompleteOnly, callbackFunc)
    return self.OnPacketRecivedSignal.Event:Connect(function(completed, ...)
        if (completed and getCompleteOnly) or not getCompleteOnly then
            callbackFunc(...)
        end
    end)
end

function TopicListener.new(topic)
    local self = {}
    setmetatable(self, TopicListener)
    self.Topic = topic
    self.OnPacketRecivedSignal = Signal.new()
    self._maid = Maid.new()
    self.Connection = MessagingService:SubscribeAsync(topic, function(package)
        local timeSent = package.Sent
        package = HttpService:JSONDecode(package.Data)
        for _,packet in pairs(package) do
            local builtPacket = ""
            if packet["UID"] then
                -- Segment packet
                local segment = Utility.PacketSegments[packet.UID] or {}
                local order, max = string.split(packet.Order, "/"), nil
                order, max = tonumber(order[1]), tonumber(order[2])
                table.insert(segment, order, packet)
                Utility.PacketSegments[packet.UID] = segment
                if #Utility.PacketSegments[packet.UID]==max then
                    for _,pack in pairs(segment) do
                        builtPacket = builtPacket .. pack.Data
                    end
                    builtPacket = HttpService:JSONDecode(builtPacket)
                    self.OnPacketRecivedSignal:Fire(true, HttpService:JSONDecode(builtPacket), timeSent)
                end
            end
            self.OnPacketRecivedSignal:Fire(not packet["UID"] or builtPacket~="", builtPacket~="" or packet.Data, timeSent)
        end
    end)

    self._maid:GiveTask(self.Connection)
    self._maid:GiveTask(self.Signal)

    Utility.TopicListenerCache[topic] = self

    return self
end

return TopicListener