--  OrderedDataStore calling method
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")

local OrderedDataStore = {}
OrderedDataStore.__index = OrderedDataStore

function OrderedDataStore:SetAsync(key, value)
    return Promise.async(function(resolve)
        return resolve(self.OrderedDataStore:SetAsync(key, value))
    end)
end

function OrderedDataStore:UpdateAsync(key, transformFunction)
    return Promise.async(function(resolve)
        return resolve(self.OrderedDataStore:SetAsync(key, transformFunction))
    end)
end

function OrderedDataStore:GetAsync(key)
    return Promise.async(function(resolve)
        return resolve(self.OrderedDataStore:GetAsync(key))
    end)
end

function OrderedDataStore:RemoveAsync(key)
    return Promise.async(function(resolve)
        return resolve(self.OrderedDataStore:RemoveAsync(key))
    end)
end

function OrderedDataStore.new(name, scope)
    local self = {}
    setmetatable(self, OrderedDataStore)
    self.Name = name
    self.Scope = scope
    self.OrderedDataStore = DataStoreService:GetOrderedDataStore(name, scope)

    return self
end

return OrderedDataStore