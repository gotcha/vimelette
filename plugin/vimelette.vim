if exists('g:loaded_vimelette') || &cp
  if !exists('g:debug_vimelette')
    finish
  endif  
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
import rope
import ropevim
import vim
import os
from rope.contrib import autoimport

def open_project(self, root):
    if self.project is not None:
        self.close_project()
    address = rope.base.project._realpath(os.path.join(root,
                                                       '.ropeproject'))
    progress = self.env.create_progress('Opening [%s] project' % root)
    self.project = rope.base.project.Project(root)
    if self.env.get('enable_autoimport'):
        underlined = self.env.get('autoimport_underlineds')
        self.autoimport = autoimport.AutoImport(self.project,
                                                underlined=underlined)
    progress.done()

omelette_path = vim.eval('a:omelette_path')
interface = ropevim._interface
if interface.project is None or interface.project.address != omelette_path:
    open_project(interface, omelette_path)
    ropevim.echo("Rope project opened at %s" % omelette_path)
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
  
function! s:checkOmelette()
  if !exists("g:omelette_path")
    let g:omelette_path = input("Omelette Path: ", ".", "file")
  endif
endfunction

function! OmeletteExplore()
  call s:checkOmelette()
  exec 'Explore '. g:omelette_path  
endfunction

command! OmeletteExplore call OmeletteExplore()
nmap <silent> <Leader>oe :OmeletteExplore<CR>

function! OmeletteWhich()
    if !exists("g:omelette_path")
        echo "No omelette"
    else
        echo "Omelette at " . g:omelette_path
    endif
endfunction

command! OmeletteWhich call OmeletteWhich()
nmap <silent> <Leader>ow :OmeletteWhich<CR>

function! OmeletteGrep(args)
    call s:checkOmelette()
    execute "!grep " . a:args . ' ' . g:omelette_path
    botright copen
    exec "redraw!"
endfunction

command! -nargs=*  OmeletteGrep call OmeletteGrep(<q-args>)

"Command T plugin
"
if exists("g:command_t_loaded")

  function! OmeletteCommandT()
    call s:checkOmelette()
    exec 'CommandT '. g:omelette_path  
  endfunction
  
  command! OmeletteCommandT call OmeletteCommandT()
  nmap <silent> <Leader>oct :OmeletteCommandT<CR>
endif

"NerdTree plugin
"
if exists("loaded_nerd_tree")

  function! OmeletteNerd()
    call s:checkOmelette()
    exec 'NERDTreeToggle '. g:omelette_path  
  endfunction
  
  command! OmeletteNerd call OmeletteNerd()
  nmap <silent> <Leader>ont :OmeletteNerd<CR>
endif

"Ack plugin
"
if exists("g:ackprg")

  function! OmeletteAck(args)
    call s:checkOmelette()
    let args = a:args . ' --follow ' . g:omelette_path
    call Ack(args)
  endfunction

  command! -nargs=*  OmeletteAck call OmeletteAck(<q-args>)
endif
