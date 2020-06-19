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


function TopicListener:_invokeAllCallback(isCompleted, ...)
    for _,callback in pairs(self._listeners) do
        if (callback.completeOnly and isCompleted) or not callback.completeOnly then
            callback.callback(...)
        end
    end
end

function TopicListener:Destroy()
    self._maid:DoCleaning()
    self = nil
end

function TopicListener:Connect(getCompleteOnly, callbackFunc)
    return self.OnPacketRecivedSignal.Event:Connect(function(completed, ...)
        if (completed and getCompleteOnly) or not getCompleteOnly then
            callbackFunc(...)
        end
    end)
end

function TopicListener.new(topic, getIncomplete)
    local self = {}
    setmetatable(self, TopicListener)
    self.OnPacketRecivedSignal = Signal.new()
    self._maid = Maid.new()
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
                    self.OnPacketRecivedSignal:Fire(true, HttpService:JSONDecode(buildPacket), timeSent)
                end
            end
            if not packet["UID"] or getIncomplete then
                self.OnPacketRecivedSignal:Fire(not packet["UID"], packet.Data, timeSent)
            end
        end
    end)

    self._maid:GiveTask(self.Connection)
    self._maid:GiveTask(self.Signal)

    return self
end

return TopicListener