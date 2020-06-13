--[[
    Name: Ambassador.lua
    Author: DontRevealme
    Description: Provides better networking for the client side
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local t = require("t")
local Promise = require("Promise")
local Maid = require("Maid")
local Remote = require(script:WaitForChild("Remote"))
local path = require("Shared.__internal__.path")

local Ambassador = {}
Ambassador.__index = Ambassador
Ambassador.ClassName = "Ambassador"
Ambassador._remotes = {}

local REMOTE_STORAGE = game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("__storage__"):WaitForChild("Ambassador")

function Ambassador:Listen(...)
    --[[
        {
            [path] = function()

            end
        }
    --]]
    -- For situations where you want to connect multiple functions without having to the through the hassle of creating new ambassador classes
    local listeners = {...}
    local totalConnections = {}
    listeners = listeners[1]
    for location, listener in pairs(listeners) do 
        local continue = false
        if not Ambassador._remotes[location] then 
            -- If an Ambassador class does not exist in client cache, create a new one.
            local succ, newAmbassador = pcall(function()
                return Ambassador.new(location)
            end)
            if not succ then
                continue = true; -- Roblox has yet to implement continue into Lua.
            end
        end
        if not continue then 
            -- If there is an ambassador class, add it's newly connected connections to the table and return it. 
            local ambassador = Ambassador._remotes[location]
            totalConnections = {unpack(totalConnections), ambassador:Connect(listener)}
        end
    end
    return (#totalConnections==1 and totalConnections[1]) or totalConnections
end

function Ambassador:Connect(...)
    return self._remote:Connect(...)
end

function Ambassador:Send(...)
    if self then 
        return self._remote:Fire(...)
    end
end

function Ambassador:SendAsync(...)
    local arguments = (...)
    return Promise.async(function(resolve)
        resolve(self:Send(arguments))
    end)
end

function Ambassador:Destroy()
    if self then 
        self._remote:Destroy()
        self._maid:DoCleaning()
        self = nil
    end
end

function Ambassador.new(location)
    do 
        -- Type checking
        local succ, res = t.tuple(t.string)(location)
        if not succ then 
            error(res)
        end
        local object = path:PathToInstance(location, REMOTE_STORAGE, true)
        if not (object and typeof(object)=="Instance" and (object.ClassName=="RemoteFunction" or object.ClassName=="RemoteEvent")) or not object or typeof(object)~="Instance" then 
            error(string.format("Expected a remote at %s, got %s", location, tostring(object)))
        end
    end
    local self = {}
    setmetatable(self, Ambassador)
    self._maid = Maid.new()
    self._remoteObject = path:PathToInstance(location, REMOTE_STORAGE, true)
    self._remote = Remote.new(self._remoteObject)
    self.OnClientSend = self._remote.OnClientSend
    self._remotes[location] = self
    return self
end

return Ambassador