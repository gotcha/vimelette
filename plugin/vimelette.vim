if exists('g:loaded_vimelette') || &cp
  finish
endif
let g:loaded_vimelette = 1

function! s:sub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:shellslash(path)
  if exists('+shellslash') && !&shellslash
    return s:gsub(a:path,'\\','/')
  else
    return a:path
  endif
endfunction

function! s:ExtractOmeletteDir(path) abort
  let path = s:shellslash(a:path)
  let fn = fnamemodify(path,':s?[\/]$??')
  let ofn = ""
  let nfn = fn
  while fn != ofn
    if isdirectory(fn . '/parts/omelette')
      return s:sub(simplify(fnamemodify(fn . '/parts/omelette',':p')),'\W$','')
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':h')
  endwhile
  return ''
endfunction

function! s:Detect(path)
  "echom a:path
  if exists('b:omelette_path') && b:omelette_path == ''
    unlet b:omelette_path
  endif
  if !exists('b:omelette_path')
    let dir = s:ExtractOmeletteDir(a:path)
    if dir != ''
      let b:omelette_path = dir
      let g:omelette_path = dir
    endif
  else
    let g:omelette_path = b:omelette_path
  endif
  call s:SetGlobal()
endfunction

function! s:SetGlobal()
  if exists("g:ropevim_loaded") && !exists("*s:RopeSetup")
    function! s:RopeSetup(omelette_path)
      python << EOF
import ropevim
import vim
omelette_path = vim.eval('a:omelette_path')
interface = ropevim._interface
if interface.project is None or interface.project.address != omelette_path:
    interface.open_project(omelette_path)
    ropevim.echo("project opened")
EOF
    endfunction
  endif
  if exists('g:omelette_path') && exists("*s:RopeSetup")
    call s:RopeSetup(g:omelette_path)
  endif
endfunction

augroup vimelette
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
  autocmd BufEnter * call s:SetGlobal()
  autocmd FileType           netrw call s:Detect(expand('<afile>:p'))
  autocmd VimEnter * call s:Detect(getcwd())
augroup END
  
if exists("g:command_t_loaded")
  nmap <silent> <Leader>co :call CommandTOmelette()<CR>

  function! CommandTOmelette()
    if !exists("g:omelette_path")
      let g:omelette_path = input("Omelette Path: ", ".", "file")
    endif
    exec 'CommandT '. g:omelette_path  
  endfunction
endif

