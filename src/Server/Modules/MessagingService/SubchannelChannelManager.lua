--  Manages all SubChannelChannels
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")
local ChannelListener = require(script.Parent:WaitForChild("ChannelListener"))

local SubChannelChannelManager = {}
SubChannelChannelManager.__index = SubChannelChannelManager

function SubChannelChannelManager:Add(amount)
    amount = amount or 1
    assert(typeof(amount)=="number", 
    ('"amount" expected "number", got %s'):format(
        typeof(amount)
    )
    )
    for i=1, amount do
        i = i + #self.ChannelListeners
        local listener = ChannelListener.new(self.Name .. i)
        self._maid:GiveTask(listener)
        table.insert(self.ChannelListeners, i, listener)
        table.insert(listener, i, listener:Connect(false, function(...)
            self.OnPacketRecived:Fire(...)
        end))
    end
end

function SubChannelChannelManager:Remove(index, destroy)
    assert(typeof(index)=="number", 
    ('Argument "index" expected "number", got %s'):format(
        typeof(index)
    )
    )
    assert(typeof(index)=="boolean" or typeof(index)=="nil",
    ('Argument "destroy" expected "boolean" or "nil", got %s'):format(
        typeof(destroy)
    )
    )
    local listener = self.ChannelListeners[index]
    assert(typeof(listener)=="table" and listener.ClassName=="ChannelListener", 
    ('Expected "ChannelListener" at index %c, got %s'):format(
        index,
        typeof(listener)
    )
    )
    table.remove(self.ChannelListeners, index)
    table.remove(self._listenerConnections, index)
    if destroy then
        listener:Destroy()
    end
end

function SubChannelChannelManager:Destroy()
    self._maid:DoCleaning()
    self = nil
end

function SubChannelChannelManager.new(name)
    assert(typeof(name)=="string",
    ('"name" expected "string", got %s'):format(
        typeof(name)
    )
    )
    local self = {}
    setmetatable(self, SubChannelChannelManager)
    self.Name = name
    self.ChannelListeners = {}
    self._listenerConnections = {}
    self._maid = Maid.new()
    self._onPacketRecived = Signal.new()
    self.OnPacketRecived = self._onPacketRecived.Event

    self._maid:GiveTask(self._onPacketRecived)

    return self
end

return SubChannelChannelManager