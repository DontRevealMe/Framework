--  Standard data store saving
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")

local DataStore = {}
DataStore.__index = DataStore

function DataStore:GetAsync(key, value)
	return Promise.async(function(resolve)
		resolve(self.DataStore:GetAsync(key or "default", value))
	end)
end

function DataStore:UpdateAsync(key, transformFunction)
	return Promise.async(function(resolve)
		resolve(self.DataStore:UpdateAsync(key, transformFunction))
	end)
end

function DataStore:SetAsync(key, value)
	return Promise.async(function(resolve)
		resolve(self.DataStore:SetAsync(key, value))
	end)
end

function DataStore:RemoveAsync(key)
	return Promise.async(function(resolve)
		resolve(self.DataStore:RemoveAsync(key))
	end)
end

function DataStore.new(name, scope)
	local self = {}
	setmetatable(self, DataStore)
	self.Name = name
	self.Scope = scope
	self.ActualName = ("%s/%s"):format(name, scope)
	self.DataStore = DataStoreService:GetDataStore(name, scope)
	return self
end

return DataStore