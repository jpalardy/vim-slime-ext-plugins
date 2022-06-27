"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Hardcoded Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:TargetSend(config, text)
  let output = system("CONFIG=" . shellescape(a:config) . " send-to-tmux", a:text)
  if v:shell_error
    echoerr output
  endif
endfunction

function! s:TargetConfig() abort
  if exists("b:slime_config")
    return b:slime_config
  end
  let output = system("send-to-tmux --config")
  if v:shell_error
    echoerr output
    return ""
  endif
  let b:slime_config = output
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

