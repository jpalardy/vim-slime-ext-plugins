vim-slime-ext-plugins
=====================

A "fork" of [vim-slime](https://github.com/jpalardy/vim-slime) to see how
easy/hard it would be to keep target/language plugins outside of this codebase.

This fork uses plugins to send data to its targets.

## Vim-slime documentation and usage

The complete [documentation](doc/vim-slime.txt) is available with `:help vim-slime-ext-plugins.txt`.

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

In this example, we are going to write a plugin that sends the text it receives to a file `foo.txt` in the current directory. We need to define a function for plugin configuration, and another for handling the data. We also define two functions for validating the environment and validating the configuration. Check your extension plugin to see if these functions exist and if they are optional.

### Configuration

The configuration function takes the current configuration in parameter and must return the updated configuration. For our example, one could write the following :

```vim
function! SlimeFooPluginConfig(config)
  if !exists("a:config['foo']")
    let a:config["foo"] = {"file": "foo.txt"}
  end
  let a:config["foo"]["file"] = input("Target file: ", a:config["foo"]["file"])
  return a:config
endfunction
```

In case your plugin does not need configuration, you can use the `slime#noop` convenience function at the registration step.

#### Validating The Environment

 Broadly checks if the environment has requisite properties that would allow any config to be valid. Should check properties of the system and environment, not of the configuration object.
Checks if there are even any text files at all in the current working directory. If there weren't any, no configuration could be valid for this plugin.

```vim
function! SlimeFooPluginValidateEnv()
    let textFiles = glob('./*.txt')
    if textFiles == ''
        echo "No text files in current directory."
        return 0
    else
        return 1
    endif
endfunction
```


#### Validating The Configuration

Verifies that the configuration is valid.

```vim
function! SlimeFooPluginValidateConfig(config)
    if filereadable(a:config["foo"]["file"])
        return 1
    else
        echom "Config invalid. Use :SlimeConfig to Reconfigure."
        return 0
    endif
endfunction
```

### Sending the data

This is the function that will actually do the work. Its paramters are the configuration and the text to send. 

```vim
function! SlimeFooPluginSend(config, text)
  let l:file = a:config["foo"]["file"]
  return system("cat >> " . shellescape(file), a:text) 
endfunction
```

### Registering the plugin

Vim-slime looks for the configuration function and the target function in two variables : `slime_target_send` and `slime_target_config`. Note that these variables can be defined globally or on a per-buffer level. The variable at buffer level takes precedence. In your configuration file, you can simply add :

```vim
let g:slime_target_send="SlimeFooPluginSend"
let g:slime_target_config="SlimeFooPluginConfig"
let g:slime_validate_env="SlimeFooPluginValidateEnv"
let g:slime_validate_config="SlimeFooPluginValidateConfig"
```

Remember that you can use `slime#noop` here if your plugin does not need any configuration.

