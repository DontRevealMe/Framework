--[[
    Name: interface.lua
    Author: DontRevealMe
    Description: Sometimes there are certain external libraries that use HTTPService, but you don't wanna go through each line to add compatability with my module. This module does it for you automatically. 
--]]
local HttpService = require(script.Parent)

local Interface = {}

function Interface:RequestAsync(...)
    local success, value = HttpService:RequestAsync(...):await()

    return value, success
end

function Interface:GetAsync(url, nocache, headers)
    local success, value = HttpService:QuickRequestAsync({
        Url = url,
        Method = "GET",
        Headers = headers
    }, noCache, noCache):await()
    if success then 
        return value, success
    else
        error(value)
    end
end

function Interface:PostAsync(url, data, content_type, compress, headers)
    -- Compress is not supported for now
    if headers~=nil then
        headers = {
            ["Content-Type"] = content_type
        }
    end
    local success, value = HttpService:QuickRequestAsync({
        Url = url,
        Method = "POST",
        Headers = headers or {},
        Body = data
    }):await()
    if success then
        return value, success
    else
        error(value)
    end
end

function Interface:JSONEncode(...)
    return game:GetService("HttpService"):JSONEncode(...)
end

function Interface:JSONDecode(...)
    return game:GetService("HttpService"):JSONDecode(...)
end

function Interface:UrlEncode(...)
    return game:GetService("HttpService"):UrlEncode(...)
end

Interface.HttpEnabled = game:GetService("HttpService").HttpEnabled

return Interface