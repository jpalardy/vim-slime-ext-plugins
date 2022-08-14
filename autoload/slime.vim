"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Target Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TargetSend tries to send the text and its config to the right place.
" It tries to use b:slime_target_send and defaults to g:slime_target_send.
" b:slime_target_send can be either a string, in this case vim-slime wraps it
" into a list, or a list of strings and functions.
"
" When processing a list, vim-slime chains the output of each element of the
" list. If an element is a string it executes a `system` call, if its a
" function it executes the function.
function! s:TargetSend(config, text)
  if exists("g:slime_target_send") && !exists("b:slime_target_send")
    let b:slime_target_send = g:slime_target_send
  endif
  if !exists("b:slime_target_send")
    echoerr "vim-slime could not find slime_target_send."
    return ""
  endif
  let type_of_target = type(b:slime_target_send)
  if type_of_target == v:t_string
    let b:slime_target_send = [b:slime_target_send]
  elseif type_of_target != v:t_list
    echoerr "vim-slime got unsupported type for slime_target_send. Must be either List or String."
  endif
  let output_text = a:text
  " We need to iterate over the indices because slime_target_send can store
  " either functions or strings, and there are different variable naming rules
  " for those two types in vimscript.
  for i in range(len(b:slime_target_send))
    let type_of_item = type(b:slime_target_send[i])
    if type_of_item == v:t_string
      let output_text = system("CONFIG=" . shellescape(json_encode(a:config)) . " " . b:slime_target_send[i], output_text)
      if v:shell_error
        echoerr output_text
        break
      endif
    elseif type_of_item == v:t_func
      let output_text = b:slime_target_send[i](a:config, output_text)
    else
      echoerr "Item " . i . " of slime_target_send is of invalid type. Only strings and functions are supported."
      break
    endif
  endfor
endfunction

" TargetConfig tries to configure vim-slime. It looks for a functions to
" delegate to in b:slime_target_config or in g:slime_target_config.
"
" If nothing is found, it silently returns an empty string, allowing for
" no-configuration plugins.
function! s:TargetConfig() abort
  if exists("b:slime_config")
    return b:slime_config
  endif
  if exists("g:slime_target_config") && !exists("b:slime_target_config")
    let b:slime_target_config = g:slime_target_config
  endif
  " Silently exit if no configuration functions list exists.
  if !exists("b:slime_target_config")
    return ""
  endif
  let b:slime_config = {}
  for ConfigurationFunction in b:slime_target_config
    call ConfigurationFunction()
  endfor
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

