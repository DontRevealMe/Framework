--[[
    Name: HttpService.lua / init.lua
    Author: DontRevealMe
    Description: Provides an httpservice queuing system
--]]

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local Signal = require("Signal")
local Promise = require("Promise")
local HttpService = game:GetService("HttpService")
local Module = {}
Module._cache = {}
Module._queueData = {
    queue = {},
    lastReset = tick(),
    requestsMade = 0,
    wakeQueue = Signal.new()
}
function Module:RequestAsync(requestDictionary, cache, useCache)
    return Promise.async(function(resolve, reject, onCancel)
        if useCache and Module._cache[requestDictionary.Url] then 
            return Module._cache[requestDictionary.Url]
        else
            if tick() - Module._queueData.lastReset >= 60 then 
                Module._queueData.requestsMade = 0
                Module._queueData.lastReset = tick()
            end
            if Module._queueData.requestsMade >= 500 or #Module._queueData.queue>0 then 
                -- Queue is full or is on going!
                local isEmpty = #Module._queueData.queue == 0
                local placeOnQueue = #Module._queueData.queue + 1
                -- Add it to the queue
                table.insert(Module._queueData.queue, placeOnQueue, {
                    Response = function(succ, res)
                        if succ then 
                            resolve(res)
                        else
                            reject(res)
                        end
                    end,
                    Data = requestDictionary
                })
                if isEmpty then Module._queueData.wakeQueue:Fire() end
            else
                -- Queue is not full
                resolve(HttpService:RequestAsync(requestDictionary))
                Module._queueData.requestsMade = Module._queueData.requestsMade  + 1
            end
        end
    end):andThen(function(response)
        if cache and response["Success"] then 
            Module._cache[response.Url] = response
        end
        return response
    end)
end

function Module:QuickRequestAsync(dictionary, cache, useCache)
    dictionary.Method = dictionary.Method:upper()
    if not dictionary["Headers"] then
        dictionary.Headers = {}
    end
    if not dictionary.Headers["Content-Type"] then 
        dictionary.Headers["Content-Type"] = "application/json"
    end 
    dictionary.Body = HttpService:JSONEncode(dictionary.Body)
    return Module:RequestAsync(dictionary, cache, useCache):andThen(function(res)
        if res["Success"] then 
            res = HttpService:JSONDecode(res)
        end
        return res
    end)
end

return Module