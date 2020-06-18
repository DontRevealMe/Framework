--  Handles the sending of messages.
--  @author DontRevealMe

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Utility = require(script:WaitForChild("Util"))
local Package = require(script:WaitForChild("Package"))
local Packet = require(script:WaitForChild("Packet"))

local module = {}

Utility.PacketQueue:SetUpdater(false, function()
    local buffer = Utility.PacketQueue.Queue
    Utility.PacketQueue.Queue = {}
    while #buffer > 0 do
        local packet = buffer[1]
        local package = Utility.CurrentlyBoxing[packet.Topic] or Package.new(packet.Topic)
        if packet:GetSize()>=800 then
            --  Break the packet up
            local UID = HttpService:GenerateGUID(false)
            for i=1, math.ceil(packet:GetSize() / 800) do
                local segmentData = HttpService:JSONEncode(packet.Data):sub( (i - 1) * 800 + 1, i * 800 )
                local newPacket = Packet.new(segmentData, packet.Topic)
                newPacket.Data.UID = UID
                newPacket.Data.Order = i
                if not package:AddPacket(newPacket, true) then
                    local newPackage = Package.new(packet.Topic)
                    newPackage:AddPacket(newPacket, false)
                    newPackage:Send(true)
                end
            end
        elseif not package:AddPacket(packet, true) then
            --  Package is full, send package.
            package:Send()
        else
            --  Successful, remove the buffer from the list
            table.remove(buffer, 1)
        end
    end
end)

Utility.PublishQueue:SetUpdater(false, function(package)
    local succ, err = pcall(function()
        MessagingService:PublishAsync(false, HttpService:JSONEncode(package.Packets))
    end)
    if not succ then
        warn(string.format("Failed to send package: %q\n\n%s", package.Topic, err))
        package["Fails"] = package["Fails"] or 0
        package.Fails = package.Fails + 1
        if package.Fails >= 5 then
            table.remove(Utility.PublishQueue.Queue, 1)
        end
    else
        table.remove(Utility.PublishQueue.Queue, 1)
    end
    wait(1)
end)

return module