--  Manages all SubChannelChannels
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")

local SubChannelChannelManager = {}
SubChannelChannelManager.__index = SubChannelChannelManager

function SubChannelChannelManager:Add(amount)

end

function SubChannelChannelManager:Remove(index)

end

function SubChannelChannelManager:Destroy()
    self._maid:DoCleaning()
    self = nil
end

function SubChannelChannelManager.new(name)
    local self = {}
    setmetatable(self, SubChannelChannelManager)
    self.Name = name
    self.SubChannelChannels = {}
    self._maid = Maid.new()
    self._onPacketRecived = Signal.new()
    self.OnPacketRecived = self._onPacketRecived.Event

    self._maid:GiveTask(self._onPacketRecived)

    return self
end

return SubChannelChannelManager