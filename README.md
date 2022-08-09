vim-slime-ext-plugins
=====================

A "fork" of [vim-slime](https://github.com/jpalardy/vim-slime) to see how
easy/hard it would be to keep target/language plugins outside of this codebase.

## Proposed plugin structure

A simple, stupid plugin that echoes the text being sent could have the following
structure :

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

function! slime_wezterm#send(config, text)
  echo a:text
endfunction
```
