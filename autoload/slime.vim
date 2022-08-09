"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Target Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:TargetSend(config, text)
  let TargetSend = function(g:slime_target . "#send")
  let output = TargetSend(a:config, a:text)
  if v:shell_error
    echoerr output
  endif
endfunction

function! s:TargetConfig() abort
  if exists("b:slime_config")
    return b:slime_config
  end
  let TargetFunction = function(g:slime_target . "#config")
  let output = TargetFunction()
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

