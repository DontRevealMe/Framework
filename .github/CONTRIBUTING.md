Thank you for having an interest into improving the framework!

# Introduction
Please follow these guidelines if you're gonna help us.

## What you'll need
 - Understanding of concepts such as:
   - OOP
   - [Promises](https://devforum.roblox.com/t/promises-and-why-you-should-use-them/350825)
 - [Rojo](https://github.com/rojo-rbx/rojo)
 - [Selene](https://github.com/Kampfkarren/selene)

## Framework structure
The framework structure has ``sides`` which contain ``folders`` which contain ``libraries``, modules, and scripts.
Any internal module should generally be put into the side's ``__internal__``.

## Documentation
All non-internal methods must be documented using [Documentation Reader](https://devforum.roblox.com/t/documentation-reader-a-plugin-for-scripters/128825). We use RoDocs standard but there are plans to switch over to XML. 

## Coding Style
Please try to follow this naming scheme as best as you can. Generally, we follow Roblox's [coding style](https://roblox.github.io/lua-style-guide/).

### Naming scheme
 - Methods/Module functions and files will be named like ``SnakeCase``
 - Variables will be named like ``snakeCase``
 - Constants will be named like ``SNAKECASE``
 - We use .new() and not .New()

### Script heading
When naming a newly made script, use:
```lua
--[[
    Name: fileName.x.lua
    Author: Whoever made this file
    Description: Information on the file
--]]
```
If you're creating a class, name the script after the class. 

### Yielding
Generally, if you're yielding, try to see if a Promise implementation would be better.

### Practices
 - Try to avoid using ``require(id)``
 - Use tabs and not spaces