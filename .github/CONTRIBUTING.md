# Contributing

Thank you for having an interest into improving the framework!

## Introduction

Please follow these guidelines if you're gonna help us.

## What you'll need

- Understanding of concepts such as:
  - OOP
  - [Promises](https://devforum.roblox.com/t/promises-and-why-you-should-use-them/350825)
- [Rojo](https://github.com/rojo-rbx/rojo)
- [Selene](https://github.com/Kampfkarren/selene)

## Framework structure

The framework structure has ``sides`` which contain ``folders`` which contain ``libraries``, modules, and scripts. Any internal module should generally be put into the side's ``__internal__``.

## Documentation

It's now optional to document using [Documentation Reader](https://devforum.roblox.com/t/documentation-reader-a-plugin-for-scripters/128825).
We now use [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) to document code. To find documentation standards go [here].

## Coding Style

Please try to follow this naming scheme as best as you can. Generally, we follow Roblox's [coding style](https://roblox.github.io/lua-style-guide/).

### Naming scheme

| Type | Naming Scheme |
|------|---------------|
| Methods | SnakeCase |
| Functions | SnakeCase |
| Files | SnakeCase |
| Variables | snakeCase |
| Internal methods | _snakeCase |
| Internal properties | _snakeCase |
| Constructors | new() / snakeCase |
| Destructors | Destroy() / SnakeCase |

### Script heading

When naming a newly made script, use:

```lua
--  description
--  @author name1, name2, John Doe, Tim, ...

code
...
```

If you're creating a class, name the script after the class.

### Yielding

Generally, if you're yielding, try to see if a Promise implementation would be better.

### Practices

- Try to avoid using ``require(id)``
- Use tabs and not spaces
