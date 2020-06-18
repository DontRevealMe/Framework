
local HttpService = game:GetService("HttpService")
local Utility = require(script.Parent:WaitForChild("Util"))
local Packet = {}
Packet.__index = Packet

function Packet.new(data, topic)
    local self = {}
    setmetatable(self, Packet)
    self.Topic = topic
    self.Data = {
        Topic = topic,
        Data = data
    }
    self.Size = Utility:GetSize(self.Data)
    return self
end

return Packet