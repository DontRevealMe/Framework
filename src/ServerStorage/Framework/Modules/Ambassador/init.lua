--[[
    Name: Ambassador.lua / init.lua
    Author: DontRevealme
    Description: Provides promise wrapped networking classes
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local t = require("t")
local path = require("Shared.__internal__.path")
local Maid = require("Maid")
local Remote = require(script:WaitForChild("Remote"))
local Promise = require("Promise")

local REMOTE_STORAGE = game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("__storage__"):WaitForChild("Ambassador")
local Ambassador = {}
Ambassador._remotes = {}
Ambassador.__index = Ambassador
Ambassador.ClassName = "Ambassador"

--[[**
    Similar to FireAsync(), but doesn't run asynchronously. Use "all" to use FireAllClients if you're using a RemoteEvent.
    @param [t:Instance] player
    @param [t:Tuple] data
**--]]
function Ambassador:Send(...)
    if self then
        return self._remote:Fire(...)
    end
end

--[[**
    Sends the given data to a specified client asynchronously. Use "all" to use FireAllClients if you're using a RemoteEvent.
    @param [t:Instance] player
    @param [t:Tuple] data
    @return [t:Tuple] invokedData This will only matter if you're using a RemoteFunction type ambassador.
**--]]
function Ambassador:SendAsync(...)
    if self then 
        local arguments = (...)
        return Promise.async(function(resolve, reject, onCancel)
            onCancel(function()
                reject("Cancelled")
            end)
            resolve(self:Send(arguments))
        end)
    end
end

--[[**
    Takes in a table of functions which contain data about path, type, and function to connect/create different remotes without having to go through the creation process of creating a class.
    @param [t:table] listeners Format:
    {
        [path] = {
            ClassName = "RemoteEvent"
            Function = function()
                ...
            end
        }
    }
    @returns [t:Tuple] connectionsAndAmbassadors Contains a tuple that contains 2 tables that contain the connections and new ambassadors made. If 1 ambassador/connection is made it will only return that.
**--]]
function Ambassador:Listen(listeners)
    local totalConnections = {}
    local totalAmbassadors = {}
    for location,listener in pairs(listeners) do 
        if not Ambassador._remotes[location] then 
            table.insert(totalAmbassadors, Ambassador.new(location, listener.ClassName)); -- memory leak issue?
        end
        local con = Ambassador._remotes[location]._remote:Connect(listener.Function)
        self._maid:GiveTask(con)
        table.insert(totalConnections, con)
    end
    return (#totalConnections==1 and totalConnections[1]) or totalConnections, (#totalAmbassadors==1 and totalAmbassadors[1]) or totalAmbassadors; -- Returns a table if there is only one event or only one new ambassador made
end

--[[**
    Connects a function to an ambassador.
    @param [t:Function] listener
    @returns [t:RBXScriptConnection] connection If you're using a RemoteEvent type ambassador, it may return a RBXScriptConnection. 
**--]]
function Ambassador:Connect(...)
    return self._remote:Connect(...)
end

--[[**
    Destroys the ambassador class, but not the remote.
**--]]
function Ambassador:Destroy(...)
    if self then 
        self._maid:DoCleaning()
        self._remote:Destroy()
        self = nil
    else
        for _,ambassador in pairs({...}) do 
            if Ambassador._remote[ambassador] then 
                Ambassador._remote[ambassador]:Destroy()
            end
        end
    end
end

--[[**
    Destroys an ambassador object and remote object too.
    @returns [t:void]
**--]]
function Ambassador:DeepDestroy()
    if self then 
        self._remote:DeepDestroy()
        self:Destroy()
    end
end

--[[**
    Creates a new ambassador class.
    @param [t:string] location
    @param [t:string] className
    @returns [t:Ambassador]
**--]]
function Ambassador.new(location, className)
    do
        -- Type checking
        local succ, res = t.tuple(t.string, t.string)(location, className)
        if not succ then 
            error(res)
        end
    end
    local self = {}
    setmetatable(self, Ambassador)
    self._remoteObject = path:PathToInstance(location, REMOTE_STORAGE, false)
    -- If a remote does not exist, create the needed folders for it.
    if not self._remoteObject then 
        -- Create a new path and a new remote
        self._remoteObject = path:CreatePath(location, REMOTE_STORAGE, false, function(parent, i, segments)
            local name = segments[i]
            local newObject
            if i<#segments then
                newObject = Instance.new("Folder")
                newObject.Name = name
                newObject.Parent = parent 
            else 
                newObject = Instance.new(className)
                newObject.Name = name
                newObject.Parent = parent
            end
            return newObject
        end)
    end
    self._remote = Remote.new(self._remoteObject)
    self._maid = Maid.new()
    self.OnServerSend = self._remote.OnServerSend
    Ambassador._remotes[location] = self; -- This is important for later
    return self
end

return Ambassador