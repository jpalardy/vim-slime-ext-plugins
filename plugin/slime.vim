if exists('g:loaded_slime') || &cp || v:version < 700
  finish
endif
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 SlimeConfig call slime#config()

noremap <SID>Operator :<c-u>call slime#store_curpos()<cr>:set opfunc=slime#send_op<cr>g@

noremap <unique> <script> <silent> <Plug>SlimeRegionSend :<c-u>call slime#send_op(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeParagraphSend <SID>Operatorip
noremap <unique> <script> <silent> <Plug>SlimeConfig :<c-u>SlimeConfig<cr>

if !exists("g:slime_no_mappings") || !g:slime_no_mappings
  if !hasmapto('<Plug>SlimeRegionSend', 'x')
    xmap <c-c><c-c> <Plug>SlimeRegionSend
  endif

  if !hasmapto('<Plug>SlimeParagraphSend', 'n')
    nmap <c-c><c-c> <Plug>SlimeParagraphSend
  endif

  if !hasmapto('<Plug>SlimeConfig', 'n')
    nmap <c-c>v <Plug>SlimeConfig
  endif
endif
