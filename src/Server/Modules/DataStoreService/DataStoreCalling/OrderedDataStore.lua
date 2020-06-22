--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")

local OrderedDataStore = {}
OrderedDataStore.__index = OrderedDataStore

function OrderedDataStore:SetAsync(key, value)
    return Promise.async(function(resolve)
        return resolve(self.OrderedDataStore:SetAsync(key or "default", value))
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