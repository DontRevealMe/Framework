--  Class that contains a group of packets
--  @author DontRevealMe
local Utility = require(script.Parent:WaitForChild("Util"))

local Package = {}
Package.__index = Package

function Package:Send(dontReplace)
    Utility.PublishQueue:Enqueue(self)
    if not dontReplace then
        Utility.CurrentlyBoxing[self.Topic] = Package.new(self.Topic)
    end
end

function Package:AddPacket(packet, check)
    if check and self:GetSize() + packet:GetSize() >= 900 then
        return false
    end
    table.insert(self.Packets, packet)
    return true
end

function Package:GetSize()
    local dataList = {}
    for _,v in pairs(self.Packets) do
        table.insert(dataList, v.Data)
    end
    self.Size = Utility:GetSize(unpack(dataList))
    return self.Size
end

function Package:FireAllResponses(...)
    for _,packet in pairs(self.Packets) do
        packet.Response:Fire(...)
    end
end

function Package:Destroy()
    for _,packet in pairs(self.Packets) do
        packet:Destroy()
    end
    if Utility.CurrentlyBoxing[self.Topic]==self then
        Utility.CurrentlyBoxing[self.Topic] = nil
    end
    self = nil
end

function Package.new(topic)
    local self = {}
    setmetatable(self, Package)
    self.Topic = topic
    self.Packets = {}
    self.Size = Utility:GetSize(self.Packets)
    Utility.CurrentlyBoxing[topic] = self
    return self
end

return Package