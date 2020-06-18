--[[
    Name: Framework.lua / init.lua
    Author: DontRevealMe
    Description: Manages the handling and loading of libraries. 

    Framework Version: DEV-1
    Loader Version: DEV-3
    Server Version: DEV-1
    ServerScript Version: DEV-1
    Client Version: DEV-1
--]]

local table = require(script:WaitForChild("Modules"):WaitForChild("table"))
local Frameworks = {
    ["Server"] = {
        Get = function()
            return game:GetService("ServerStorage"):WaitForChild("Framework")
        end,
        Permission = "Server",
    },
    ["Shared"] = {
        Get = function()
            return game:GetService("ReplicatedStorage"):WaitForChild("Framework")
        end,
        Permission = "All"
    },
    ["Client"] = {
        Get = function()
            -- Assuming it is on client.
            local framework = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Framework", 2)
            if not framework then 
                framework = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("Framework")
                framework = framework:Clone()
                framework.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Framework")
            end
            return framework
        end,
        Permission = "Client"
    }
}

return function(library)
    if typeof(library)=="string" then 
        --[[
            {
                Get = "..." or function or Instance,
                DoesNotExist = function
                Permission = "Client" or "Shared" or "Server"
            }
        --]]
        local function getSides(goal)
            -- Gets avaliable frameworks. If a goal value is passed, it will target that one framework only. This is done to improve performance if you already know which framework
            -- you're going to. 
            local totalFrameworks = {}
            local currentPermission = (game:GetService("RunService"):IsServer() and "Server") or (game:GetService("RunService"):IsClient() and "Client")
            local selectedFrameworks = Frameworks
            if goal then 
                selectedFrameworks = {
                    [goal] = Frameworks[goal]
                }
            end
            for name,framework in pairs(selectedFrameworks) do 
                if currentPermission==framework.Permission or framework.Permission=="All" then 
                    -- Add framework the into a table
                    local success, error = pcall(function()
                        return framework.Get()
                    end)
                    if not success then 
                        error(string.format("Could not fetch Framework %q due to error: %s", name, error))
                    else 
                        table.insert(totalFrameworks, {
                            Name = name,
                            Self = error
                        })
                    end
                end
            end
            if #totalFrameworks==0 then 
                warn("Well this is awkward! We somehow ended up with 0 frameworks.")
            end
            return totalFrameworks
        end

        local function compileModules(modulesOnly, goal)
            -- Compiles modules together
            local compiled = {}
            local totalFrameworks = getSides(goal)

            local function compileRecursion(parent)
                --[[
                    [Name] = {
                        Self = ...
                        Children = {}
                    }
                --]]
                for _,child in pairs(parent.Self:GetChildren()) do 
                    -- To do: Add ignore capabilities
                    parent.Children[child.Name] = {
                        Self = child,
                        Children = {}
                    }
                    if #child:GetChildren()>0 then 
                        compileRecursion(parent.Children[child.Name])
                    end
                end
            end

            local function len(dict)
                -- Don't wanna require table each time.
                local keys = 0
                for _,_ in pairs(dict) do 
                    keys = keys + 1
                end
                return keys
            end

            for _,framework in pairs(totalFrameworks) do 
                -- Initial set up
                compiled[framework.Name] = {
                    Self = framework.Self,
                    Children = {}
                }
                compileRecursion(compiled[framework.Name])
            end
            if modulesOnly then 
                -- Make the dictionary only contains key values of the the name of the module and the module itself.
                local newCompiled = {}
                local function getModulesRecursion(parent)
                    for name,child in pairs(parent.Children) do
                        if child.Self.ClassName=="ModuleScript" then
                            newCompiled[name] = child
                        end
                        if len(child.Children)>0 then
                            getModulesRecursion(child)
                        end
                    end
                end
                for _,v in pairs(compiled) do 
                    getModulesRecursion(v)
                end
                compiled = newCompiled
            end
            return compiled
        end

        local segments = string.split(library, ".")
        if #segments == 1 then 
            -- require(library) and not require(side.folder.library)
            local modules = compileModules(true)
            return require(modules[segments[1]].Self)
        else 
            -- require(side.folder.library)
            local module = compileModules(false)[segments[1]]
            table.remove(segments, 1)
            for _,segment in pairs(segments) do
                module = module.Children[segment]
            end
            return require(module.Self)
        end
    else
        return require(library)
    end
end