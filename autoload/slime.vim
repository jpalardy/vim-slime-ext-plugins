"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Target Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" this would go in a `util` module...
function! s:resolve(...)
  for name in a:000
    if exists(name)
      return eval(name)
    endif
  endfor
  return v:null
endfunction

function! s:TargetSend(config, text)
  let b:slime_target_send = s:resolve("b:slime_target_send", "g:slime_target_send")
  if b:slime_target_send is v:null
    throw "slime_target_send is not defined"
  endif
  call function(b:slime_target_send)(a:config, a:text)
endfunction

function! s:TargetConfig(config) abort
  let b:slime_target_config = s:resolve("b:slime_target_config", "g:slime_target_config")
  if b:slime_target_config is v:null
    throw "slime_target_config is not defined"
  endif
  return function(b:slime_target_config)(a:config)
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
  call s:TargetSend(slime#config(), a:text)
endfunction

function! slime#config() abort
  if exists("b:slime_config")
    return b:slime_config
  endif
  let b:slime_config = s:resolve("g:slime_config")
  if b:slime_config is v:null
    let b:slime_config = {}
  endif
  let b:slime_config = s:TargetConfig(b:slime_config)
  return b:slime_config
endfunction

" force re-config
function! slime#reconfig() abort
  if exists("b:slime_config")
    unlet b:slime_config
  endif
  return slime#config()
endfunction

" helper function for empty configs
function! slime#noop(...)
  return {}
endfunction
