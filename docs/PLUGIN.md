# Neovim Plugin Development Notes

I am very interested in Neovim plugin development and I haven't found great
resources online describing it so I will attempt to take some notes here on
the basic steps I'm taking to author my own Neovim plugins.

## Overview

A Neovim plugin is essentially a reusable hunk of lua code that can be shared
with others to extend the functionality of Neovim.

## Creating a new Plugin

### Step 1. Create a new local directory for your plugin

For the purpose of this document we will assume our new plugin's name will
be `acme`. 

Since our plugin name is `acme` somewhere on our local system we are going to 
create a directory named `acme.nvim`.

```shell
mkdir acme.nvim
cd acme.nvim
```

### Step 2. Create the initial directory structure for our plugin

For this step we will assume our current directory is `acme.nvim`

```shell
mkdir lua
cd lua
mkdir acme
cd acme
touch init.lua
```

At this point your plugin directory structure should look like this:

```plaintext
.
└── lua
    └── acme
        └── init.lua
```

```lua
-- lua/acme/init.lua

print("Hello from ache.nvim's init")
```

### Step 3. Integrate your new plugin with your neovim config

Typically when we are working on a new plugin idea we likely want to try it 
out for ourselves locally and iterate on it a bit before we are ready to share
it with the world. 

Before we start manipulating our local neovim configuration we need to 
grab the full path to our plugin directory. So make sure we are in the
`acme` directory then execute:

```shell
pwd
```

We should see something like `/home/fflintstone/plugins/acme.nvim`. Your path
will vary.

Now nagivate to the source code of your neovim configuration.

Add a new plugin to your Lazy config that looks like this:

```lua
{
  dir="/home/fflintstone/plugins/acme.nvim"
}
```

Now remember, your path will vary. Essentially we just need to specify the 
fully qualified path to our local plugin directory.  This table will simply
allow our local neovim configuration to load our local "new plugin".  This is
how we will experiment with our plugin before publishing it.

In my configuration I would create a new plugin file called `acme.lua` in my
plugins directory with the source:

```lua
return {
  dir="/home/fflintstone/plugins/acme.nvim"
}
```

then somewhere else in my configuration I would add 

a `require("acme")` to load my plugin manually.

At this point when we restart Neovim we should see our print statement. This
tells us that our new experimental plugin is now loaded within Neovim. This is
where we can start adding all of our cool new functionality.

### Step 4. Adding a Setup function to our plugin

Open your plugin's `init.lua` file which should now look like this:

```lua
-- lua/acme/init.lua

print("Hello from ache.nvim's init")
```

Update this file with the following:

```lua
-- lua/acme/init.lua

local M = {}

function M.setup()
  print("Hello from setup")
end

return M
```

and within your Neovim config whereever we required `acme` we can call our new
setup function like this:

```lua
require("acme").setup()
```

Restarting Neovim we should now see the message from our handy setup function.


### Step 5. Adding a user command

User commands can be bound to keymaps or they could be run in command mode
directly. In the development process I would recommend simply calling your 
user commands in command mode to check them out.


```lua
-- lua/acme/init.lua

local M = {}

function M.setup()
  print("Hello from setup")
  vim.api.nvim_create_user_command('Widget', function()
    print("Hello from the widget command")
  end, {})
end

return M
``` 

Now in command mode you can call your new custom command as follows:

```plaintext
:Widget
```



### Step 1. Create a new 

## Structurina a Neovim Plugin
