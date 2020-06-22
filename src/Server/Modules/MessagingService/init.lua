--  Handles the sending of messages.
--  @author DontRevealMe

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Promise = require("Promise")
local Configuration = require("Server.Settings").MessagingService
local Utility = require(script:WaitForChild("Util"))
local Package = require(script:WaitForChild("Package"))
local Packet = require(script:WaitForChild("Packet"))
local ChannelListener = require(script:WaitForChild("ChannelListener"))
local SubChannelChannelManager = require(script:WaitForChild("SubChannelChannelManager"))

local module = {}


function module:SendAsync(name, data, subChannel)
    --  Type check + size check
    assert(typeof(name)=="string", ('name" expected "string", got %s.'):format(
        typeof(name)
    ))
    assert(typeof(data)=="table", ('"data" expected "table", got %s.'):format(
        typeof(data)
    ))
    assert(HttpService:JSONEncode(data):len() <= Configuration.SizeLimits.DataSize,
    ("Data has exceeded data size limits. Current limit is: %c. Data size goten was: %c"):format(
        Configuration.SizeLimits.DataSize,
        HttpService:JSONEncode(data):len()
    ))
    assert(Utility.Cache.SubChannelChannelManager[name] or (typeof(subChannel) == "table" and subChannel.ClassName == "SubChannelChannelManager"),
    ('Expected a SubChannel at %s, got %s.'):format(
        name,
        typeof(Utility.Cache.SubChannelChannelManager[name])
    )
    )
    assert((typeof(subChannel)=="table" and subChannel.ClassName=="SubChannelChannelManager") or typeof(subChannel)=="nil" or typeof(subChannel)=="string",
    ('"subChannel" expected "SubChannelChannelManager" or "nil" or "string", got %s'):format(
        typeof(subChannel)
    )
    )
    local packet
    if subChannel==nil then
        packet = Packet.new(data, name)
        Utility.PacketQueue:Enqueue(packet)
    else
        subChannel = (subChannel=="default" and "FrameworkChannel") or subChannel
        subChannel = (typeof(subChannel)=="string" and Utility.Cache.SubChannelChannelManager[subChannel]) or subChannel 
        assert(typeof(subChannel)=="table" and subChannel.ClassName=="SubChannelChannelManager",
        ("Couldn't find SubChannelChannelManager.")
        )
        packet = Packet.new(data, Random.new(os.time()):NextInteger(1, #subChannel.ChannelListeners))
        Utility.PacketQueue:Enqueue(packet)
    end

    return Promise.async(function(resolve)
        resolve(packet.Response.Event:Wait())
    end)
end

function module:Listen(name, getComplete, subChannel, callback)
    -- Type checking
    assert(typeof(name)=="string", string.format('"name" expected "string", got %s', typeof(name)))
    assert(typeof(getComplete)=="boolean" or typeof(getComplete)=="nil", string.format('"getComplete" expected "boolean" or "nil", got %s.', typeof(getComplete)))
    assert(typeof(subChannel)=="boolean" or typeof(getComplete)=="nil", string.format('"subChannel" expected "boolean" or "nil", got %s.', typeof(subChannel)))
    assert(typeof(callback)=="function", string.format('"callback" expected "function", got %s.', typeof(callback)))
    
    if not subChannel then
        local nameListener = Utility.Cache.ChannelListener[name] or ChannelListener.new(name, true)
        return nameListener:Connect(getComplete, callback)
    else
        return Utility.SubChannel.OnPackedRecieved.Event:Connect(function(data, timeSent, packet)
            if packet.Name == name and ((getComplete and not packet["UID"] or packet.SegmentCompleted ) or not getComplete) then
                callback(data, timeSent, packet)
            end
        end)
    end
end

Utility.PacketQueue:SetUpdater(false, function()

    local function sendPackage(package, dontReplace)
        Utility.PublishQueue:Enqueue(package)
        if not dontReplace then
            Utility.CurrentlyBoxing[package.Name] = Package.new(package.Name)
        end
    end

    local buffer = Utility.PacketQueue.Queue
    while #buffer > 0 do
        local packet = buffer[1]
        local package = Utility.CurrentlyBoxing[packet.Name] or Package.new(packet.Name)
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
                local newPacket = Packet.new(segmentData, packet.Name)
                newPacket.Data.UID = UID
                newPacket.Data.Order = i .. "/" .. totalSegments
                if not package:AddPacket(newPacket, true) then
                    -- Create a new package if we cannot fit the packet inside. 
                    local newPackage = Package.new(packet.Name)
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
        MessagingService:PublishAsync(package.Name, HttpService:JSONEncode(dataOnly))
    end)
    if not succ then
        warn(string.format("Failed to send package: %q\n%s", tostring(package.Name), tostring(err)))
        --  If the package fails X or more times, just remove the package and give up.
        package["Fails"] = package["Fails"] or 0
        package.Fails = package.Fails + 1
        if package.Fails >= Utility.MaxFailedAttempts then
            package:FireAllResponses("Fail")
            table.remove(Utility.PublishQueue.Queue, 1)
            warn("MessagingService dropped a packet.")
            package:Destroy()
        end
    else
        package:FireAllResponses("Success")
        table.remove(Utility.PublishQueue.Queue, 1)
        package:Destroy()
    end
end)

-- Subchannels

if Configuration.DefaultSubChannels.Enabled then
    SubChannelChannelManager.new("FrameworkChannel", true):Add(Configuration.DefaultSubChannels.Amount)
end

return module