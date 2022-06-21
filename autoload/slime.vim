"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" screen and tmux need a file, so set a default if not configured
if !exists("g:slime_paste_file")
  let g:slime_paste_file = expand("$HOME/.slime_paste")
end

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Hardcoded Tmux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:TargetSend(config, text)
  call s:WritePasteFile(a:text)
  call system("tmux load-buffer " . g:slime_paste_file)
  call system("tmux paste-buffer -d -p -t " . shellescape(a:config["target_pane"]))
endfunction

function! s:TargetConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": "{last}"}
  end
  let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"])
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:WritePasteFile(text)
  let output = system("cat > " . g:slime_paste_file, a:text)
  if v:shell_error
    echoerr output
  endif
endfunction

function! s:SlimeGetConfig()
  " b:slime_config already configured...
  if exists("b:slime_config")
    return
  end
  " prompt user
  call s:TargetConfig()
endfunction

function! slime#send_op(type, ...) abort
  call s:SlimeGetConfig()

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
  call s:SlimeGetConfig()
  call s:TargetSend(b:slime_config, a:text)
endfunction

function! slime#config() abort
  call inputsave()
  call s:TargetConfig()
  call inputrestore()
endfunction

