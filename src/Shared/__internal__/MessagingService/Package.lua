--  Class that contains a group of packets
--  @author DontRevealMe
local Utility = require(script.Parent:WaitForChild("Util"))

local Package = {}
Package.__index = Package

function Package:Send()

end

function Package:AddPacket(packet)

end

function Package:GetSize()
    self.Size = Utility:GetSize(unpack(self.Packets))
    return self.Size
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