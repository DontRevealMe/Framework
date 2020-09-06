--  Manages messagingservice for DataStoreService
--  @author DontRevealme

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local MessagingService = require("MessagingService")
local SubChannelsManager = require("SubChannelsManager")
local Configuration = require("Server.Modules.Settings")

local ChannelName = (Configuration.DataStoreService.UseOwnChannels and Configuration.DataStoreService.SubChannelsName) or "FrameworkChannel"
SubChannelsManager = Configuration.DataStoreService.OnUpdateMessaging.Enabled and ((not Configuration.DataStoreService.OnUpdateMessaging.UseOwnChannels and SubChannelsManager.new(ChannelName, true)) or SubChannelsManager.new(ChannelName, true))

local module = {}

function module:SendAsync(data)
	if Configuration.DataStoreService.OnUpdateMessaging.Enabled then
		return MessagingService:SendAsync(nil, data, Configuration.DataStoreService.SubChannelsName)
	end
end

function module:Connect(listener)
    return MessagingService:Listen(nil, true, Configuration.DataStoreService.SubChannelsName, "")
end

return module
