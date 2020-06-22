--  Ordered backup saving
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")


local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups

function OrderedBackups:GetAsync()

end

function OrderedBackups:UpdateAsync()

end

function OrderedBackups:SetAsync()

end

function OrderedBackups:DeleteAsync()

end

function OrderedBackups.new(name, scope, key)
    local self = {}
    setmetatable(self, OrderedBackups)
    self.Name = name
    self.Scope = scope
    self.Key = key
    self.ActualName = string.format("%s\%s\%s", name, scope, key)
    self.DataStore = DataStoreService:GetDataStore(self.ActualName)

    return self
end

return OrderedBackups