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

--[[**
    Listens to multiple ambassadors at once. If there is no ambassador, it will try to create a new ambassador class, NOT A NEW REMOTE.
    @param [t:Variant] dictionaries Format:
    {
        Location = string
        Function = function
    }
    @returns [t:table] Contains the new connections made. 
**--]]
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

--[[
    Connects to an ambassador class.
    @param [t:function] listener
    @returns [t:RBXScriptConnection]
--]]
function Ambassador:Connect(...)
    return self._remote:Connect(...)
end

--[[
    Fires the remote. This should be used if your ambassador type if a RemoteEvent.
    @param [t:Variant]
    @returns [t:Variant] If your ambassador type is a RemoteFuncction, it will return a variant. If not, it will return nothing.
--]]
function Ambassador:Send(...)
    if self then 
        return self._remote:Fire(...)
    end
end

--[[
    Asnychoursly fires the remote over to the server. This should be used if your ambassador type is a RemoteFunction.
    @param [t:Variant] 
    @returns [t:Variant] If your ambassador type is a RemoteFuncction, it will return a variant. If not, it will return nothing.
--]]
function Ambassador:SendAsync(...)
    local arguments = (...)
    return Promise.async(function(resolve)
        resolve(self:Send(arguments))
    end)
end

--[[
    Destroys the ambassador class, but not the remote.
    @returns [t:void]
--]]
function Ambassador:Destroy()
    if self then 
        self._remote:Destroy()
        self._maid:DoCleaning()
        self = nil
    end
end

--[[
    Creates a new ambassador class.
    @param [t:string] location
    @retrusn [t:Ambassador]
--]]
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