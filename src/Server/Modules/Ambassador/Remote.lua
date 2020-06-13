--[[
    Name: Remote.lua
    Author: DontRevealMe
    Description: Allows for seemless handling between RemoteFunction and RemoteEvent
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local Maid = require("Maid")
local Signal = require("Signal")

local Remote = {}
Remote.__index = Remote
Remote.ClassName = "Remote"

function Remote:Fire(...)
    -- Non-asynchronous version of FireAsync.
    local package = {...}
    if self._remote.ClassName == "RemoteEvent" then
        if typeof(package[1]=="string") and package[1]:lower()=="all" then 
            table.remove(package, 1)
            return self._remote:FireAllClients(unpack(package))
        else
            return self._remote:FireClient(unpack(package))
        end
    else
        return self._remote:InvokeClient(unpack(package))
    end
end


function Remote:Connect(...)
    if self._remote.ClassName=="RemoteEvent" then 
        local totalConnections = {}
        for _,listener in pairs({...}) do 
            -- Get all listeners and create a connection with them to the OnServerSend signal.
            local con = self.OnServerSend.Event:Connect(listener)
            self._maid:GiveTask(con)
            table.insert(totalConnections, con)
        end
        -- If there is only 1 signal, return that if not, return the rest in a table.
        return (#totalConnections==1 and totalConnections[1]) or totalConnections
    else 
        -- RemoteFunction support, just adds functions onto a list. 
        self._invokeCallBack = {unpack(self._invokeCallBack), ...}
    end
end

function Remote:Destroy()
    self._maid:DoCleaning()
    self = nil
end

function Remote:DeepDestroy()
    self._remote:Destroy()
    self:Destroy()
end

function Remote.new(remoteClass)
    local self = {}
    setmetatable(self, Remote)
    self._remote = remoteClass
    self._maid = Maid.new()
    self._maid["connectSignal"] = Signal.new(); -- Odd...
    self.OnServerSend = self._maid["connectSignal"]
    
    -- If the Remote is fired, fire the needed events.
    if self._remote.ClassName=="RemoteEvent" then 
        self._maid:GiveTask(self._remote.OnServerEvent:Connect(function(...)
            self.OnServerSend:Fire(...)
        end))
    elseif self._remote.ClassName=="RemoteFunction" then 
        self._invokeCallBack = {}
        self._remote.OnServerInvoke = function(...)
            local promises = {}
            local response = {}
            -- Convert all of it into promises
            for _,func in pairs(self._invokeCallBack) do 
                table.insert(promises, Promise.promisify(func)(...))
            end
            Promise.all(promises):andThen(function(totalRes)
                -- Collect all responses and if there is 1 response only, then just return that
                response = (#totalRes==1 and totalRes[1]) or totalRes
            end):await()

            return response
        end
    end

    return self
end

return Remote