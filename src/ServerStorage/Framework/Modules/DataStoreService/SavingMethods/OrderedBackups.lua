--[[
    Name: OrderedBackups.lua
    Author: DontRevealMe, https://github.com/Kampfkarren/Roblox/blob/master/DataStore2/SavingMethods/OrderedBackups.lua
    Description: Uses berezaa's method of storing data by creating back ups of the data each time it is save. This makes data loss almost impossible. 
    Use: INTERNAL
--]]
local DataStoreService = game:GetService("DataStoreService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")

local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups
OrderedBackups.ClassName = "OrderedBackupsDataStore"

function OrderedBackups:BackupExists(keyNum)
    return Promise.async(function(resolve)
        resolve(self.OrderedDataStore:GetAsync(keyNum))
    end):andThen(function(key)
        if key then 
            return true
        else
            return false
        end
    end):catch(function(...)
        print("[" .. script:GetFullName() .. "]:", ...)
        return false
    end)
end

function OrderedBackups:GetAsync(backupNum)
    return Promise.async(function(resolve)
        if backupNum then
            resolve(self.OrderedDataStore:GetAsync(backupNum))
        else
            resolve(self.OrderedDataStore:GetSortedAsync(false, 1):GetCurrentPage()[1])
        end
    end):andThen(function(keyPage)
        if keyPage then
            return Promise.async(function(resolve)
                self.BackupKey = keyPage.value
                resolve(self.DataStore:GetAsync(self.BackupKey))
            end)
        else
            return nil
        end
    end)
end

function OrderedBackups:SetAsync(value)
    local key = (self.BackupKey or 0) + 1
    return Promise.async(function(resolve)
        self.DataStore:SetAsync(key, value)
        resolve()
    end):andThen(function()
        self.OrderedDataStore:SetAsync(key, key)
        key = nil
    end)
end

function OrderedBackups:UpdateAsync(backupNum, cbf)
    if self:BackupExists(backupNum) then 
        return Promise.async(function(resolve)
            resolve(self.DataStore:UpdateAsync(backupNum, cbf))
        end)
    end
end

function OrderedBackups:Destroy()
    self = nil
end

function OrderedBackups.new(dataStore)
    local self = {}
    setmetatable(self, OrderedBackups)

    self.Name = dataStore.Name
    self.Scope = dataStore.Scope
    self.DataStoreClass = dataStore
    self.BackupKey = nil
    self.Key = dataStore.Name .. "/" .. dataStore.Scope
    self.DataStore = DataStoreService:GetDataStore(self.Key)
    self.OrderedDataStore = DataStoreService:GetOrderedDataStore(self.Key)
    return self
end

return OrderedBackups