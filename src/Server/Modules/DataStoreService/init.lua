--  DataStoreService library's main module and will handle the creation of these classes
--  @author DontRevealme

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Configuration = require("Server.Settings").DataStoreService
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local MessagingService = require("MessagingService")


local DataStoreService = {}
DataStoreService._cache = {}
DataStoreService.__index = function(tab, index)
    index = (index=="Value" and "_value") or index
    return tab[index]
end
DataStoreService.__newindex = function(tab, index, value)
    index = (index=="Value" and "_value") or index
    tab[index] = value
    if index=="Value" then
        tab._ValueChanged:Fire(value)
    end
end

DataStoreService.ClassName = "DataStore"

function DataStoreService:FlushAsync()
    return self.CallingMethod:UpdateAsync(self.Key, function()
        return self.Value
    end)
end

function DataStoreService:PullAsync(key, defaultValue)
    key = (self.ClassName=="OrderedBackups" and defaultValue) or key
    return self.CallingMethod:GetAsync(self.Key or key):andThen(function(data)
        if not data then
            local function recursiveCompare(parent, compare)
                local hadToReplace = false
                for i,v in pairs(parent) do
                    if not compare[i] then
                        compare[i] = v
                        hadToReplace = true
                    elseif typeof(v)=="table" then
                        recursiveCompare(v, compare[i])
                    end
                end
                return compare, hadToReplace
            end
            --  Compare values
            if not data then
                self.Value = defaultValue
                return self.Value
            else
                local comparedData, replaced = recursiveCompare(defaultValue, data)
                self.Value = comparedData
                return self.Value, replaced
            end
        else
            self.Value = data
        end
    end)
end

function DataStoreService:GetBackupAsync(backupNum)
    assert(typeof(backupNum)=="number",
        ('"backupNum" expected "number", got %s'):format(
            typeof(backupNum)
        )
    )
    assert( self.ClassName=="OrderedBackups" or self.ClassName=="OrderedBackupsBackup",
        (":GetBackupAsync() is a method exclusive to OrderedBackups DataStores or OrderedBackupsBackup DataStores, got %s"):format(
            self.ClassName
        )
    )
    return self.CallingMethod:GetBackup(backupNum):andThen(function(callingMethod, success)
        if success then
            local newDS = DataStoreService.new(self.Name, self.Key, self.ClassName)
            newDS.ClassName = "OrderedBackupBackup"
            newDS.CalllingMethod = nil
            newDS.CallingMethod = callingMethod
        end
    end)
end

function DataStoreService:BindToPlayer(player)

end

function DataStoreService:Destroy()

end

function DataStoreService:BindToClose(callback)

end

function DataStoreService:Increment(detla)

end

function DataStoreService.new(name, key, callingMethod)
    if DataStoreService._cache[name .. key] then return DataStoreService[name .. key] end
    assert(typeof(name)=="string", 
        ('"name" expected "string", got %s'):format(
            typeof(name)
        )
    )
    assert(typeof(key)=="string",
        ('"key" expected "string", got %s'):format(
            typeof(key)
        )
    )
    assert(typeof(callingMethod)=="string",
        ('"callingMethod" expected "string", got %s'):format(
            typeof(callingMethod)
        )
    )
    assert(script:WaitForChild("DataStoreCalling"):FindFirstChild(callingMethod),
        ("Didn't find a valid DataStore calling method, got %s"):format(
            callingMethod
        )
    )

    local self = {}
    setmetatable(self, DataStoreService)
    self.Name = name
    self.Key = key
    self.ClassName = callingMethod
    self.CallingMethod = require(script:WaitForChild("DataStoreCalling"):FindFirstChild(callingMethod)).new(name, key)
    self.Value = nil
    self._onUpdate = Signal.new()
    self._valueChanged = Signal.new()
    self.ValueChanged = self._valueChanged.Event
    self.OnUpdate = self._onUpdate.Event
    self._maid = Maid.new()
    
    self._maid:GiveTask(self._onUpdate)
    self._maid:GiveTask(self._valueChanged)
    DataStoreService._cache[name .. key] = self

    return self
end

-- MessagingService


return DataStoreService