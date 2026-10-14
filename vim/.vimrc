" -- Options ---------------------------------------------------
" Set leader key to Space
let mapleader = ' '
set number
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set shiftround
set list
set listchars=tab:»\ ,trail:·,nbsp:·,eob:\ 
set inccommand=split
set confirm
set splitright
set splitbelow
set ignorecase
set smartcase
set linebreak
set foldcolumn=1
set foldlevelstart=99
set foldtext=
set undofile
let &undodir = $HOME . "/.vim/undodir"
set fillchars=vert:\│,fold:\ ,foldclose:\ ,foldopen:\ ,foldsep:\ ,foldinner:\ ,msgsep:\─
set signcolumn=yes
set updatetime=300
set timeoutlen=500
set ttimeoutlen=10
set completeopt=menuone,noselect,noinsert
set pumheight=15
set laststatus=3
set cmdheight=1
set termguicolors
set wildmenu
set wildmode=noselect:lastused,full
set wildoptions=pum

let g:netrw_banner = 0
let g:netrw_showhidden = 1
let g:netrw_winsize = 25
let g:netrw_liststyle = 0
let g:netrw_browse_split = 0
let g:netrw_altfile = 1
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_python3_provider = 0

if executable('rg')
    set grepprg=rg\ --vimgrep\ --hidden\ --no-heading
    set grepformat=%f:%l:%c:%m
endif

" -- Statusline ---------------------------------------------------
function! Statusline()
    return join([
        \ '%f',
        \ '%h%w%m%r',
        \ '\%=',
        \ &filetype !=# '' ? '[' . &filetype . ']' : '',
        \ ' %-14(%l,%c%V%)',
        \ '%P',
    \ ], ' ')
endfunction
set statusline=%!Statusline()

" -- Keymaps ---------------------------------------------------
" Clear search highlights
nnoremap <Esc> :nohlsearch<CR>

" Exit terminal mode
tnoremap <Esc> <C-\><C-N>

" Indent stay in visual
vnoremap < <gv
vnoremap > >gv

" Resize splits
nnoremap <C-l> :vertical resize +2<cr>
nnoremap <C-h> :vertical resize -2<cr>
nnoremap <C-j> :resize +2<cr>
nnoremap <C-k> :resize -2<cr>

" Center cursor on move
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" Format buffer
nnoremap gQ mzgggqG`z:delmarks z<cr>zz

" Marks
cnoremap dm delmarks

" Redo
nnoremap U <C-r>

" System clipboard / Blackhole
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>p "_dP
vnoremap <leader>p "_dP
vnoremap <leader>y "+y

" Global replace selection
vnoremap <leader>r "hy:%s/<C-r>h//g<left><left>

" Split comma-list onto lines
nnoremap <leader>s :.s/, \ */,\\r/g<cr>

" Close other Buffers
nnoremap <leader>B :%bd|e#|bd#<CR>

" Terminal
nnoremap <leader>t :vsplit term://
nnoremap <leader>T :split term://

" Netrw
nnoremap <leader>e :Lexplore<cr>

" Find
nnoremap <leader>f :find 

" Grep to quickfix
nnoremap <leader>g :call GrepPrompt()<CR>

function! GrepPrompt()
    call inputsave()
    let pattern = input('Grep: ')
    call inputrestore()
    if pattern !=# ''
        execute 'silent grep! ' . fnameescape(pattern)
        copen
    endif
endfunction

" Quickfix
nnoremap <leader>q :copen<CR>
nnoremap <leader>Q :cclose<CR>

" Marks to quickfix
nnoremap <leader>m :call MarksToQuickfix()<CR>

function! MarksToQuickfix()
    let qf_items = []

    " Global uppercase marks (A-Z)
    for mark in getmarklist()
        let name = mark.mark[1:]
        let b = char2nr(name)
        if b >= 65 && b <= 90
            call add(qf_items, {
                \ 'bufnr': mark.bufnr,
                \ 'filename': mark.file,
                \ 'lnum': mark.lnum,
                \ 'col': mark.col,
                \ 'text': printf(" '%s | %s", name, getline(mark.lnum)),
            \ })
        endif
    endfor

    " Buffer-local lowercase marks (a-z)
    for bufnr in range(1, bufnr('$'))
        if buflisted(bufnr)
            for mark in getmarklist(bufnr)
                let name = mark.mark[1:]
                let b = char2nr(name)
                if b >= 97 && b <= 122
                    call add(qf_items, {
                        \ 'bufnr': bufnr,
                        \ 'filename': bufname(bufnr),
                        \ 'lnum': mark.lnum,
                        \ 'col': mark.col,
                        \ 'text': printf(" '%s | %s", name, getbufline(bufnr, mark.lnum)[0]),
                    \ })
                endif
            endfor
        endif
    endfor

    call setqflist(qf_items, 'r')
    copen
endfunction

" -- Autocommands ---------------------------------------------------
" Toggle relative numbers
augroup ToggleLineNumbers
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() !=# 'i' | set relativenumber | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave * if &nu | set norelativenumber | endif
    autocmd CmdlineEnter * if &nu | set norelativenumber | redraw | endif
augroup END

" Close specific filetypes with q
augroup CloseWithQ
    autocmd!
    autocmd FileType git,help,man,qf if &ft !=# 'help' || !&modifiable | nnoremap <buffer> q :quit<CR> | endif
augroup END

" Strip trailing whitespace
augroup RemoveWhitespaces
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END

" Strip trailing empty lines
augroup RemoveEndingEmptyLines
    autocmd!
    autocmd BufWritePre * let save_pos = getpos(".") | silent! %s/\($\n\s*\)\+\%$//e | call setpos(".", save_pos)
augroup END

" Vertical help
augroup VerticalHelp
    autocmd!
    autocmd FileType help wincmd L
augroup END

" Terminal settings
augroup TermOptions
    autocmd!
    autocmd TerminalOpen * startinsert | setlocal nonumber norelativenumber scrolloff=0
augroup END

" Active window cursorline
augroup ActiveCursorLine
    autocmd!
    autocmd WinEnter,BufEnter * setlocal cursorline
    autocmd WinLeave,BufLeave * setlocal nocursorline
augroup END

" Auto resize splits
augroup AutoResizeSplit
    autocmd!
    autocmd VimResized * wincmd =
augroup END

" Highlight on yank
augroup HighlightYank
    autocmd!
    autocmd TextYankPost * silent! let @a=@a
    autocmd TextYankPost * :hi Visual guibg=#87E58E guifg=#0e1419 | call timer_start(150, {-> execute("hi! link Visual Normal")})
augroup END

" Auto-trigger wildmenu for file-search commands
augroup CmdlineWildTrigger
    autocmd!
    autocmd CmdlineChanged : call CmdlineWildTrigger()
augroup END

function! CmdlineWildTrigger()
    let cmd = getcmdline()
    for pat in ['^find?', '^bu?f?f?e?r?', '^e', '^edit']
        if cmd =~# pat . '\s' || cmd =~# pat . '$'
            call wildtrigger()
            return
        endif
    endfor
endfunction
