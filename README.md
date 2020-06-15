<h1 align="center">Framework</h1>
<div align="center">
    <a href="https://discord.gg/22Uw8ZY">
        <img src="https://img.shields.io/badge/discord-server-blue.svg">
    </a>
</div>
<p align="center">This is my personal framework I use.</p>

## Usage example
```lua
local require = require(path.to.framework.loader)
local Ambassador = require("Ambassador")
-- or
local Ambassador = require("Server.Modules.Ambassador")

local myAmbassador = Ambassador.new("myAmbassador", "RemoteEvent")
myAmbassador:Connect(function(plr, message)
    print(string.format("%s sent us a message: %s", plr.Name, message))
end)
```

This repository is licensed under MIT