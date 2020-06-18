--  Class that manages the listening of a topic
--  @author DontRevealme

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Utility = require(script.Parent:WaitForChild("Utility"))

local TopicListener = {}
TopicListener.__index = TopicListener

local function CreateSegment()
end

function TopicListener.new(topic, callbackFunc)
    local self = {}
    setmetatable(self, TopicListener)
    self.Connection = MessagingService:SubscribeAsync(topic, function(package, timeSent)
        package = HttpService:JSONDecode(package)
        print("Delay was " .. tostring(os.time() - timeSent))
    end)
    self.Signal = Signal.new()
    self._callBack = callbackFunc

    return self
end

return TopicListener