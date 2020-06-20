--  Handles the sending of messages.
--  @author DontRevealMe

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local Configuration = require("Settings").MessagingService
local Utility = require(script:WaitForChild("Util"))
local Package = require(script:WaitForChild("Package"))
local Packet = require(script:WaitForChild("Packet"))
local TopicListener = require(script:WaitForChild("TopicListener"))

local module = {}


function module:SendAsync(topic, data, useChannel)
    topic = (useChannel and "FrameworkChannel" .. Random.new(os.time()):NextInteger(1,Configuration.TotalSubChannels)) or topic

    local packet = Packet.new(data, topic)
    if useChannel then
        packet.Data.Topic = topic
    end
    Utility.PacketQueue:Enqueue(packet)

    return Promise.async(function(resolve)
        resolve(packet.Response:Wait())
    end)
end

function module:Listen(topic, getComplete, useChannel, callback)
    if not useChannel then
        local topicListener = Utility.TopicListenerCache[topic] or TopicListener.new(topic)
        return topicListener:Connect(getComplete, callback)
    else
        print("was I even called")
        return Utility.SubChannel.OnPackedRecieved.Event:Connect(function(data, timeSent, packet)
            if packet.Topic == topic and ((getComplete and not packet["UID"] or packet.SegmentCompleted ) or not getComplete) then
                callback(data, timeSent, packet)
            end
        end)
    end
end

Utility.PacketQueue:SetUpdater(false, function()

    local function sendPackage(package, dontReplace)
        Utility.PublishQueue:Enqueue(package)
        if not dontReplace then
            Utility.CurrentlyBoxing[package.Topic] = Package.new(package.Topic)
        end
    end

    local buffer = Utility.PacketQueue.Queue
    while #buffer > 0 do
        local packet = buffer[1]
        local package = Utility.CurrentlyBoxing[packet.Topic] or Package.new(packet.Topic)
        if package["Sender"] == nil then
            coroutine.resume(coroutine.create(function()
                wait(1)
                sendPackage(package)
            end))
            package["Sender"] = true
        end
        if packet:GetSize()>=800 then
            --  Break the packet up
            local UID = HttpService:GenerateGUID(false)
            local totalSegments = math.ceil(packet:GetSize() / 800)
            for i=1, totalSegments do
                local segmentData = HttpService:JSONEncode(packet.Data.Data):sub( (i - 1) * 800 + 1, i * 800 )
                local newPacket = Packet.new(segmentData, packet.Topic)
                newPacket.Data.UID = UID
                newPacket.Data.Order = i .. "/" .. totalSegments
                if not package:AddPacket(newPacket, true) then
                    -- Create a new package if we cannot fit the packet inside. 
                    local newPackage = Package.new(packet.Topic)
                    newPackage:AddPacket(newPacket, false)
                    sendPackage(newPackage, true)
                end
            end
            table.remove(buffer, 1)
        elseif not package:AddPacket(packet, true) then
            --  Package is full, send package.
            sendPackage(package)
        else
            --  Successful, remove the buffer from the list
            table.remove(buffer, 1)
        end
    end
end)

Utility.PublishQueue:SetUpdater(false, function(package)
    local succ, err = pcall(function()
        local dataOnly = {}
        for _,packet in pairs(package.Packets) do
            table.insert(dataOnly, packet.Data)
        end
        MessagingService:PublishAsync(package.Topic, HttpService:JSONEncode(dataOnly))
    end)
    if not succ then
        warn(string.format("Failed to send package: %q\n%s", tostring(package.Topic), tostring(err)))
        --  If the package fails 5 or more times, just remove the package and give up.
        package["Fails"] = package["Fails"] or 0
        package.Fails = package.Fails + 1
        if package.Fails >= 5 then
            package:FireAllResponses("Fail")
            table.remove(Utility.PublishQueue.Queue, 1)
            package:Destroy()
        end
    elseif succ then
        package:FireAllResponses("Success")
        table.remove(Utility.PublishQueue.Queue, 1)
        package:Destroy()
        print("Removed it")
    end
end)

if Configuration.UseSubChannels then
    for i=1, Configuration.TotalSubChannels do
        local Channel = TopicListener.new("FrameworkChannel" .. i)
        table.insert(Utility.SubChannel.Listeners, i, Channel)
        table.insert(Utility.SubChannel.Connections, i, Channel:Connect(true, function(data, timeSent, packet)
            Utility.SubChannel.OnPackedRecieved:Fire(data, timeSent, packet)
            print("Sent it")
        end))
    end
end

return module