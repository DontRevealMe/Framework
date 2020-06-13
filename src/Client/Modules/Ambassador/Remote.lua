--[[
    Name: Remote.lua
    Author: DontRevealme
    Description: Provides seemless controls between server and client
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local t = require("t")
local Promise = require("Promise")
local Maid = require("Maid")
local Signal = require("Signal")

local REMOTE_STORAGE = game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("__storage__"):WaitForChild("Ambassador")
local Remote = {}
Remote.__index = Remote
Remote.ClassName = "Remote"

function Remote:Fire(...)
    if self._remote.ClassName=="RemoteEvent" then 
        return self._remote:FireServer(...)
    elseif self._remote.ClassName=="RemoteFunction" then 
        return self._remote:InvokeServer(...)
    end
end

function Remote:Connect(...)
    if self._remote.ClassName == "RemoteEvent" then
        local totalConnections = {}
        for _,listener in pairs({...}) do 
            local con = self.OnClientSend.Event:Connect(listener)
            self._maid:GiveTask(con)
            table.insert(totalConnections, con)
        end
        return (#totalConnections==1 and totalConnections[1]) or totalConnections
    elseif self._remote.ClassName == "RemoteFunction" then 
        self._invokeCallBack = {unpack(self._invokeCallBack), ...}
    end
end

function Remote:Destroy()
    if self._remote.ClassName=="RemoteFunction" then 
        self._remote.OnServerInvoke = nil
    end
    self._maid:DoCleaning()
    self._active = false
    self = nil
end

function Remote.new(remoteObject)
    do 
        local succ, res = t.tuple(t.Instance)(remoteObject)
        if not succ then 
            error(res)
        end
    end
    local self = {}
    setmetatable(self, Remote)
    self._remote = remoteObject
    self._maid = Maid.new()
    self._maid["onClientSend"] = Signal.new()
    self.OnClientSend = self._maid["onClientSend"]

    if self._remote.ClassName=="RemoteEvent" then 
        self._maid:GiveTask(self._remote.OnClientEvent:Connect(function(...)
            self.OnClientSend:Fire(...)
        end))
    elseif self._remote.ClassName=="RemoteFunction" then
        self._invokeCallBack = {}
        self._remote.OnClientInvoke = function(...)
            local asyncs = {}
            local response = {}
            for _,func in pairs(self._invokeCallBack) do 
                table.insert(asyncs, Promise.promisify(func)(...))
            end
            Promise.all(asyncs):andThen(function(totalRes)
                response = (#totalRes==1 and totalRes[1]) or totalRes
            end):await()
            return response
        end
    end
    return self
end

return Remote