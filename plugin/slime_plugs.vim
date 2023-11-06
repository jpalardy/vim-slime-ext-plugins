if exists('g:loaded_slime') || exists('g:loaded_slime_plugs') || &cp || v:version < 700
  finish
endif

let g:loaded_slime_plugs = 1
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 SlimeConfig call slime_plugs#reconfig()
command -range -bar -nargs=0 SlimeSend call slime_plugs#send_range(<line1>, <line2>)
command -nargs=+ SlimeSend1 call slime_plugs#send(<q-args> . "\r")
command -nargs=+ SlimeSend0 call slime_plugs#send(<args>)
command! SlimeSendCurrentLine call slime_plugs#send(getline(".") . "\r")

noremap <SID>Operator :<c-u>call slime_plugs#store_curpos()<cr>:set opfunc=slime_plugs#send_op<cr>g@

noremap <unique> <script> <silent> <Plug>SlimeRegionSend :<c-u>call slime_plugs#send_op(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeLineSend :<c-u>call slime_plugs#send_range(line('.'), line('.') + v:count1 - 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeMotionSend <SID>Operator
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
