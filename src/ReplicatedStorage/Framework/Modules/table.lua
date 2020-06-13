--[[
    Name: table.lua
    Author: DontRevealme
    Description: Adds more table functions
--]]

local module = {}

--[[**
    Deep copies the table passed into it
    @param [t:Tuple] tables
    @return [t:Tuple] clonedTables
**--]]
function module.deepcopy(...)
    local result = {}
    for _,tab in pairs({...}) do
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[module.deepcopy(orig_key)] = module.deepcopy(orig_value)
            end
            setmetatable(copy, module.deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        table.insert(result, copy)
    end
    return unpack(result)
end

--[[**
    Merges 2 tables together. Gives priority to table 2.
    @param [t:Table] table1
    @param [t:Table] table2
    @returns [t:table] mergedTable
**--]]
function module.merge(t1, t2)
    for i,v in pairs(t2) do 
        t1[i] = v
    end
    return newTable
end

--[[**
    Gets all the keys inside of a dictionary
    @param [t:Dictionary] dictionary
    @returns [t:Table] keys
**--]]
function module.keys(dictionary)
    local returnList = {}
    for i,v in pairs(dictionary) do 
        table.insert(returnList, i)
    end
    return returnList
end

--[[**
    Return true or false depending if the searched value is in the table
    @param [t:Table] table
    @param [t:Variant] search
    @retursn [t:Bool] found
**--]]
function module.find(t1, search)
    for i,v in pairs(t1) do
        if v==search then
            return true
        end
    end
    return false
end

--[[**
    Gets the length of a dictionary
    @param [t:Dictionary] dictionary
    @returns [t:Number] length
**--]]
function module.len(dict)
    return #module.keys(dict)
end

return setmetatable(module, {
    __index = table
})