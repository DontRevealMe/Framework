--  DataStoreService library's main module and will handle the creation of these classes
--  @author DontRevealme

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Configuration = require("Server.Modules.Settings").DataStoreService
local Maid = require("Maid")
local Signal = require("Signal")
local Promise = require("Promise")
local MessagingService = require(script:WaitForChild("UtilMS"))
local SubChannelsManager = require("SubChannelsManager")


local DataStoreService = {}
DataStoreService._cache = {}
DataStoreService.__index = function(tab, index)
	index = (index=="Value" and "_value") or index
	return tab[index]
end
DataStoreService.__newindex = function(tab, index, value)
	index = (index=="Value" and "_value") or index
	tab[index] = value
	if index=="Value" then
		tab._ValueChanged:Fire(value)
	end
end

DataStoreService.ClassName = "DataStore"

function DataStoreService:FlushAsync()
	return self.CallingMethod:UpdateAsync(self.Key, function()
		return self.Value
	end):andThen(function(value)
		if Configuration.OnUpdateMessaging then
			return MessagingService:SendAsync({
				n = self.Name,
				k = self.Key,
			})
		else
			return value
		end 
	end)
end

function DataStoreService:PullAsync(key, defaultCheckFunction)
	key = key or (self.ClassName=="OrderedBackups" and self.CallingMethod.SavingKey)
	return self.CallingMethod:GetAsync(self.Key or key):andThen(function(data)
		data = (typeof(defaultCheckFunction)=="function" and defaultCheckFunction(data)~=nil) or data
		if defaultCheckFunction==nil and not data then
			return defaultCheckFunction
		end
		if data then
			self.Value = data
		end
		return self.Value
	end)
end

function DataStoreService:GetBackupAsync(backupNum)
	assert(typeof(backupNum)=="number",
		('"backupNum" expected "number", got %s'):format(
			typeof(backupNum)
		)
	)
	assert( self.ClassName=="OrderedBackups" or self.ClassName=="OrderedBackupsBackup",
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
            return newDS
        end
        return false
	end)
end

function DataStoreService:BindToPlayer(player)
	assert(typeof(player)=="Instance" and player.ClassName=="player",  string.format('"player" expected "player", got %s', typeof(player)))
	self:BindToClose(function()
		self:FlushAsync()
	end)
	self._maid:GiveTask(game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
		if leavingPlayer==player then
			self:FlushAsync()
			self:Destroy()
		end
	end))
end

function DataStoreService:Destroy()
	self:_ActivateBindToClose()
	self = nil
end

function DataStoreService:BindToClose(callback)
	assert(typeof(callback)=="function", string.format('"callback" expected "Function", got %s', typeof(callback)))
	table.insert(self._bindToClose, callback)
end

function DataStoreService:_ActivateBindToClose()
	for _,func in pairs(self._bindToClose) do
		xpcall(func, function(err)
			print("Failed to execute BindToClose function.\n" .. err)
		end)
	end
end

function DataStoreService:Increment(delta)
	assert(typeof(self.Value)=="number", string.format('Expected DataStore value to be "number", got %s', typeof(self.Value)))
	assert(typeof(delta)=="number", string.format('"delta" expected "number", got %s', typeof(delta)))
	self.Value = self.Value + delta
	return self.Value
end

function DataStoreService.new(name, key, callingMethod)
	if DataStoreService._cache[name .. key] then return DataStoreService[name .. key] end
	assert(typeof(name)=="string", 
		('"name" expected "string", got %s'):format(
			typeof(name)
		)
	)
	assert(typeof(key)=="string",
		('"key" expected "string", got %s'):format(
			typeof(key)
		)
	)
	assert(typeof(callingMethod)=="string",
		('"callingMethod" expected "string", got %s'):format(
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
	self._onUpdate = Signal.new()
	self._valueChanged = Signal.new()
	self.ValueChanged = self._valueChanged.Event
	self.OnUpdate = self._onUpdate.Event
	self._maid = Maid.new()
	self._bindToClose = {}
	
	self._maid:GiveTask(self._onUpdate)
	self._maid:GiveTask(self._valueChanged)
	DataStoreService._cache[name .. key] = self

	return self
end

-- MessagingService


return DataStoreService