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

function DataStoreService:FlushData()
    return self.DataStoreCaller:UpdateAsync(self.Key, function()
        return self.BufferData
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
    self.CallingMethod = self.CallingMethod
    self.DataStoreCaller = require(script:WaitForChild("DataStoreCalling"):FindFirstChild(callingMethod)).new(name, key)
    self.BufferData = nil

    DataStoreService._cache[name .. key] = self

    return self
end

return DataStoreService