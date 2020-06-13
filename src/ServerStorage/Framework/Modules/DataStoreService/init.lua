--[[
    Name: DataStoreService.lua
    Author: DontRevealMe
    Description: Could be considered as a stripped down version of DataStore2 with add functionality for non-player datastores.
--]]
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local Signal = require("Signal")
local Maid = require("Maid")
local t = require("t")

local DataStoreService = {}
DataStoreService.__index = DataStoreService
DataStoreService.ClassName = "DataStore"

DataStoreService._constants = {
    t = {
        newClass = t.tuple(t.string, t.string, t.optional(t.string), t.optional(t.boolean), t.optional(t.string))
    }
}

--[[** 
    IT'S HIGHLY RECCOMENDED YOU DON'T USE THIS. IF YOU WANT TO SAVE DATA, USE :SaveAsync().
    Saves whatever data that's passed into it into Roblox's DataStoreService.
    @param [t:Variant] value Data that will be saved to Roblox's DataStoreService
    @returns [t:Promise]
**--]]

function DataStoreService:PullAsync(...)
    return self._savingMethod:GetAsync(...)
end

--[[** 
    IT'S HIGHLY RECCOMENDED YOU DON'T USE THIS. IF YOU WANT TO SAVE DATA, USE :SaveAsync().
    Saves whatever data that's passed into it into Roblox's DataStoreService.
    @param [t:Variant] value Data that will be saved to Roblox's DataStoreService
    @returns [t:Promise]
**--]]

function DataStoreService:PushAsync(...)
    return self._savingMethod:SetAsync(...)
end

--[[**
    Gets the value of the DataStore cache.
    @param [t:Variant] defaultValue
    @returns [t:Variant] dataStoreValue
**--]]

function DataStoreService:Get(defaultValue)
    if not self._foundValue then 
        local _,value = self:PullAsync():await()
        if value then
            self._value = value
        else 
            self._value = defaultValue
        end
        self._foundValue = true
    end
    return self._value
end

--[[**
    Retrives DataStore value asynchronously. You might wanna use this when you first get the value of the DataStore as it's most likely gonna need
    to retrive the value of the DataStore from Roblox's DataStoreService. If you call regular :Get(), it will yield your script. 
    @param [t:Variant] defaultValue
    @returns [t:Promise]
**--]]

function DataStoreService:GetAsync(defaultValue)
    return Promise.async(function(resolve)
        resolve(self:Get(defaultValue))
    end)
end

--[[**
    Turns the DataStore class into a DataStoreBackup by calling a backup class.
    @param [t:Number] backupNumber
    @returns [t:Promise] backupData
**--]]

function DataStoreService:GetBackupAsync(backupNum)
    return Promise.async(function(resolve, reject)
        if self._savingMethod~="OrderedBackups" then 
            if self._savingMethod:BackupExists(backupNum) then 
                resolve(self._savingMethod.DataStore:GetAsync(backupNum))
            else 
                reject(backupNum .. " does not exist as a backup.")
            end
        else
            reject("Tried to use :GetBackupAsync() method on a class that does not support it.")
        end
    end):andThen(function(result)
        self.ClassName = "BackupDataStore"
        return result
    end)
end

--[[**
    Sets the value of the DataStore cache/session to the passed value
    @param [t:Variant] value
    @returns [t:void]
**--]]

function DataStoreService:Set(value)
    self._value = value
end

--[[**
    Saves current cache data onto Roblox's DataStore. 
    @returns [t:void]
**--]]

function DataStoreService:SaveAsync()
    --return self:PushAsync(self._value)
    return Promise.async(function(resolve)
        self.bindToSaveFunc(self._value)
        resolve()
    end):andThen(function()
        return self:PushAsync(self._value)
    end)
end

--[[**
    Calls the function when the datastore is destroyed or when the game is shutting down.
    @param [t:Function] function
    @returns [t:void]
**--]]

function DataStoreService:BindToClose(callback)
    table.insert(self._bindToCloseFunctions, callback)
end

--[[**
    Calls the function when the :SaveAsync() function is called upon. It will pass the DataStore class as an argument into the function. Please note
    that this will run when :BindToClose() is ran too.
    @param [t:Function] function
    @returns [t:void]
**--]]
function DataStoreService:BindToSave(callback)
    table.insert(self._bindToSaveFunctions, callback)
end

