# Documentation Format

This contains everything you'll need for the documentation standards.

## What you'll need

- [MarkdownLint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- A text editor that supports MarkdownLint

## Documenting a method/function

Generally, methods and functions will be documented inside of tables. We try to follow Roblox's standard as much as possible here.

```md
``returnType`` :MyFunction(``string`` myArgument, ``expectedArgumentType`` ``[optional]`` myOptionalVariant=``defaultValue``) ``[yields]``
```

For example:

``Vector3`` :GetSize(``Instance`` model, ``Variant`` ``[optional]`` myOptional=``3``)

``number`` :GetAsync(``string`` scope, ``integer`` ``[optional]`` amount=``4``) ``[yields]``

## How to document a library

Libraries generally follow a documentation strucutre of:

```md
# TITLE

DESCRIPTION

## API

| Property Name | Description |
|---------------|-------------|
| ... | ... |

| Function Name | Description | Returns |
|---------------|-------------|---------|
| ... | ... | ... |

```

Include anything else such as examples after the API section. Anything after should be titled too using ``##``.

## How to document a class

Documenting classes is similiar to documenting libraries but we change the names up.

```md
# TITLE

DESCRIPTION

## API

| Property Nane | Description |
|---------------|-------------|

| Method Name | Description | Returns |
|-------------|-------------|---------|

```

Same ideas as documenting libraries. If you want to add more, add it after the API section.
