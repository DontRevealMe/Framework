--  Manages all the listeners needed to form subchannels
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")
local Utility = require(script.Parent:WaitForChild("Util"))
local ChannelListener = require(script.Parent:WaitForChild("ChannelListener"))

local SubChannelsManager = {}
SubChannelsManager.__index = SubChannelsManager
SubChannelsManager.ClassName = "SubChannelsManager"

function SubChannelsManager:Add(amount)
    amount = amount or 1
    assert(typeof(amount)=="number", 
        ('"amount" expected "number", got %s'):format(
            typeof(amount)
        )
    )
    for i=1, amount do
        i = i + #self.ChannelListeners
        local channelListener = ChannelListener.new(self.Name .. i)
        self._maid:GiveTask(channelListener)
        table.insert(self.ChannelListeners, i, channelListener)
        channelListener:Connect(false, function(data, timeSent, packet)
            if packet["Name"] then
                for _,listener in pairs(self._listeners) do
                    if listener.Name == packet.Name and ( (listener.GetComplete and packet.IsCompleted) or not listener.GetComplete ) then
                        listener.Listener(data, timeSent, packet)
                    end
                end
            end
        end)
    end
end

function SubChannelsManager:Remove(index, destroy)
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
    if destroy then
        listener:Destroy()
    end
end

function SubChannelsManager:Destroy()
    self._maid:DoCleaning()
    self = nil
end

function SubChannelsManager:Connect(name, getComplete, listener)
    local UID = game:GetService("HttpService"):GenerateGUID(false)
    self._listeners[UID] = {
        Name = name,
        Listener = listener,
        GetComplete = getComplete
    }
    return setmetatable({IsConnected = true, _parent = self}, {
        __index = {
            Disconnect = function()
                self._parent._listeners[UID] = nil
                self.IsConnected = false
            end
        }
    })
end

function SubChannelsManager.new(name, useCache)
    if useCache and Utility.Cache.SubChannelsManager[name] then
        return Utility.Cache.SubChannelsManager[name]
    end

    assert(typeof(name)=="string",
        ('"name" expected "string", got %s'):format(
            typeof(name)
        )
    )
    local self = {}
    setmetatable(self, SubChannelsManager)
    self.Name = name
    self.ChannelListeners = {}
    self._listenerConnections = {}
    self._maid = Maid.new()
    self._onPacketRecived = Signal.new()
    self.OnPacketRecived = self._onPacketRecived.Event
    self._listenerFunctions = {}

    self._maid:GiveTask(self._onPacketRecived)

    if useCache then
        Utility.Cache.SubChannelsManager[name] = self
    end

    return self
end

return SubChannelsManager