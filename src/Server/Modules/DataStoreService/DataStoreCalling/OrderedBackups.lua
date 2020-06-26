--  Ordered backup saving
--  @author DontRevealMe

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local DataStoreService = game:GetService("DataStoreService")
local Promise = require("Promise")

local OrderedBackupBackup = {}
OrderedBackupBackup.__index = OrderedBackupBackup
OrderedBackupBackup.ClassName = "OrderdBackupBackup"

function OrderedBackupBackup:SetAsync(data, transform)
	data = (transform~=nil and transform()) or data
	return Promise.async(function(resolve)
		resolve(self.DataStore:UpdateAsync(function()
			return data
		end))
	end)
end

OrderedBackupBackup.UpdateAsync = OrderedBackupBackup.SetAsync



local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups
OrderedBackups.ClassName = "OrderedBackups"

function OrderedBackups:GetAsync()
	return Promise.async(function(resolve)
		resolve(self.OrderedDataStore:GetSortedAsync(false, 1):GetCurrentPage()[1])
	end):andThen(function(key)
		if key then
			self.SavingKey = key.value
			return Promise.async(function(resolve)
				resolve(self.DataStore:GetAsync(key.value), true)
			end)
		else
			return nil, false
		end
	end)
end

OrderedBackups.UpdateAsync = OrderedBackups.GetAsync

function OrderedBackups:SetAsync(data, transform)
	data = (transform~=nil and transform()) or data
	self.SavingKey = (self.SavingKey or 0) + 1
	return Promise.async(function(resolve)
		resolve(self.DataStore:SetAsync(self.SavingKey, data))
	end):andThen(function()
		return Promise.async(function(resolve)
			resolve(self.OrderedDataStore:SetAsync(self.SavingKey, self.SavingKey))
		end)
	end)
end

function OrderedBackups:OverwriteBackup(backupNum, data)
	return Promise.async(function(resolve)
		resolve(self.DataStore:UpdateAsync(backupNum, function()
			return data
		end))
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

function OrderedBackups:GetBackup(key)
	assert(tonumber(key) < tonumber(self.SavingKey),
	("Backup key must be under %c, got key of %c."):format(
		self.SavingKey,
		key
	)
	)
	return Promise.async(function(resolve)
		resolve(self.DataStore:GetAsync(key))
	end):andThen(function(data)
		if data then
			local newOrderedBackup = OrderedBackups.new(self.Name, self.Key)
			newOrderedBackup.SetAsync = nil
			newOrderedBackup.UpdateAsync = nil
			setmetatable(newOrderedBackup, OrderedBackupBackup)
			newOrderedBackup.SavingKey = key
			newOrderedBackup.ClassName = "OrderedBackupBackup"
			return newOrderedBackup, true
		else
			return nil, false
		end
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