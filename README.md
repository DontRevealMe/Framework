<h1 align="center">Framework</h1>
<div align="center">
    <a href="https://discord.gg/22Uw8ZY">
        <img src="https://img.shields.io/badge/discord-server-blue.svg">
    </a>
    <a href="https://github.com/DontRevealMe/Framework/actions?query=workflow%3ACI">
        <img src="https://github.com/DontRevealMe/Framework/workflows/CI/badge.svg">
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

## Credits
This repository couldn't be made without the help of:
 - [Promise](https://github.com/evaera/roblox-lua-promise)
 - [Signal](https://gist.github.com/Anaminus/afd813efc819bad8e560caea28942010)
 - [t](https://devforum.roblox.com/t/t-a-runtime-type-checker-for-roblox/139769)

### Inspired from
 - [NevermoreEngine](https://github.com/Quenty/NevermoreEngine)
 - [DataStore2](https://github.com/Kampfkarren/Roblox/)

This repository is licensed under MIT