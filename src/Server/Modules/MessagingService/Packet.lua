--  Packet class
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Utility = require(script.Parent:WaitForChild("Util"))
local Packet = {}
Packet.__index = Packet

function Packet:GetSize()
    return Utility:GetSize(self.Data)
end

function Packet:Destroy()
    self.Response:Destroy()
    self = nil
end

function Packet.new(data, name)
    local self = {}
    setmetatable(self, Packet)
    self.Name = name
    self.Data = {
        Data = data
    }
    self.Size = self:GetSize()
    self.Response = Signal.new()
    return self
end

return Packet