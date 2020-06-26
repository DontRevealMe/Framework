--  Manages messagingservice for DataStoreService
--  @author DontRevealme

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local MessagingService = require("MessagingService")
local SubChannelsManager = require("SubChannelsManager")
local Configuration = require("Server.Modules.Settings")

local ChannelName = (Configuration.DataStoreService.UseOwnChannels and Configuration.DataStoreService.SubChannelsName) or "FrameworkChannel"
SubChannelsManager = Configuration.DataStoreService.OnUpdateMessaging.Enabled and ((not Configuration.DataStoreService.OnUpdateMessaging.UseOwnChannels and SubChannelsManager.new(ChannelName, true)) or SubChannelsManager.new(ChannelName, true):Add(Configuration.DataStoreService.OnUpdateMessaging.SubChannelsChannels))

local module = {}

function module:SendAsync(data)
	if Configuration.DataStoreService.OnUpdateMessaging.Enabled then
		return Promise.async(function(resolve)
			resolve(MessagingService:SendAsync(""):await())
		end)
	end
end

function module:Connect(listener)

end

return module
