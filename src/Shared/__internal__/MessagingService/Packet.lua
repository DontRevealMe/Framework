
local HttpService = game:GetService("HttpService")
local Utility = require(script.Parent:WaitForChild("Util"))
local Packet = {}
Packet.__index = Packet

function Packet:GetSize()
    return Utility:GetSize(self)
end

function Packet.new(data, topic)
    local self = {}
    setmetatable(self, Packet)
    self.Topic = topic
    self.Data = {
        Topic = topic,
        Data = data
    }
    self.Size = Utility:GetSize(self)
    return self
end

return Packet