--  Class that manages the listening of a channel
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Maid = require("Maid")
local Utility = require(script.Parent:WaitForChild("Util"))

local ChannelListener = {}
ChannelListener.__index = ChannelListener
ChannelListener.ClassName = "ChannelListener"
ChannelListener._cache = {}

function ChannelListener:Destroy()
	self._maid:DoCleaning()
	Utility.Cache.ChannelListener[self.Name] = nil
	self = nil
end

function ChannelListener:Connect(getCompleteOnly, callbackFunc)
	local con = self.OnPacketRecivedSignal.Event:Connect(function(completed, packet, timeStamp)
		if (completed and getCompleteOnly) or not getCompleteOnly or packet.Global then
			callbackFunc(packet.d, timeStamp, packet)
		end
	end)
	self._maid:GiveTask(con)
	return con
end

function ChannelListener.new(name, useCache)
	if useCache and Utility.Cache.ChannelListener[name] then
		return Utility.Cache.ChannelListener[name]
	end

	local self = {}
	setmetatable(self, ChannelListener)
	self.Name = name
	self.OnPacketRecivedSignal = Signal.new()
	self._maid = Maid.new()
	self.Connection = MessagingService:SubscribeAsync(name, function(package)
		local timeSent = package.Sent
		package = package.Data
		for _,packet in pairs(package) do

			-- Unpack metadata
			do
				local n, global, UID, segmentPos, segmentMax = unpack((packet.m or ""):split("/"))
				packet.Name = n
				packet.Global = global == "true"
				packet.UID = UID
				packet.Segments = {
					Position = segmentPos,
					Max = segmentMax
				}
			end

			if packet["UID"] and packet["UID"]~="" then
				--  Segment packet
				local segment = Utility.PacketSegments[packet.UID] or {}
				local order, max = packet.Segments.Position, packet.Segments.Max
				order, max = tonumber(order), tonumber(max)

				table.insert(segment, order, packet)
				Utility.PacketSegments[packet.UID] = segment
				if #Utility.PacketSegments[packet.UID]==max then
					local builtPacket = ""
					for _,pack in pairs(segment) do
						builtPacket = builtPacket .. pack.Data
					end
					builtPacket = HttpService:JSONDecode(builtPacket)
					self.OnPacketRecivedSignal:Fire(true, HttpService:JSONDecode(builtPacket), timeSent)
					packet.Data = builtPacket
					packet.IsCompleted = true
				else
					packet.IsCompleted = false
				end
			else
				packet.IsCompleted = true
			end
			self.OnPacketRecivedSignal:Fire(not packet["UID"] or packet.IsCompleted, packet, timeSent)
		end
	end)

	self._maid:GiveTask(self.Connection)
	self._maid:GiveTask(self.OnPacketRecivedSignal)

	Utility.Cache.ChannelListener[name] = self

	return self
end

return ChannelListener