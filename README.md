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
function! SlimeTargetConfig()
  if !exists("b:slime_config")
    let b:slime_config = ""
  endif
  let b:slime_config = input("Target file name :", b:slime_config) 
endfunction
```

and replace the target command with :

```vimscript
slime_target_send="bash -c 'cat >> $CONFIG'"
```

(the extra `bash -c` statement is needed to allow access to the $CONFIG
environment variable set by vim-slime. See [here](https://unix.stackexchange.com/questions/126938/why-is-setting-a-variable-before-a-command-legal-in-bash))

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
endfunction
```

Then in your configuration file :

```vimscript
let SlimeTargetConfig=function("slime_wezterm#config")
let SlimeTargetSend=function("slime_wezterm#send")
```
