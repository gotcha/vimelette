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
    if filereadable(fn . '/parts/omelette')
      return s:sub(simplify(fnamemodify(fn . '/parts/omelette',':p')),'\W$','')
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':h')
  endwhile
  return ''
endfunction

function! s:Detect(path)
  if exists('b:omelette_dir') && b:git_dir ==# ''
    unlet b:omelette_dir
  endif
  if !exists('b:omelette_dir')
    let dir = s:ExtractOmeletteDir(a:path)
    if dir != ''
      let b:omelette_dir = dir
    endif
  endif
  if exists('b:omelette_dir')
      echo(b:omelette_dir)
  endif
endfunction

augroup vimelette
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
  autocmd FileType           netrw call s:Detect(expand('<afile>:p'))
  autocmd VimEnter * if expand('<amatch>')==''|call s:Detect(getcwd())|endif
augroup END