--[[**
    Binds a datastore to a player instance. This basically converts the DataStore into a DataStore2. 
    @param [t:Instance] player Player that will be binded.
    @returns [t:void]
**--]]
function DataStoreService:BindToPlayer(player)
    self.Player = player
    if self._savingType=="TraditionalSaving" then
        self.Key = tostring(player.UserId)
    else
        self.Scope = tostring(player.UserId)
    end
    self._maid["internal_playerSavingEvent"] = Instance.new("BindableEvent")
    self._closingEvent = {
        event = self._maid["internal_playerSavingEvent"],
        fired = false
    }
    -- Add a bind to close function and give it highest priority to run
    self:BindToClose(function()
        spawn(function()
            player.Parent = nil
        end)
        if not self._closingEvent.fired then 
            self._closingEvent.event.Event:Wait()
        end
    end)
    -- Player leaving
    self._maid:GiveTask(player.AncestryChanged:Connect(function()
        self:SaveAsync():await()
        print("Done saving!")
        self._closingEvent.fired = true 
        print("Firing event")
        self._closingEvent.event:Fire()
        print("Event fired!")
    end))
end

--[[**
    Destroys the DataStore itself.
    @returns [t:void]
**--]]
function DataStoreService:Destroy()
    self.bindToCloseFunc()
    self._maid:DoCleaning()
    self._savingMethod = nil
    self = nil
end

--[[**
    Creates a new DataStore class.
    DataStoreService's custom class aims to provide a promised wrapped version of Roblox's DataStoreService. It also supports extra method such as
    :BindToClose(), :BindToSave(), :Pull(), :Push(), and etc... which can help during the development process.
    There are 2 types of saving right now which is:
        - "OrderedBackups"
        - "TraditionalSaving"
    OrderedBackups is necessary when you're handling user data which can be corrupted easily. It works by creating a backup of the datastore 
    each time it is saved.
    TraditionalSaving is regular old :Set, :Get, and :Update from Roblox's DataStoreService. 
    @param [t:string] name
    @param [t:string] scope
    @param [t:string] key [Optional] [Default: nil] Only necessary if you're using conventential saving methods. 
    @param [t:boolean] useCache [Optional] [Default: false] There are very rare cases on why you would want to use this, but this makes it so you're now directly access Roblox's DataStoreService with each method
    @param [t:string] savingMethod [Optional] [Default: "TraditionalSaving"]
**--]]
function DataStoreService.new(name, scope, key, useCache, savingMethod)
    do 
        -- Type checking
        local res, message = DataStoreService._constants.t.newClass(name, scope, key, useCache, savingMethod)
        if not res then 
            error("[Framework\Server\DataStoreService]: " .. message)
        end
    end
    local self = {}
    setmetatable(self, DataStoreService)
    self._maid = Maid.new()
    self.Name = name
    self.Scope = scope
    self.Key = key
    self._value = nil
    self._foundValue = false; -- So I realized that the user could set the datastore to "nil" and getasync would constantly request a datastore request each time
    self._useCache = useCache
    self._savingType = savingMethod or "TraditionalSaving"
    self._bindToCloseFunctions = {}
    self._bindToSaveFunctions = {}
    self._savingMethod = require(script:WaitForChild("SavingMethods"):WaitForChild(savingMethod or "TraditionalSaving")).new(self)
    self.bindToCloseFunc = function()
        -- Convert these functions into promises. We'll run Promise.all to run them all concurrently.
        local promisedVersions = {}
        for i,func in pairs(self._bindToCloseFunctions) do 
            if typeof(func)=="function" then
                func = Promise.promisify(func)(self)
                table.insert(promisedVersions, func)
            end
        end
        Promise.all(promisedVersions):catch(function(...)
            warn(string.format("[%s]: %s", script:GetFullName(), ...))
        end):await()
    end
    self.bindToSaveFunc = function(savingData)
        -- Same idea as bindToCloseFunc
        local promisedVersions = {}
        for i,func in pairs(self._bindToCloseFunctions) do 
            if typeof(func)=="function" then
                func = Promise.promisify(func)(self)
                table.insert(promisedVersions, func)
            end
        end
        Promise.all(promisedVersions):catch(function(...)
            warn(string.format("[%s]: %s", script:GetFullName(), ...))
        end):await()
    end
    game:BindToClose(self.bindToCloseFunc)

    return self
end

return DataStoreService