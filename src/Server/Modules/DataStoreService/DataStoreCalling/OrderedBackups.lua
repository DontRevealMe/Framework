--  Ordered backup saving
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")


local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups

function OrderedBackups:GetAsync()
    return Promise.async(function(resolve)
        resolve(self.OrderedDataStore:GetSortedAsync(false, 1):GetCurrentPage()[1])
    end):andThen(function(key)
        if key then
            self.SavingKey = key.value
            return Promise.async(function(resolve)
                resolve(self.DataStore:GetAsync(key.value))
            end)
        else
            return false
        end
    end)
end

OrderedBackups.UpdateAsync = OrderedBackups.GetAsync

function OrderedBackups:SetAsync(data)
    self.SavingKey = self.SavingKey + 1
    return Promise.async(function(resolve)
        resolve(self.DataStore:SetAsync(self.SavingKey, data))
    end):andThen(function()
        return Promise.async(function(resolve)
            resolve(self.OrderedDataStore:SetAsync(self.SavingKey, self.SavingKey))
        end)
    end)
end

function OrderedBackups:RemoveAsync(key)
    return Promise.async(function(resolve)
        resolve(self.DataStore:RemoveAsync(key))
    end):andThen(function()
        return Promise.async(function(resolve)
            resolve(self.OrderedDataStore:RemoveAsync(key))
        end)
    end)
end

function OrderedBackups.new(name, key)
    local self = {}
    setmetatable(self, OrderedBackups)
    self.Name = name
    self.Key = key
    self.ActualName = ("%s\%s"):format(name, key)
    self.DataStore = DataStoreService:GetDataStore(self.ActualName)
    self.OrderedDataStore = DataStoreService:GetOrderedDataStore(self.ActualName)
    self.SavingKey = nil
    return self
end

return OrderedBackups