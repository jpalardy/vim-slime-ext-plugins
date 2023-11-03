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
	let valid_env = 1
	if exists("*g:slime_validate_env")
		let valid_env = g:slime_validate_env()
	endif

	if valid_env
		let config = slime#config()
		if config !=# "invalid"
			call s:TargetSend(config, a:text)
		endif
	endif

endfunction

function! slime#config() abort
	let valid = 1
	if exists("b:slime_config")
		if exists("*g:slime_validate_config")")
			let valid =  g:slime_validate_config(b:slime_config)
		endif

		if valid
			return b:slime_config
		endif

	endif

	let b:slime_config = s:resolve("g:slime_config")

	if b:slime_config is v:null "implies that g:slime_config doesn't exist
		let b:slime_config = {}
	elseif exists("*g:slime_validate_config")") && !g:slime_validate_config("g:slime_config")
		let b:slime_config = {}
		unlet("g:slime_config")
	endif
	" at the end of the preceding try block, b:slime_config is either {} or a valid config

	let config = s:TargetConfig(b:slime_config)
	if exists("*g:slime_validate_config")")
		let valid = g:slime_validate_config(config)
	endif
	if valid
		let b:slime_config = config
		return config
	endif

	return "invalid"
endfunction

" force re-config
function! slime#reconfig() abort
	let valid_env = 1
	if exists("*g:slime_validate_env")
		let valid_env = g:slime_validate_env()
	endif

	if valid_env
		if exists("b:slime_config")
			unlet b:slime_config
		endif
		return slime#config()
	endif

	if exists("b:slime_config")
		" the environment is not valid but there is a local config;
		" return that config in case remediation of the environment results in
		" the existing local config being valid
		return b:slime_config
	endif
endfunction

" helper function for empty configs
function! slime#noop(...)
	return {}
endfunction

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

function! slime#send_range(startline, endline) abort
	let rv = getreg('"')
	let rt = getregtype('"')
	silent exe a:startline . ',' . a:endline . 'yank'
	call slime#send(@")
	call setreg('"', rv, rt)
endfunction


