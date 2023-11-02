vim-slime-ext-plugins
=====================

A "fork" of [vim-slime](https://github.com/jpalardy/vim-slime) to see how
easy/hard it would be to keep target/language plugins outside of this codebase.

This fork uses plugins to send data to its targets.

## Vim-slime documentation and usage

The complete [documentation](doc/vim-slime.txt) is available with `:help vim-slime`.

## Upgrading from vim-slime

The new vim-slime defines most of the command and mappings that legacy
vim-slime defines, except for `<Plug>SlimeSendCell`, so your current mappings
and configuration should still work. For cells feature, please see
[vim-slime-cells](https://github.com/Klafyvel/vim-slime-cells/).

You will need a plugin for your specific target. Please see [available target plugins](#available-plugins). 
Please refer to the target plugin documentation and [Registering the plugin](#registering-the-plugin) 
below for configuration.

## Available plugins

Here are the available target plugins. If you write a new plugin for your
favourite target, please open a [pull request](https://github.com/jpalardy/vim-slime-ext-plugins/edit/main/README.md).

* Wezterm : [Klafyvel/vim-slime-ext-wezterm](https://github.com/Klafyvel/vim-slime-ext-wezterm)
* NeoVim terminal: [Klafyvel/Klafyvel/vim-slime-ext-neovim](https://github.com/Klafyvel/vim-slime-ext-neovim)

## Plugin structure

Vim-slime needs a way to configure, and a way to send text. This is
done through vim functions that you or your plugin must declare.

### Example of using a simple plugin

In this example, we are going to write a plugin that sends the text it receives to a file `foo.txt`. We need to define a function for plugin configuration, and another for handling the data.

### Configuration

The configuration function takes the current configuration in parameter and must return the updated configuration. For our example, one could write the following :

```vimscript
function! SlimeFooPluginConfig(config)
  if !exists("a:config['foo']")
    let a:config["foo"] = {"file": "foo.txt"}
  end
  let a:config["foo"]["file"] = input("Target file: ", a:config["foo"]["file"])
  return a:config
endfunction
```

In case your plugin does not need configuration, you can use the `slime#noop` convenience function at the registration step.

### Sending the data

This is the function that will actually do the work. Its paramters are the configuration and the text to send. 

```vimscript
function! SlimeFooPluginSend(config, text)
  let l:file = a:config["foo"]["file"]
  return system("cat >> " . shellescape(file), a:text) 
endfunction
```

### Registering the plugin

Vim-slime looks for the configuration function and the target function in two variables : `slime_target_send` and `slime_target_config`. Note that these variables can be defined globally or on a per-buffer level. The variable at buffer level takes precedence. In your configuration file, you can simply add :

```vimscript
let g:slime_target_send="SlimeFooPluginSend"
let g:slime_target_config="SlimeFooPluginConfig"
```

Remember that you can use `slime#noop` here if your plugin does not need any configuration.

