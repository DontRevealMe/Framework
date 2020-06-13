-- Loads in the framework
-- V1.0.0
local Settings = {
    localModules = true; -- Wether or not we'll use custom modules within the game.
}


local InsertService = game:GetService("InsertService")
local totalIDs = {
    Client = 5158506956,
    Shared = 5158817233,
    Server = 5158468028,
    ServerScripts = 5163633141
}
local t1 = tick()
for name, id in pairs(totalIDs) do 
    coroutine.resume(coroutine.create(function()
        local latestVersion = InsertService:GetLatestAssetVersionAsync(id)
        print(string.format("Framework is now loading in %q. Version %s", name, latestVersion))
        local module = nil
        do
            local model = InsertService:LoadAssetVersion(latestVersion)
            module = model:GetChildren()[1]
            module.Parent = nil
            model:Destroy()
        end
        -- Consider custom modules that have been added
        do 
            local sides = {
                Server = game:GetService("ServerStorage"):FindFirstChild("CustomFramework"),
                Shared = game:GetService("ReplicatedStorage"):FindFirstChild("CustomFramework"),
                Client = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"):FindFirstChild("CustomFramework"),
                ServerScripts = game:GetService("StarterPlayer"):WaitForChild("CustomFramework")
            }
            framework = sides[name]
            if framework then 
                for _,folder in pairs(framework:GetChildren()) do 
                    if module:FindFirstChild(folder.Name) then 
                        -- Custom modules will always take priority. 
                        for _,object in pairs(folder:GetChildren()) do 
                            -- If there are somehow 2 of the same objects, we'll just merge the module scripts
                            local mergingObject = module:FindFirstChild(folder.Name):FindFirstChild(object.Name)
                            if mergingObject then 
                                if object:IsA("ModuleScript") and mergingObject:IsA("ModuleScript") then 
                                    mergingObject = require(mergingObject)
                                    for i,v in pairs(require(object)) do 
                                        mergingObject[i] = v
                                    end
                                else 
                                    warn(string.format("Conflict error occoured between local instance, %q, and framework instance, %q.", tostring(object), tostring(mergingObject)))
                                end
                            else 
                                object.Parent = module:FindFirstChild(folder.Name)
                            end
                        end
                    else
                        folder.Parent = module
                    end
                end
                framework:Destroy()
            else
                print("Custom framework", name, "Does not exist")
            end
        end

        if name=="Client" then 
            module.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
        elseif name=="Shared" then 
            module.Parent = game:GetService("ReplicatedStorage")
        elseif name=="Server" then 
            module.Parent = game:GetService("ServerStorage")
        elseif name=="SeverScripts" then 
            module.Parent = game:GetService("ServerScriptService")
        end
        local t2 = tick()
        print(string.format("Loaded %q in %s sec", name, tostring((t2 - t1) * 1)))
    end))
end