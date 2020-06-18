--  Handles the sending of messages.
--  @author DontRevealMe
local MessagingService = game:GetService("MessagingService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Utility = require(script:WaitForChild("Util"))
local Package = require(script:WaitForChild("Package"))

local module = {}

Utility.PacketQueue:SetUpdater(false, function()
    local buffer = Utility.PacketQueue.Queue
    Utility.PacketQueue.Queue = {}
    while #buffer > 0 do
        local packet = buffer[#buffer]
        local package = Utility.CurrentlyBoxing[packet.Topic] or Package.new(packet.Topic)
        if not package:AddPacket(packet, true) then
            package:Send()
        else
            table.remove(buffer, #buffer)
        end
    end
end)

return module