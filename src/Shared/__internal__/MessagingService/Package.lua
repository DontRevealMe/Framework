--  Class that contains a group of packets
--  @author DontRevealMe
local Utility = require(script.Parent:WaitForChild("Util"))

local Package = {}
Package.__index = Package

function Package:Send()

end

function Package:AddPacket()

end

function Package:GetSize()
    local size = 0
    for _,packet in pairs(self.Packets) do
        size = size + Utility:GetSize(packet)
    end
    self.Size = size
    return size
end

function Package.new(topic)
    local self = {}
    self.Topic = topic
    self.Packets = {}
    self.Size = Utility:GetSize(self.Packets)
    Utility.CurrentlyBoxing[topic] = self
    return self
end

return Package