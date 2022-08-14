vim-slime-ext-plugins
=====================

A "fork" of [vim-slime](https://github.com/jpalardy/vim-slime) to see how
easy/hard it would be to keep target/language plugins outside of this codebase.

## Proposed plugin structure

Vim-slime needs a way to configure, and a way to send text. Configuration is
done through a vim function, and sending through either a `system` call, or a
vim function.

### Example of using a simple `system` call.

In your configuration set 

```vimscript
let slime_target_send="cat >> foo.txt"
```

You've effectively setup a vim-slime plugin that writes everything it's sent to
'foo.txt' ! vim-slime will send any text it's supposed to send to `cat`'s STDIN.

### Example of using a simple `system` call, but with some configuration.

Let's keep going with the previous plugin, but this time we want a bit of
configuration. In `vim-slime` configuration is made on a per-buffer basis. We
need to do that using a vim function. In you configuration file, you can add the
following :

```vimscript
function! SlimeSnitchConfig()
  if !exists("b:slime_config['slime_snitch']")
    let b:slime_config["slime_snitch"] = "snitch.txt"
  end
  let b:slime_config["slime_snitch"] = input("Snitch filename : ", b:slime_config["slime_snitch"])
endfunction
```

then replace the target command with (the extra `bash -c` statement is needed to allow access to the $CONFIG
environment variable set by vim-slime. See
[here](https://unix.stackexchange.com/questions/126938/why-is-setting-a-variable-before-a-command-legal-in-bash))
:
```vimscript
let slime_target_send = "bash -c 'tee $(echo $CONFIG | jq -r .slime_snitch)'"
```

and register your configuration function (note that this is a list with one
element):
```vimscript
let slime_target_config = [function("SlimeSnitchConfig")]
```


### Example of a tiny bit more evolved plugin, using vim functions.
```
.
├── autoload
│   └── slime_echo.vim
├── LICENSE
├── plugin
│   └── slime-echo.vim
└── README.md
```

With `autoload/slime_echo.vim` being

```vimscript
function! slime_echo#config()
  if !exists("b:slime_config['echo']")
    let b:slime_config["echo"] = {"foo": "useless configuration"}
  end
endfunction

function! slime_echo#send(config, text)
  echo a:text
  return a:text
endfunction
```

Then in your configuration file :

```vimscript
let slime_target_config=[function("slime_echo#config")]
let slime_target_send=[function("slime_echo#send")]
```

### Example of chaining plugins.

vim-slime is capable of chaining plugins. This is done by providing multiple functions
and/or strings in the `slime_target_send` list. The output of each function or
shell command is fed to the next. This allows plugins to edit the text that is
being sent by vim-slime, or to send the same text at different locations. For
example, one could chain the two previous plugins by simply using the following
configuration :

```vimscript
let slime_target_config=[function("SlimeSnitchConfig"), function("slime_wezterm#config")]
let slime_target_send=["bash -c 'tee $(echo $CONFIG | jq -r .slime_snitch)'", function("slime_wezterm#send")]
```
