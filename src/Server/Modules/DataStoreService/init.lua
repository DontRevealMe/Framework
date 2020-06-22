--  DataStoreService library's main module and will handle the creation of these classes
--  @author DontRevealme

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local MessagingService = require("MessagingService")


local DataStoreService = {}
DataStoreService._cache = {}
DataStoreService.__index = DataStoreService
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
    assert(self.ClassName=="OrderedBackups" or self.ClassName=="OrderedBackupsBackup",
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

function DataStoreService.new(name, key, callingMethod)
    if DataStoreService._cache[name .. key] then return DataStoreService[name .. key] end
    assert(typeof(name)=="string", 
    ('Argument "name" expected "string", got %s'):format(
        typeof(name)
    )
    )
    assert(typeof(key)=="string",
    ('Argument "key" expected "string", got %s'):format(
        typeof(key)
    )
    )
    assert(typeof(callingMethod)=="string",
    ('Argument "callingMethod" expected "string", got %s'):format(
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

    DataStoreService._cache[name .. key] = self

    return self
end

return DataStoreService