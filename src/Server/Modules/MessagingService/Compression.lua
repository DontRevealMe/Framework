--  Experimental compression
--  @author DontRevealMe

local module = {}

function module:Compress(target)
    local function recursive(tab)
        for _,v in pairs(tab) do
            --  Compression
            if typeof(v)=="table" then
                recursive(tab)
            end
        end
    end
    recursive(target)
end

function module:Decompress(target)
    local function recursive(tab)
        for _,v in pairs(tab) do
            --  Decompression
            if typeof(v)=="table" then
                recursive(tab)
            end
        end
    end
    recursive(target)
end

return module