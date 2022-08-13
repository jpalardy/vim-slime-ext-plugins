"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Target Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TargetSend tries to send the text and its config to the right place, by
" finding the first existing variable in this list and performing the
" corresponding action.
" 1. b:slime_target_send  -> Trying to execute a `system` call, passing the
" configuration in a `CONFIG` environment variable,
" 2. b:SlimeTargetSend    -> Calling the function with `config` and `text`,
" 3. g:slime_target_send  ->  Trying to execute a `system` call, passing the
" configuration in a `CONFIG` environment variable,
" 4. g:SlimeTargetSend    -> Calling the function with `config` and `text`.
function! s:TargetSend(config, text)
  if exists("b:slime_target_send")
    let output = system("CONFIG=" . shellescape(a:config) . " " . b:slime_target_send, a:text)
  elseif exists("*b:SlimeTargetSend")||exists("b:SlimeTargetSend") 
    let output = b:SlimeTargetSend(a:config, a:text)
  elseif exists("g:slime_target_send")
    let output = system("CONFIG=" . shellescape(a:config) . " " . g:slime_target_send, a:text)
  elseif exists("*g:SlimeTargetSend")||exists("g:SlimeTargetSend") 
    let output = g:SlimeTargetSend(a:config, a:text)
  else
    echoerr "vim-slime could not determine a valid target !"
  endif
  if v:shell_error
    echoerr output
  endif
endfunction

" TargetConfig tries to configure vim-slime. It looks for a function to
" delegate to and calls the first defined function in this list :
" 1. b:SlimeTargetConfig
" 2. g:SlimeTargetConfig
"
" If nothing is found, it silently returns an empty string, allowing for
" no-configuration plugins.
function! s:TargetConfig() abort
  if exists("b:slime_config")
    return b:slime_config
  end
  if exists("*b:SlimeTargetConfig")||exists("b:SlimeTargetConfig") 
    let output = b:SlimeTargetConfig()
  elseif exists("*g:SlimeTargetConfig")||exists("g:SlimeTargetConfig")
    let output = g:SlimeTargetConfig()
  else
    return ""
  endif
  if v:shell_error
    echoerr output
    return ""
  endif
  return b:slime_config
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! slime#send_op(type, ...) abort
  let sel_save = &selection
  let &selection = "inclusive"
  let rv = getreg('"')
  let rt = getregtype('"')

  if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . '`>y'
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]\y"
  else
    silent exe "normal! `[v`]y"
  endif

  call setreg('"', @", 'V')
  call slime#send(@")

  let &selection = sel_save
  call setreg('"', rv, rt)

  call s:SlimeRestoreCurPos()
endfunction

function! slime#store_curpos()
  let s:cur = winsaveview()
endfunction

function! s:SlimeRestoreCurPos()
  if exists("s:cur")
    call winrestview(s:cur)
    unlet s:cur
  endif
endfunction

function! slime#send_range(startline, endline) abort
  call s:TargetConfig()

  let rv = getreg('"')
  let rt = getregtype('"')
  silent exe a:startline . ',' . a:endline . 'yank'
  call slime#send(@")
  call setreg('"', rv, rt)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Public interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! slime#send(text)
  call s:TargetSend(s:TargetConfig(), a:text)
endfunction

function! slime#config() abort
  if exists("b:slime_config")
    unlet b:slime_config
  end
  call s:TargetConfig()
endfunction

