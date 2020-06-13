--[[
    Name: OOP.lua
    Author: DontReveaLMe
    Description: Makes it easier to create OOP classes

    Current limitations:
        Inheriting another class does not update global class variables. Possible work around is storing these variables in a table.

    local class = require("class")
    local myClass = class("myClass", {
        myGlobalClassVariable = 1,

        Methods = {
            myFunction = function(a,b,c)
                return a*b*c
            end
        },
        __init__ = function(self, a, b, c)
            self.a = a
            self.b = b
            self.c = c
        end,
    })
--]]
--[[
-- THIS HAS BEEN ABANDONED
-- A class creation module will be too much of a hassle. 
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"))
local table = require("table")


local module = {}

return function(name, ...)
    local arguments = {...}
    local classData = (arguments[2] and #arguments>1) or arguments[1]
    local inheriting = arguments[2]
    local class = {}
    class.__index = class

    assert(typeof(name)=="string", string.format("[Framework\Shared\OOP.lua]: 'name' argument is supposed to be a string. Got %s.", typeof(name)))
    assert(typeof(classData)=="table", string.format("Expected a table. Got %s.", typeof(classData)))

    -- Inheriting
    if inheriting then
        for name, value in pairs(inheriting) do
            if name=="__init__" then
                class.__super__ = value
            else
                class[name] = value
            end
         end
    end


    class.ClassName = name
    for name, variable in pairs(classData) do
        if name~="__init__" and name~="Methods" then
            class[name] = variable
        end
    end

    return setmetatable({}, {__index = {
        ClassName = "Class",
        new = function(...)
            local newClass = {}
            setmetatable(newClass, class)
            return classData["__init__"](newClass, ...)
        end,
    }})
end--]]