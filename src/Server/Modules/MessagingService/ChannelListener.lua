--  Class that manages the listening of a channel
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")
local Utility = require(script.Parent:WaitForChild("Util"))

local ChannelListener = {}
ChannelListener.__index = ChannelListener
ChannelListener._cache = {}

function ChannelListener:Destroy()
    self._maid:DoCleaning()
    Utility.Cache.ChannelListener[self.Name] = nil
    self = nil
end

function ChannelListener:Connect(getCompleteOnly, callbackFunc)
    return self.OnPacketRecivedSignal.Event:Connect(function(completed, packet, timeStamp)
        if (completed and getCompleteOnly) or not getCompleteOnly then
            callbackFunc(packet.Data, timeStamp, packet)
        end
    end)
end

function ChannelListener.new(name)
    local self = {}
    setmetatable(self, ChannelListener)
    self.Name = name
    self.OnPacketRecivedSignal = Signal.new()
    self._maid = Maid.new()
    self.Connection = MessagingService:SubscribeAsync(name, function(package)
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
                    local builtPacket = ""
                    for _,pack in pairs(segment) do
                        builtPacket = builtPacket .. pack.Data
                    end
                    builtPacket = HttpService:JSONDecode(builtPacket)
                    self.OnPacketRecivedSignal:Fire(true, HttpService:JSONDecode(builtPacket), timeSent)
                    packet.Data = builtPacket
                    packet.SegmentCompleted = true
                end
            end
            self.OnPacketRecivedSignal:Fire(not packet["UID"] or packet.SegmentCompleted, (packet.SegmentCompleted~="" and packet) or packet, timeSent)
        end
    end)

    self._maid:GiveTask(self.Connection)
    self._maid:GiveTask(self.OnPacketRecivedSignal)

    Utility.Cache.ChannelListener[name] = self

    return self
end

return ChannelListener