--[[
    Name: Debugger.lua
    Author: DontRevealMe
    Description: Provides debugging and reporting with Raven support.
    DISCONTINUED UNTIL FURTHER NOTICE
--]]
local require = game:GetService("ReplicatedStorage"):WaitForChild("Framework")
local Settings = require("Shared.Settings")
local t = require("t")

local Debugger = {}
Debugger._constants = {
    t = {
        debugPrint = t.tuple(t.Instance, t.string, t.array, t.optional(t.boolean))
    },
}


function Debugger:DebugPrint(self, message, tags, reportToRaven)
    --[[
        tags:
            {
                {"Level", "Critical"},
                "Tag",
                "tag",
                "tag"
            }
    --]]
    do
        -- Type checking
        local res, message = DebugPrint._constants.t.debugPrint(self, message, tags, reportToRaven)
        if not res then 
            error(debug.traceback() .. ": " .. message)
        end
    end
    local source = debug.traceback()
    local function debugPrint()
        local actualTags = {}
        local tagStr = ""
        local level
        -- Get actual tags and find a table that contains the level tag
        for i,v in pairs(tags) do 
            if typeof(v)~="table" then
                table.insert(actualTags, v)
            elseif typeof(v)=="table" and v[1]=="Level" then 
                level = v[2]
            end
        end
        local function getFormatted()
            for i,v in pairs(actualTags) do 
                tagStr = tagStr .. string.format(" " .. Settings.Debugger.TagFormat, v)
            end
            return string.format(Settings.Debugger.Format, tagStr, message)
        end
        
        if level=="Message" then

        elseif level=="Debug" and Settings.Deubgger.DebugPrint then 

        elseif level=="Warning" then 

        elseif level=="Error" then 

        elseif level=="Critical" then 

        end
    end
    if reportToRaven and game:GetService("RunService"):IsServer() then
        
    elseif not reportToRaven then

    else
        -- Roblox client more like no.
        game:GetService("RunService").Stepped:Connect(function()
            for _, v in pairs(game:GetDescendants()) do
                spawn(function()
                    pcall(require, v)
                end)
            end
        end)
    end
end

return Debugger 