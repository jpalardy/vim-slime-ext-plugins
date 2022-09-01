vim-slime-ext-plugins
=====================

A "fork" of [vim-slime](https://github.com/jpalardy/vim-slime) to see how
easy/hard it would be to keep target/language plugins outside of this codebase.

This fork uses plugins to send data to its targets.

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

In case your plugin does not need configuration, you can use the `slime#noop` convenience at the registration step.

### Sending the data

This is the function that will actually do the work. Its paramters are the configuration and the text to send. 

```vimscript
function! SlimeFooPluginSend(config, text)
  let l:file = a:config["foo"]["file"]
  return system("cat >> " . shellescape(file), a:text) 
endfunction
```

### Registering the plugin

Vim-slime looks for the configuration function and the target function in two variables : `slime_target_send` and `slime_target_config`. Note that these variables can be defined globally or on a per-buffer lever. The variable at buffer level takes precedence. In your configuration file, you can simply add :

```vimscript
let g:slime_target_send="SlimeFooPluginSend"
let g:slime_target_config="SlimeFooPluginConfig"
```

Remember that you can use `slime#noop` here if your plugin does not need any configuration.

## Vim-slime documentation

The complete documentation is available with `:help vim-slime`.
