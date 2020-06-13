--[[
    Name: TraditonalSaving.lua
    Author: DontRevealMe
    Description: Uses tradtional methods to save data. It's highly advised you don't use this method for handling player data
--]]
local DataStoreService = game:GetService("DataStoreService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")

local TraditonalSaving = {}
TraditonalSaving.__index = TraditonalSaving
TraditonalSaving.ClassName = "TraditonalSavingDataStore"

function TraditonalSaving:GetAsync(key)
    return Promise.async(function(resolve)
        resolve(self.DataStore:GetAsync(key))
    end):andThen(function(data)
        if data then 
            self._exists = true
            return data
        else
            return nil
        end
    end)
end

function TraditonalSaving:SetAsync(key, value)
    if self._exists then
        -- Redirect to updateasync for obvious reasons
        return self:UpdateAsync(key, value)
    else
        return Promise.async(function(resolve)
            resolve(self.DataStore:SetAsync(key, value))
        end)
    end
end

function TraditonalSaving:UpdateAsync(key, cbf)
    return Promise.async(function(resolve)
        resolve(self.DataStore:UpdateAsync(key, cbf))
    end)
end

function TraditonalSaving.new(dataStore)
    local self = {}
    setmetatable(self, TraditonalSaving)
    self.Name = dataStore.Name
    self.Scope = dataStore.Scope
    self.DataStoreClass = dataStore
    self.DataStore = DataStoreService:GetDataStore(self.Name, self.Scope)
    self._exists = false
    return self
end

return TraditonalSaving