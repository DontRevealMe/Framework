--[[
    Name: path.lua
    Author: DontRevealMe
    Description: Provides string to path functions. Now has no use at this point but who knows when I need it.
--]]

local path = {}

--[[**
    Grab the segments of a path string
    @param [t:string] path
    @returns [t:table] segments
**--]]
function path:GetSegments(location)
    return string.split(location, ".")
end

--[[**
    Converts a path string to an instance
    @param [t:string] 
    @param [t:Instance] 
    @param [t:bool] waitFor Wether or not to use WaitForChild() when going down the path.
    @returns [t:Instance] 
**]]
function path:PathToInstance(location, parent, waitFor)
    local target = parent or game
    local success = true
    for _,segment in pairs(path:GetSegments(location)) do 
        if (waitFor and target:WaitForChild(segment, 5)) or target:FindFirstChild(segment) then 
            target = target[segment]
        else
            success = false
            break 
        end
    end
    if success then
        return target
    else 
        return false
    end
end

--[[**
    Grabs descendants of the path
    @param [t:string] path
    @param [t:Instance] parent
    @param [t:bool] waitFor Wether or not to use WaitForChild() when going down the path.
    @returns [t:table] Descendants The descendants of the path
**--]]
function path:DescendantsOfPath(location, parent, waitFor)
    return path:PathToInstance(location, parent, waitFor):GetDescendants()
end

--[[**
    If the path encounters a non-existant segment, it will invoke the handler function.
    @param [t:string] path
    @param [t:Instance] parent
    @param [t:bool] waitFor Wether or not to use WaitForChild() when going down the path.
    @param [t:function] handler This function will be invoked when CreatePath encounters a non-existent segment. current parent, segment number, and segments wil be passed into the function. The function must return the newly create object that it wants the path to continue off of. 
    @returns [t:Instance] 
**--]]
function path:CreatePath(location, parent, waitFor, handler)
    local target = parent or game 
    local segments = path:GetSegments(location)
    for i,segment in pairs(segments) do 
        if target:FindFirstChild(segment) or (waitFor and target:WaitForChild(segment, 5)) then 
            target = target[segment]
        else
            target = handler(target, i, segments)
        end
    end
    return target
end

return path