scriptencoding utf-8

" =================================================================
" 1. エンコーディング・基本設定・パフォーマンス
" =================================================================
if &shell =~# 'fi\(z\)\?sh' && executable('/bin/sh')
  set shell=/bin/sh
  set shellcmdflag=-c
  set shellredir=>%s\ 2>&1
endif

" Flutter / Dart (Snap版) / Go のパス設定
let s:flutter_sdk = '/home/kotaro/snap/flutter/common/flutter'
let s:dart_sdk = s:flutter_sdk . '/bin/cache/dart-sdk'

if isdirectory(s:flutter_sdk)
  let $FLUTTER_ROOT = s:flutter_sdk
endif
if isdirectory(s:dart_sdk)
  let $DART_SDK = s:dart_sdk
endif

for s:extra_bin in [
      \ s:dart_sdk . '/bin',
      \ s:flutter_sdk . '/bin',
      \ '/snap/bin',
      \ expand('~/.pub-cache/bin'),
      \ expand('/usr/bin'),
      \ ]
  if isdirectory(s:extra_bin) && stridx(':' . $PATH . ':', ':' . s:extra_bin . ':') < 0
    let $PATH = s:extra_bin . ':' . $PATH
  endif
endfor

set encoding=utf-8
set fileencodings=utf-8,euc-jp,sjis,cp932,iso-2022-jp
set fileformats=unix,dos,mac
set ambiwidth=single

set hidden
set autoread
set nowritebackup
set nobackup
set noswapfile
set backspace=indent,eol,start
set updatetime=128 " LSP応答・GitGutter・単語ハイライトを高速化 (0.1秒)
set timeoutlen=500
set ttimeoutlen=10 " EscやAltキーの待ち時間を極小化
set synmaxcol=300  " 長い行での描画遅延を防止
set history=350

if has('persistent_undo')
  let s:undo_dir = expand('~/.vim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
  endif
  let &undodir = s:undo_dir
  set undofile
endif

" =================================================================
" 2. プラグイン管理 (vim-plug)
" =================================================================
call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-plug'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }

" Flutter / Dart サポート
Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'

" LSP & 自動補完 (vim-lsp + asyncomplete + fzf連携)
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'wellle/context.vim'
"Plug 'mhinz/vim-crates'

" スニペット & 括弧自動補完 (yasnippet + electric-pair-mode 相当)
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'cohama/lexima.vim'

" Git差分・インデント縦線・キーガイド (diff-hl / indent-bars / which-key 相当)
Plug 'airblade/vim-gitgutter'
Plug 'Yggdroot/indentLine'
Plug 'liuchengxu/vim-which-key'

" 辞書・翻訳・その他
Plug 'thinca/vim-ref'
Plug 'mfumi/ref-dicts-en'
Plug 'tyru/vim-altercmd'
Plug 'mattn/webapi-vim'
Plug 'skanehira/translate.vim'

" Git操作・ログ閲覧・Blameポップアップ
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'rhysd/git-messenger.vim'
call plug#end()

filetype plugin indent on
syntax enable

" =================================================================
" 3. TrueColor & 黒背景に映えるグリーン基調
" =================================================================
if has('termguicolors')
  if !has('gui_running') && !has('win32')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
    let &t_8u = "\e[58;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif

set background=dark
set number
set cursorline
set signcolumn=yes
set showmatch
set matchtime=0
set laststatus=2
set showcmd
set wildmenu
set wildmode=longest:full,full
set title
set noerrorbells
set visualbell t_vb=
set scrolloff=5
set sidescrolloff=5
set splitbelow
set splitright
set fillchars+=vert:│

function! s:apply_init_el_highlights() abort
  highlight Normal       cterm=NONE ctermbg=NONE guibg=NONE ctermfg=252 guifg=#bcbec4
  highlight NonText      cterm=NONE ctermbg=NONE guibg=NONE ctermfg=239 guifg=#43454a
  highlight EndOfBuffer  cterm=NONE ctermbg=NONE guibg=NONE ctermfg=239 guifg=#43454a
  highlight LineNr       cterm=NONE ctermbg=NONE guibg=NONE ctermfg=241 guifg=#5a5d63
  highlight CursorLineNr cterm=bold ctermbg=NONE guibg=NONE ctermfg=255 guifg=#e8eaed gui=bold
  highlight CursorLine   cterm=NONE ctermbg=NONE guibg=NONE
  highlight SignColumn   cterm=NONE ctermbg=NONE guibg=NONE
  highlight VertSplit    cterm=NONE ctermbg=NONE guibg=NONE ctermfg=238 guifg=#323438

  highlight StatusLine   cterm=NONE ctermbg=235 ctermfg=250 gui=NONE guibg=#1e1f22 guifg=#abb2bf
  highlight StatusLineNC cterm=NONE ctermbg=233 ctermfg=240 gui=NONE guibg=#141517 guifg=#5a5d63

  highlight Visual       cterm=NONE ctermbg=24  gui=NONE guibg=#214283
  highlight MatchParen   cterm=bold ctermbg=237 ctermfg=79  gui=bold guibg=#35373b guifg=#73c991
  highlight Search       cterm=NONE ctermbg=95  ctermfg=255 gui=NONE guibg=#4d3a1a guifg=#e5c07b
  highlight IncSearch    cterm=bold ctermbg=209 ctermfg=235 gui=bold guibg=#d19a66 guifg=#1e1f22

  highlight Comment      cterm=NONE ctermfg=242 gui=italic guifg=#6e7681
  highlight Include      cterm=NONE ctermfg=108 gui=NONE   guifg=#85b891
  highlight PreProc      cterm=NONE ctermfg=108 gui=NONE   guifg=#85b891
  highlight Define       cterm=NONE ctermfg=108 gui=NONE   guifg=#85b891
  highlight Macro        cterm=NONE ctermfg=115 gui=NONE   guifg=#6cb6ff

  highlight String       cterm=NONE ctermfg=71  gui=NONE   guifg=#6aab73
  highlight Character    cterm=NONE ctermfg=71  gui=NONE   guifg=#6aab73

  highlight Constant     cterm=NONE ctermfg=140 gui=italic guifg=#c77dbb
  highlight Number       cterm=NONE ctermfg=73  gui=NONE   guifg=#56b6c2
  highlight Boolean      cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Float        cterm=NONE ctermfg=73  gui=NONE   guifg=#56b6c2

  highlight Identifier   cterm=NONE ctermfg=252 gui=NONE   guifg=#bcbec4
  highlight Function     cterm=NONE ctermfg=74  gui=NONE   guifg=#56a8f5

  highlight Statement    cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Conditional  cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Repeat       cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Label        cterm=NONE ctermfg=108 gui=NONE   guifg=#85b891
  highlight Operator     cterm=NONE ctermfg=250 gui=NONE   guifg=#9da5b4
  highlight Keyword      cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Exception    cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight StorageClass cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d

  highlight Type         cterm=NONE ctermfg=79  gui=NONE   guifg=#4ec9b0
  highlight Structure    cterm=NONE ctermfg=79  gui=NONE   guifg=#4ec9b0
  highlight Typedef      cterm=NONE ctermfg=79  gui=NONE   guifg=#4ec9b0

  highlight Special      cterm=NONE ctermfg=108 gui=NONE   guifg=#85b891
  highlight SpecialChar  cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight Todo         cterm=bold ctermbg=NONE ctermfg=114 gui=bold guibg=NONE guifg=#85b891

  highlight rustKeyword       cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight rustStorage       cterm=NONE ctermfg=173 gui=NONE   guifg=#cf8e6d
  highlight rustModPath       cterm=NONE ctermfg=115 gui=NONE   guifg=#73b7a8
  highlight rustModPathSep    cterm=NONE ctermfg=244 gui=NONE   guifg=#6e7681
  highlight rustEnumVariant   cterm=NONE ctermfg=140 gui=italic guifg=#c77dbb
  highlight rustAttribute     cterm=NONE ctermfg=180 gui=NONE   guifg=#b3ae60
  highlight rustDerive        cterm=NONE ctermfg=180 gui=NONE   guifg=#b3ae60
  highlight rustDeriveTrait   cterm=NONE ctermfg=79  gui=NONE   guifg=#4ec9b0
  highlight rustLifetime      cterm=NONE ctermfg=73  gui=italic guifg=#56b6c2

  highlight Pmenu        cterm=NONE ctermbg=235 ctermfg=251 gui=NONE guibg=#1e1f22 guifg=#bcbec4
  highlight PmenuSel     cterm=bold ctermbg=24  ctermfg=255 gui=bold guibg=#214283 guifg=#ffffff
  highlight PmenuSbar    ctermbg=236 guibg=#2b2d30
  highlight PmenuThumb   ctermbg=240 guibg=#4e5157
  highlight PmenuKind    cterm=NONE ctermbg=235 ctermfg=108 gui=NONE guibg=#1e1f22 guifg=#85b891
  highlight PmenuExtra   cterm=NONE ctermbg=235 ctermfg=242 gui=NONE guibg=#1e1f22 guifg=#6e7681

  highlight lspInlayHintsType      cterm=NONE ctermbg=NONE ctermfg=241 gui=NONE guibg=NONE guifg=#5a5d63
  highlight lspInlayHintsParameter cterm=NONE ctermbg=NONE ctermfg=241 gui=NONE guibg=NONE guifg=#5a5d63

  " エラー・警告のハイライト
  highlight LspErrorHighlight       cterm=undercurl gui=bold,undercurl guifg=#ff8792 guibg=NONE guisp=#f75464 ctermbg=NONE ctermfg=210
  highlight LspWarningHighlight     cterm=undercurl gui=bold,undercurl guifg=#f2cc60 guibg=NONE guisp=#e0bb65 ctermbg=NONE ctermfg=221
  highlight LspInformationHighlight cterm=undercurl gui=undercurl      guifg=#79c0ff guibg=NONE guisp=#56a8f5 ctermbg=NONE ctermfg=117
  highlight LspHintHighlight        cterm=NONE      gui=NONE           guifg=#6e7681 guibg=NONE ctermbg=NONE ctermfg=242

  " カーソル下の同一シンボルハイライト
  highlight LspReferenceText        cterm=NONE ctermbg=236 ctermfg=NONE gui=NONE guibg=#1e2d3d guifg=NONE
  highlight LspReferenceRead        cterm=NONE ctermbg=236 ctermfg=NONE gui=NONE guibg=#1e2d3d guifg=NONE
  highlight LspReferenceWrite       cterm=NONE ctermbg=237 ctermfg=NONE gui=NONE guibg=#2d2638 guifg=NONE

  highlight LspErrorText            cterm=bold gui=bold guifg=#f75464 ctermfg=203 ctermbg=NONE guibg=NONE
  highlight LspWarningText          cterm=bold gui=bold guifg=#e0bb65 ctermfg=228 ctermbg=NONE guibg=NONE
  highlight LspInformationText      cterm=bold gui=bold guifg=#56a8f5 ctermfg=117 ctermbg=NONE guibg=NONE
  highlight LspHintText             cterm=bold gui=bold guifg=#85b891 ctermfg=108 ctermbg=NONE guibg=NONE

  highlight GitGutterAdd    guifg=#6aab73 ctermfg=71  ctermbg=NONE guibg=NONE
  highlight GitGutterChange guifg=#e0bb65 ctermfg=228 ctermbg=NONE guibg=NONE
  highlight GitGutterDelete guifg=#f75464 ctermfg=203 ctermbg=NONE guibg=NONE

  highlight Directory       cterm=NONE ctermfg=108 gui=NONE guifg=#85b891
  highlight NERDTreeDir     cterm=NONE ctermfg=108 gui=NONE guifg=#85b891
  highlight NERDTreeUp      cterm=NONE ctermfg=242 gui=NONE guifg=#6e7681
  highlight NERDTreeHelp    cterm=NONE ctermfg=242 gui=NONE guifg=#6e7681

  highlight SymbolOverlay1 ctermbg=24  guibg=#214283 guifg=#ffffff gui=bold
  highlight SymbolOverlay2 ctermbg=22  guibg=#244f36 guifg=#ffffff gui=bold
  highlight SymbolOverlay3 ctermbg=95  guibg=#5c3d5c guifg=#ffffff gui=bold
  highlight SymbolOverlay4 ctermbg=58  guibg=#5e491e guifg=#ffffff gui=bold
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme,VimEnter * call s:apply_init_el_highlights()
  autocmd ModeChanged *:[vV\x16]* set nocursorline
  autocmd ModeChanged [vV\x16]*:* set cursorline
augroup END
call s:apply_init_el_highlights()

" ステータスライン用パス解決（バッファごとにキャッシュして毎フレームのfinddir I/Oを回避）
function! SmartFilePath() abort
  let l:raw_path = expand('%:p')
  if empty(l:raw_path) | return '%b' | endif

  let l:cache_key = l:raw_path . '|' . getcwd()
  if get(b:, 'smart_filepath_key', '') !=# l:cache_key
    let b:smart_filepath_key = l:cache_key
    let l:file = tr(l:raw_path, '\', '/')
    let l:git_dir = finddir('.git', expand('%:p:h') . ';')
    if !empty(l:git_dir)
      let l:root = tr(fnamemodify(l:git_dir, ':p:h:h'), '\', '/')
      let b:smart_filepath_proj = fnamemodify(l:root, ':t')
      let b:smart_filepath_rel = substitute(l:file, '^' . escape(l:root, '\') . '/', '', '')
      let b:smart_filepath_is_git = 1
    else
      let b:smart_filepath_is_git = 0
      let b:smart_filepath_fallback = expand('%:~:.')
    endif
  endif

  if get(b:, 'smart_filepath_is_git', 0)
    let l:branch = exists('*FugitiveHead') ? FugitiveHead() : ''
    let l:branch_str = !empty(l:branch) ? ' (' . l:branch . ')' : ''
    return '[' . b:smart_filepath_proj . l:branch_str . '] ' . b:smart_filepath_rel
  endif
  return b:smart_filepath_fallback
endfunction

set statusline=%<\ %{SmartFilePath()}\ %m%r%h%w\ %{LspBreadcrumbs()}%=%{&fenc!=''?&fenc:&enc}\ [%{&ff}]\ %y\ \ %l/%L:%c\ (%p%%)\

" =================================================================
" 4. インデント・検索・クリップボード・Shift選択
" =================================================================
if has('clipboard')
  set clipboard=unnamedplus,unnamed
endif

set guioptions-=a

set mouse=a
if has('mouse_sgr')
  set ttymouse=sgr
endif

nnoremap <silent> <Esc>[I <Nop>
nnoremap <silent> <Esc>[O <Nop>
inoremap <silent> <Esc>[I <Nop>
inoremap <silent> <Esc>[O <Nop>
cnoremap <silent> <Esc>[I <Nop>
cnoremap <silent> <Esc>[O <Nop>

set selectmode=key
set keymodel=startsel,stopsel

set shiftwidth=2 tabstop=2 softtabstop=2 expandtab autoindent smartindent
augroup FileTypeIndent
  autocmd!
  autocmd FileType c,cpp,rust,python,php,java,kotlin,gradle,groovy setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab
  autocmd FileType go,gomod setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab
  autocmd FileType sh,dart,yaml,json,html,css setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
augroup END

let g:indentLine_char = '│'
let g:indentLine_defaultGroup = 'NonText'
let g:indentLine_fileTypeExclude = ['help', 'nerdtree', 'tagbar', 'qf']

set hlsearch incsearch wrapscan ignorecase smartcase
set tags=.tags;
set path+=..,/usr/share/dpkg,;

" =================================================================
" 5. Git連携設定 (fugitive / gitgutter / gv / git-messenger / fzf)
" =================================================================
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <C-c>vp <Plug>(GitGutterPreviewHunk)
nmap <C-c>vs <Plug>(GitGutterStageHunk)
nmap <C-c>vu <Plug>(GitGutterUndoHunk)

nnoremap <silent> <C-c>vv :Git<CR>
nnoremap <silent> <C-c>vd :Gdiffsplit<CR>
nnoremap <silent> <C-c>vb :Git blame<CR>
nnoremap <silent> <C-c>vc :Git commit<CR>
nnoremap <silent> <C-c>vP :Git push<CR>

nnoremap <silent> <C-c>vl :GV<CR>
nnoremap <silent> <C-c>vL :GV!<CR>
nnoremap <silent> <C-c>vf :GFiles?<CR>
nnoremap <silent> <C-c>vh :BCommits<CR>

nmap <C-c>vm <Plug>(git-messenger)
let g:git_messenger_floating_win_opts = { 'border': 'single' }
let g:git_messenger_popup_content_margins = v:false

augroup MyGitConfig
  autocmd!
  autocmd FileType fugitive,git,gv nnoremap <buffer> <silent> q :<C-u>close<CR>
augroup END

" =================================================================
" 5-a. LazyGit フローティングウィンドウ設定 (プラグイン不要版)
" =================================================================
function! s:open_lazygit() abort
  if !executable('lazygit')
    echohl ErrorMsg | echo 'lazygit がインストールされていません' | echohl None
    return
  endif

  let l:git_dir = finddir('.git', expand('%:p:h') . ';')
  let l:cwd = !empty(l:git_dir) ? fnamemodify(l:git_dir, ':p:h:h') : getcwd()

  if exists('*popup_create') && exists('*term_start')
    let l:buf = term_start(['lazygit'], {
          \ 'cwd': l:cwd,
          \ 'hidden': 1,
          \ 'term_finish': 'close',
          \ })
    let l:width = float2nr(&columns * 0.90)
    let l:height = float2nr(&lines * 0.85)
    call popup_create(l:buf, {
          \ 'minwidth': l:width,
          \ 'maxwidth': l:width,
          \ 'minheight': l:height,
          \ 'maxheight': l:height,
          \ 'title': ' LazyGit (q:終了 / ?:ヘルプ) ',
          \ 'border': [],
          \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
          \ 'highlight': 'Normal',
          \ 'borderhighlight': ['VertSplit'],
          \ 'callback': function('s:on_lazygit_close'),
          \ })
  else
    execute 'tab terminal ++close ++cwd=' . fnameescape(l:cwd) . ' lazygit'
  endif
endfunction

function! s:on_lazygit_close(id, result) abort
  silent! checktime
  if exists(':GitGutterAll')
    silent! GitGutterAll
  endif
endfunction

command! LazyGit call s:open_lazygit()
nnoremap <silent> <C-c>l :<C-u>LazyGit<CR>

" =================================================================
" 6. ペースト時の「相対インデント自動整形」 & F9 コピペ用クリーン表示トグル
" =================================================================
function! s:paste_relative_indent(cmd) abort
  let l:reg_text = getreg(v:register)
  if strlen(l:reg_text) > 5000 || &buftype !=# '' || stridx(l:reg_text, "\n") < 0
    execute 'normal! "' . v:register . a:cmd
    return
  endif
  if &filetype =~# '^\(c\|cpp\|rust\|python\|php\|sh\|dart\|java\|kotlin\|gradle\|go\|yaml\|xml\|javascript\|typescript\|html\|css\|vim\|lua\)$'
    try
      execute 'normal! "' . v:register . (a:cmd ==# 'p' ? ']p' : '[p')
      return
    catch
    endtry
  endif
  execute 'normal! "' . v:register . a:cmd
endfunction

nnoremap <silent> p :<C-u>call <SID>paste_relative_indent('p')<CR>
nnoremap <silent> P :<C-u>call <SID>paste_relative_indent('P')<CR>

let s:clean_copy_mode = 0
function! s:toggle_clean_copy_view() abort
  let s:clean_copy_mode = !s:clean_copy_mode
  if s:clean_copy_mode
    set nonumber norelativenumber signcolumn=no
    silent! GitGutterDisable
    silent! IndentLinesDisable
    echo 'Clean copy mode: ON (コピペ用・装飾オフ)'
  else
    set number signcolumn=yes
    silent! GitGutterEnable
    silent! IndentLinesEnable
    echo 'Clean copy mode: OFF (通常表示)'
  endif
endfunction
nnoremap <silent> <F9> :<C-u>call <SID>toggle_clean_copy_view()<CR>

" =================================================================
" 7. Emacs風スマート移動 & 便利キーバインド
" =================================================================
function! s:mwim_beginning_expr() abort
  let l:first_nonblank = match(getline('.'), '\S') + 1
  if l:first_nonblank == 0
    return '0'
  endif
  return col('.') == l:first_nonblank ? '0' : '^'
endfunction

function! s:mwim_beginning_i() abort
  let l:first_nonblank = match(getline('.'), '\S') + 1
  if l:first_nonblank == 0
    return "\<Home>"
  endif
  return col('.') == l:first_nonblank ? "\<Home>" : "\<C-o>^"
endfunction

function! s:mwim_end_expr() abort
  return (col('.') == col('$') - 1 && getline('.') =~# '\s$') ? 'g_' : '$'
endfunction

nnoremap <expr> 0     <SID>mwim_beginning_expr()
vnoremap <expr> 0     <SID>mwim_beginning_expr()
onoremap <expr> 0     <SID>mwim_beginning_expr()
nnoremap <expr> <C-a> <SID>mwim_beginning_expr()
vnoremap <expr> <C-a> <SID>mwim_beginning_expr()

nnoremap <expr> $     <SID>mwim_end_expr()
vnoremap <expr> $     <SID>mwim_end_expr()
onoremap <expr> $     <SID>mwim_end_expr()
nnoremap <expr> <C-e> <SID>mwim_end_expr()
vnoremap <expr> <C-e> <SID>mwim_end_expr()

inoremap <expr> <C-a> <SID>mwim_beginning_i()
inoremap <C-e> <End>
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-h> <BS>
inoremap <C-d> <Del>
inoremap <M-h> <C-w>
inoremap <C-k> <C-o>d$
inoremap <C-_> <C-o>u
inoremap <M-_> <C-o><C-r>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-h> <BS>
cnoremap <C-d> <Del>
cnoremap <C-k> <C-\>estrpart(getcmdline(), 0, getcmdpos() - 1)<CR>

inoremap <silent> <C-o> <End><CR>

nnoremap <C-c>m :sort u<CR>
vnoremap <C-c>m :sort u<CR>
nnoremap <C-c>a :sort<CR>
vnoremap <C-c>a :sort<CR>
nnoremap <C-x><Space> <C-v>
nnoremap <C-x>j :

nnoremap <silent> <C-c>w :NERDTreeToggle<CR>
nnoremap <silent> <C-c><C-w> :NERDTreeToggle<CR>
nnoremap <silent> <C-c>o :NERDTreeFocus<CR>
nnoremap <silent> <C-c><C-o> :NERDTreeFocus<CR>

nnoremap <silent> <C-j> :bprev<CR>
nnoremap <silent> <C-k> :bnext<CR>
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
nnoremap j gj
nnoremap k gk
vnoremap < <gv
vnoremap > >gv

" =================================================================
" 8. RustRover風 Search Everywhere (見分けやすさ改善 & query>廃止版)
" =================================================================
let g:fzf_layout = { 'window': { 'width': 0.85, 'height': 0.65, 'border': 'rounded' } }

" fzf.vim デフォルトの ctrl-t (新規タブで開く) を alt-t に退避して競合を防止
let g:fzf_action = {
\ 'alt-t': 'tab split',
\ 'ctrl-x': 'split',
\ 'ctrl-v': 'vsplit'
\ }

let s:se_tabs = ['all', 'type', 'file', 'symbol', 'action', 'text']
let s:se_labels = {
\ 'all':    'すべて(開いているバッファ)',
\ 'type':   '型・タグ(Tags)',
\ 'file':   'ファイル名(Files)',
\ 'symbol': 'バッファ内行・シンボル(BLines)',
\ 'action': 'Vimコマンド(Commands)',
\ 'text':   '全文検索(Rg)'
\ }
let s:se_short_labels = {
\ 'all': 'すべて', 'type': '型', 'file': 'ファイル',
\ 'symbol': 'シンボル', 'action': 'アクション', 'text': 'テキスト'
\ }
let s:se_current_tab = 'file'
let s:se_tmpfile = fnamemodify(tempname(), ':h') . '/vim_se_next'

function! s:se_header(active) abort
  let l:parts = []
  for l:t in s:se_tabs
    if l:t ==# a:active
      call add(l:parts, '【★' . s:se_short_labels[l:t] . '】')
    else
      call add(l:parts, '  ' . s:se_short_labels[l:t] . '  ')
    endif
  endfor
  return join(l:parts, '') . '   [C-t: 次のタブへ切替]'
endfunction

function! s:search_everywhere_next() abort
  let l:idx = index(s:se_tabs, s:se_current_tab)
  let l:next_tab = s:se_tabs[(l:idx + 1) % len(s:se_tabs)]
  call s:search_everywhere_run(l:next_tab)
endfunction

function! s:se_check_switch(...) abort
  if filereadable(s:se_tmpfile)
    let l:next = trim(get(readfile(s:se_tmpfile), 0, 'file'))
    call delete(s:se_tmpfile)
    call s:search_everywhere_run(l:next)
  endif
endfunction

function! s:search_everywhere_run(tab) abort
  let s:se_current_tab = a:tab
  let l:idx = index(s:se_tabs, a:tab)
  let l:next_tab = s:se_tabs[(l:idx + 1) % len(s:se_tabs)]
  let l:hdr = s:se_header(a:tab)
  let l:title = ' Search Everywhere: ' . s:se_labels[a:tab] . ' '
  let l:prompt = '【' . s:se_short_labels[a:tab] . '】検索> '

  call delete(s:se_tmpfile)
  let l:bind = 'ctrl-t:execute-silent(echo ' . l:next_tab . ' > ' . s:se_tmpfile . ')+abort'

  " 枠タイトル・ヘッダー・入力プロンプトすべてに現在のモードを明示
  let $FZF_DEFAULT_OPTS = '--border=rounded --border-label="' . l:title . '" --header="' . l:hdr . '" --prompt="' . l:prompt . '" --bind="' . l:bind . '"'

  if a:tab ==# 'all'
    Buffers
  elseif a:tab ==# 'file'
    Files
  elseif a:tab ==# 'text'
    Rg
  elseif a:tab ==# 'action'
    Commands
  elseif a:tab ==# 'symbol'
    " query> で止まらないよう、現在バッファの行検索 (BLines) を即座にfzf表示
    BLines
  elseif a:tab ==# 'type'
    " query> を出さず、ctags または Rg で Rust/Go/Flutter(Dart)/Java/Python の定義行を直接fzf検索
    if !empty(tagfiles())
      Tags
    else
      call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case "(^\s*(pub\s+)?(struct|enum|trait|type|fn|func|mod)\s+|^\s*((public|private|protected|abstract|final|sealed|static|base|interface)\s+)*(class|def|interface|enum|record|mixin|extension|typedef)\s+)"', 1, fzf#vim#with_preview())
    endif
  endif
endfunction

augroup SearchEverywhereHook
  autocmd!
  autocmd FileType fzf tnoremap <buffer> <C-t> <C-t>
  if exists('##TermClose')
    autocmd BufLeave,WinLeave,TermClose * if filereadable(s:se_tmpfile) | call timer_start(15, function('s:se_check_switch')) | endif
  else
    autocmd BufLeave,WinLeave * if filereadable(s:se_tmpfile) | call timer_start(15, function('s:se_check_switch')) | endif
  endif
  autocmd FileType qf nnoremap <buffer> <silent> <C-t> :<C-u>cclose \| call <SID>search_everywhere_next()<CR>
augroup END

nnoremap <silent> <F2>         :<C-u>call <SID>search_everywhere_run(s:se_current_tab)<CR>
nnoremap <silent> <C-c><Space> :<C-u>call <SID>search_everywhere_run(s:se_current_tab)<CR>
nnoremap <silent> <C-p>        :<C-u>call <SID>search_everywhere_run('file')<CR>
nnoremap <silent> <C-g>        :<C-u>call <SID>search_everywhere_run('text')<CR>
nnoremap <silent> <C-x>b       :Buffers<CR>
nnoremap <silent> <C-x><C-r>   :History<CR>
nnoremap <silent> <C-c>s       :BLines<CR>
nnoremap <silent> <C-c>g       :Rg<CR>

" =================================================================
" 9. symbol-overlay 相当
" =================================================================
let s:overlay_matches = {}
let s:overlay_color_idx = 1

function! s:symbol_overlay_put() abort
  let l:word = expand('<cword>')
  if empty(l:word) | return | endif
  if has_key(s:overlay_matches, l:word)
    call matchdelete(s:overlay_matches[l:word])
    call remove(s:overlay_matches, l:word)
    echo 'Removed highlight: ' . l:word
  else
    let l:grp = 'SymbolOverlay' . s:overlay_color_idx
    let s:overlay_color_idx = (s:overlay_color_idx % 4) + 1
    let l:pat = '\<' . escape(l:word, '\') . '\>'
    let s:overlay_matches[l:word] = matchadd(l:grp, l:pat)
    let @/ = l:pat
    echo 'Highlighted: ' . l:word . ' (M-n / M-p でジャンプ)'
  endif
endfunction

nnoremap <silent> <M-i> :<C-u>call <SID>symbol_overlay_put()<CR>
nnoremap <silent> <M-n> *zz
nnoremap <silent> <M-p> #zz

" =================================================================
" 10. 自動補完 (asyncomplete + 事前計算による高速ソート)
" =================================================================
if has('patch-8.1.1880')
  set completeopt=menuone,noinsert,noselect,popup
  set completepopup=height:12,width:45,highlight:Pmenu,border:off
else
  set completeopt=menuone,noinsert,noselect
endif
set shortmess+=c
set pumheight=12

let g:asyncomplete_auto_popup = 1
let g:asyncomplete_min_chars = 1
let g:asyncomplete_popup_delay = 10
let g:lsp_text_edit_enabled = 1

augroup MyAsyncompleteSources
  autocmd!
  autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
      \ 'name': 'buffer', 'allowlist': ['*'], 'priority': 1,
      \ 'completor': function('asyncomplete#sources#buffer#completor'),
      \ }))
  autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
      \ 'name': 'file', 'allowlist': ['*'], 'priority': 10,
      \ 'completor': function('asyncomplete#sources#file#completor')
      \ }))
augroup END

let s:prescient_freq = {}
augroup PrescientTracker
  autocmd!
  autocmd CompleteDone * if !empty(v:completed_item) |
        \ let s:w = get(v:completed_item, 'word', '') |
        \ let s:prescient_freq[s:w] = get(s:prescient_freq, s:w, 0) + 1 |
        \ endif
augroup END

let s:kind_icons = {
\ 'function': '󰊕 fn', 'method': '󰊕 fn', 'variable': '󰀫 var',
\ 'field': '󰜢 fld', 'property': '󰜢 prop', 'class': '󰠱 cls',
\ 'struct': '󰙅 st', 'interface': ' if', 'module': '󰏗 mod',
\ 'constant': '󰏿 cst', 'keyword': '󰌋 kw', 'snippet': ' snp',
\ 'text': '󰉿 txt', 'file': '󰈙 file', 'folder': '󰉋 dir',
\ }

function! s:sort_rank(word, low_word, base, has_base) abort
  if a:word[0] ==# '_' | return 50 | endif
  let l:is_const = (a:word =~# '^[A-Z0-9_]\+$')
  if a:has_base && stridx(a:low_word, a:base) == 0
    return l:is_const ? 20 : 10
  endif
  return l:is_const ? 40 : 30
endfunction

function! s:compare_items(i1, i2) abort
  if a:i1._rank != a:i2._rank | return a:i1._rank - a:i2._rank | endif
  if a:i1._is_lsp != a:i2._is_lsp | return a:i2._is_lsp - a:i1._is_lsp | endif
  if a:i1._freq != a:i2._freq | return a:i2._freq - a:i1._freq | endif
  return a:i1._len - a:i2._len
endfunction

function! s:my_asyncomplete_preprocessor(options, matches) abort
  let l:items = []
  let l:seen = {}
  let l:base = tolower(a:options['base'])
  let l:has_base = !empty(l:base)
  let l:tokens = split(l:base, '\s\+')

  let l:source_names = sort(keys(a:matches), {a, b -> (b =~# 'lsp') - (a =~# 'lsp')})
  let g:asyncomplete_popup_delay = 30

  for l:source_name in l:source_names
    let l:match_info = a:matches[l:source_name]
    let l:is_lsp = (l:source_name =~# 'lsp') ? 1 : 0

    for l:item in l:match_info['items']
      if len(l:items) >= 512 | break | endif
      let l:word = get(l:item, 'word', '')
      if has_key(l:seen, l:word) | continue | endif

      let l:low_word = tolower(l:word)
      let l:matched = 1
      for l:tok in l:tokens
        if stridx(l:low_word, l:tok) < 0 | let l:matched = 0 | break | endif
      endfor
      if !l:matched | continue | endif

      let l:seen[l:word] = 1

      let l:abbr = get(l:item, 'abbr', l:word)
      if strlen(l:abbr) > 22 && l:abbr =~# '^[^(]\+(.+)$'
        let l:item['abbr'] = substitute(l:abbr, '(\zs.*\ze)$', '…', '')
      endif

      let l:kind = tolower(trim(get(l:item, 'menu', '')))
      if has_key(s:kind_icons, l:kind)
        let l:item['menu'] = s:kind_icons[l:kind]
      elseif l:source_name ==# 'buffer'
        let l:item['menu'] = '[buf]'
      endif

      let l:item['_rank'] = s:sort_rank(l:word, l:low_word, l:base, l:has_base)
      let l:item['_is_lsp'] = l:is_lsp
      let l:item['_freq'] = get(s:prescient_freq, l:word, 0)
      let l:item['_len'] = strlen(l:word)
      call add(l:items, l:item)
    endfor
  endfor

  call sort(l:items, function('s:compare_items'))
  call asyncomplete#preprocess_complete(a:options, l:items)
endfunction

let g:asyncomplete_preprocessor = [function('s:my_asyncomplete_preprocessor')]

function! s:on_tab() abort
  if pumvisible()
    return complete_info(['selected']).selected == -1 ? "\<C-n>\<C-y>" : "\<C-y>"
  elseif vsnip#available(1)
    return "\<Plug>(vsnip-expand-or-jump)"
  else
    return "\<Tab>"
  endif
endfunction

function! s:on_s_tab() abort
  if pumvisible()
    return "\<C-p>"
  elseif vsnip#jumpable(-1)
    return "\<Plug>(vsnip-jump-prev)"
  else
    return "\<C-h>"
  endif
endfunction

inoremap <silent><expr> <Tab>   <SID>on_tab()
snoremap <silent><expr> <Tab>   vsnip#jumpable(1)  ? "\<Plug>(vsnip-jump-next)" : "\<Tab>"
inoremap <silent><expr> <S-Tab> <SID>on_s_tab()
snoremap <silent><expr> <S-Tab> vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "\<S-Tab>"
inoremap <silent><expr> <CR>    pumvisible() ? (complete_info(['selected']).selected != -1 ? "\<C-y>" : "\<C-e>\<CR>") : lexima#expand('<LT>CR>', 'i')
inoremap <silent><expr> <C-n>   pumvisible() ? "\<Down>" : "\<C-n>"
inoremap <silent><expr> <C-p>   pumvisible() ? "\<Up>" : "\<C-p>"
inoremap <silent> <C-/> <C-x><C-o>

" =================================================================
" 11. LSP & スマートジャンプ (Rust / Go / Flutter(Dart) / Java / C++ / Python)
" =================================================================
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeRespectWildIgnore = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeWinSize = 30

let g:rustfmt_autosave = 1
let g:dart_style_guide = 2
let g:dart_format_on_save = 0 " 保存時整形はLspDocumentFormatSyncに統一

" vim-flutter 連携設定 & キーバインド
let g:flutter_command = executable('/snap/bin/flutter') ? '/snap/bin/flutter' : 'flutter'
let g:flutter_show_log_on_run = 'split'
let g:flutter_autoscroll = 1
nnoremap <silent> <C-c>fr :<C-u>FlutterRun<CR>
nnoremap <silent> <C-c>fh :<C-u>FlutterHotReload<CR>
nnoremap <silent> <C-c>fR :<C-u>FlutterHotRestart<CR>
nnoremap <silent> <C-c>fq :<C-u>FlutterQuit<CR>
nnoremap <silent> <C-c>fd :<C-u>FlutterDevices<CR>
inoremap <silent> <C-@> <C-x><C-o>

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 100
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_signs_enabled = 1
let g:lsp_highlights_enabled = 1
let g:lsp_inlay_hints_enabled = 1
let g:lsp_signs_error = {'text': '✖'}
let g:lsp_signs_warning = {'text': '⚠'}
let g:lsp_signs_information = {'text': 'ℹ'}
let g:lsp_signs_hint = {'text': 'ℹ'}

let g:lsp_signature_help_enabled = 0
let g:lsp_preview_float = 1
let g:lsp_preview_keep_focus = 0
let g:lsp_float_max_width = 50
let g:lsp_float_max_height = 14

" vim-lsp-settings による Dart LSP の重複起動を無効化
let g:lsp_settings_filetype_dart = []

let g:lsp_settings = {
\   'rust-analyzer': {
\     'workspace_config': {
\       'rust-analyzer': {
\         'checkOnSave': {'command': 'clippy'},
\         'completion': {'autoimport': {'enable': v:true}},
\       }
\     }
\   },
\   'gopls': {
\     'workspace_config': {
\       'gopls': {
\         'staticcheck': v:true,
\         'completeUnimported': v:true,
\         'usePlaceholders': v:true,
\         'analyses': {'unusedparams': v:true, 'shadow': v:true},
\         'hints': {
\           'assignVariableTypes': v:true,
\           'compositeLiteralFields': v:true,
\           'constantValues': v:true,
\           'functionTypeParameters': v:true,
\           'parameterNames': v:true,
\           'rangeVariableTypes': v:true,
\         },
\       }
\     }
\   },
\   'analysis-server-dart-snapshot': {
\     'workspace_config': {
\       'dart': {
\         'sdkPath': '/home/kotaro/snap/flutter/common/flutter/bin/cache/dart-sdk',
\         'flutterSdkPath': '/home/kotaro/snap/flutter/common/flutter',
\         'completeFunctionCalls': v:true,
\         'showTodos': v:true,
\         'enableSnippets': v:true,
\         'updateImportsOnRename': v:true,
\         'maxCompletionItems': 256,
\       }
\     }
\   },
\   'eclipse-jdt-ls': {
\     'workspace_config': {
\       'java': {
\         'signatureHelp': {'enabled': v:true},
\         'completion': {'favoriteStaticMembers': ['org.junit.jupiter.api.Assertions.*', 'java.util.Objects.requireNonNull']},
\         'inlayHints': {'parameterNames': {'enabled': 'all'}},
\       }
\     }
\   },
\ }

augroup MyLspSetup
  autocmd!
  if executable('pyright-langserver')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'pyright-langserver',
      \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
      \ 'allowlist': ['python'],
      \ 'workspace_config': {'python': {'analysis': {'autoSearchPaths': v:true, 'useLibraryCodeForTypes': v:true, 'diagnosticMode': 'openFilesOnly'}}}
      \ })
  elseif executable('pylsp')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'pylsp', 'cmd': {server_info->['pylsp']}, 'allowlist': ['python'],
      \ })
  endif

  if executable('rust-analyzer')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'rust-analyzer', 'cmd': {server_info->['rust-analyzer']}, 'allowlist': ['rust'],
      \ })
  endif

  if executable('clangd')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'clangd', 'cmd': {server_info->['clangd', '--background-index', '--clang-tidy']},
      \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
      \ })
  endif

  if executable('taplo')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'taplo',
      \ 'cmd': {server_info->['taplo', 'lsp', 'stdio']},
      \ 'allowlist': ['toml'],
      \ })
  endif

  if executable('gopls')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'gopls',
      \ 'cmd': {server_info->['gopls']},
      \ 'allowlist': ['go', 'gomod', 'gowork', 'gotmpl'],
      \ 'workspace_config': g:lsp_settings['gopls']['workspace_config'],
      \ })
  endif

  let s:dart_lsp_bin = filereadable('/home/kotaro/snap/flutter/common/flutter/bin/cache/dart-sdk/bin/dart')
        \ ? '/home/kotaro/snap/flutter/common/flutter/bin/cache/dart-sdk/bin/dart'
        \ : (executable('/snap/bin/dart') ? '/snap/bin/dart' : 'dart')
  if executable(s:dart_lsp_bin)
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'dart-language-server',
      \ 'cmd': {server_info->[s:dart_lsp_bin, 'language-server', '--protocol=lsp']},
      \ 'allowlist': ['dart'],
      \ 'initialization_options': {
      \   'onlyAnalyzeProjectsWithOpenFiles': v:false,
      \   'suggestFromUnimportedLibraries': v:true,
      \   'closingLabels': v:false,
      \   'flutterOutline': v:false,
      \ },
      \ 'workspace_config': g:lsp_settings['analysis-server-dart-snapshot']['workspace_config'],
      \ })
  endif

  if executable('jdtls')
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'jdtls',
      \ 'cmd': {server_info->[
      \   'jdtls',
      \   '-data', expand('~/.cache/jdtls/workspace/') . fnamemodify(getcwd(), ':t')
      \ ]},
      \ 'allowlist': ['java'],
      \ 'workspace_config': g:lsp_settings['eclipse-jdt-ls']['workspace_config'],
      \ })
  endif
augroup END

function! s:smart_jump_fallback() abort
  let l:orig_buf = bufnr('%')
  let l:orig_pos = getpos('.')
  let l:file = findfile(expand('<cfile>'))
  if !empty(l:file) && filereadable(l:file)
    execute 'edit ' . fnameescape(l:file)
    return
  endif
  try
    execute "normal! g\<C-]>"
  catch
    try
      execute "normal! [\<C-i>"
    catch
      normal! gd
    endtry
  endtry
  if bufnr('%') == l:orig_buf && getpos('.') == l:orig_pos
    let l:word = expand('<cword>')
    if !empty(l:word)
      silent! execute 'vimgrep /\<' . escape(l:word, '/\') . '\>/j %'
      copen
    endif
  endif
endfunction

function! s:lsp_smart_xref_dwim() abort
  let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_definition_provider(v:val)')
  if empty(l:servers)
    call s:smart_jump_fallback()
    return
  endif
  let l:cur_uri = lsp#utils#get_buffer_uri()
  let l:cur_line = line('.') - 1
  call lsp#send_request(l:servers[0], {
  \ 'method': 'textDocument/definition',
  \ 'params': {'textDocument': lsp#get_text_document_identifier(), 'position': lsp#get_position()},
  \ 'on_notification': function('s:handle_dwim_response', [l:cur_uri, l:cur_line]),
  \ })
endfunction

function! s:handle_dwim_response(cur_uri, cur_line, data) abort
  if lsp#client#is_error(a:data['response']) || !has_key(a:data['response'], 'result') || empty(a:data['response']['result'])
    LspReferences
    return
  endif
  let l:res = a:data['response']['result']
  let l:loc = type(l:res) == v:t_list ? l:res[0] : l:res
  let l:target_uri = get(l:loc, 'uri', get(l:loc, 'targetUri', ''))
  let l:range = get(l:loc, 'range', get(l:loc, 'targetSelectionRange', {}))
  let l:target_line = get(get(l:range, 'start', {}), 'line', -1)

  if tolower(l:target_uri) ==# tolower(a:cur_uri) && l:target_line == a:cur_line
    echo '★すでに定義元です → 参照一覧 (References) を表示します'
    LspReferences
  else
    LspDefinition
  endif
endfunction

function! s:lsp_toggle_help() abort
  for l:w in range(1, winnr('$'))
    if getwinvar(l:w, '&previewwindow') || bufname(winbufnr(l:w)) =~# 'lsp'
      pclose
      return
    endif
  endfor
  LspHover
endfunction

function! s:configure_lsp() abort
  setlocal omnifunc=lsp#complete
  nnoremap <buffer> <silent> <C-]> :<C-u>call <SID>lsp_smart_xref_dwim()<CR>
  nnoremap <buffer> <silent> <M-.> :<C-u>call <SID>lsp_smart_xref_dwim()<CR>
  inoremap <buffer> <silent> <M-.> <Esc>:<C-u>call <SID>lsp_smart_xref_dwim()<CR>
  nnoremap <buffer> gd :<C-u>LspDefinition<CR>
  nnoremap <buffer> gD :<C-u>LspReferences<CR>
  nnoremap <buffer> <C-c>f :<C-u>LspReferences<CR>
  nnoremap <buffer> <silent> <C-q> :<C-u>call <SID>lsp_toggle_help()<CR>
  nnoremap <buffer> <C-c>d :<C-u>LspHover<CR>
  nnoremap <buffer> K :<C-u>LspHover<CR>
  nnoremap <buffer> <C-c>r :<C-u>LspRename<CR>
  nnoremap <buffer> <C-c><C-a> :<C-u>LspCodeAction<CR>
  nnoremap <buffer> <C-c>i :<C-u>LspInlayHintsToggle<CR>
  nnoremap <buffer> <F8> :<C-u>LspNextDiagnostic<CR>
  nnoremap <buffer> <S-F8> :<C-u>LspPreviousDiagnostic<CR>
  nnoremap <buffer> [g :<C-u>LspPreviousDiagnostic<CR>
  nnoremap <buffer> ]g :<C-u>LspNextDiagnostic<CR>
  nnoremap <buffer> <C-c>e :<C-u>LspDocumentDiagnostics<CR>
  nnoremap <buffer> gs :<C-u>LspDocumentSymbol<CR>
  nnoremap <buffer> gS :<C-u>LspWorkspaceSymbol<CR>
  nnoremap <buffer> gQ :<C-u>LspDocumentFormat<CR>
  vnoremap <buffer> gQ :LspDocumentRangeFormat<CR>
endfunction

augroup MyLsp
  autocmd!
  autocmd User lsp_buffer_enabled call s:configure_lsp()
augroup END

nnoremap <silent> <C-]> :<C-u>call <SID>smart_jump_fallback()<CR>
nnoremap <silent> <M-.> :<C-u>call <SID>smart_jump_fallback()<CR>
nnoremap <silent> <M-,> <C-o>
inoremap <silent> <M-,> <Esc><C-o>

" =================================================================
" 12. 自動処理 & Quickfix・辞書ウィンドウ対応 (Windowsのドライブレター対応)
" =================================================================
augroup MyVimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC
  autocmd QuickfixCmdPost vimgrep,grep copen
  autocmd FileType qf,help,ref-*,lsp-hover nnoremap <buffer> <silent> q :<C-u>close<CR>
  autocmd BufEnter ==Translate==\ Excite nnoremap <buffer> <silent> q :<C-u>close<CR>
  " 新規ファイル作成時の定型文（スケルトン）自動挿入
  autocmd BufNewFile *.py call setline(1, ['#!/usr/bin/env python3', '# -*- coding: utf-8 -*-', '', '']) | normal! G
  autocmd BufNewFile *.sh call setline(1, ['#!/usr/bin/env bash', 'set -euo pipefail', '', '']) | normal! G

  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  autocmd BufWritePre * if &ft !=# 'markdown' | :%s/\s\+$//e | endif
  autocmd BufWritePre *.rs,*.dart,*.go,*.java silent! LspDocumentFormatSync
augroup END

augroup MyXML
  autocmd!
  autocmd FileType xml,html inoremap <buffer> </ </<C-x><C-o>
augroup END

let g:ref_source_webdict_sites = {
\   'je': { 'url': 'https://ejje.weblio.jp/content/%s' },
\   'ej': { 'url': '%s' },
\ }
let g:ref_source_webdict_sites.default = 'ej'
function! g:ref_source_webdict_sites.je.filter(output)
  return join(split(a:output, "\n")[15 :], "\n")
endfunction
function! g:ref_source_webdict_sites.ej.filter(output)
  return join(split(a:output, "\n")[15 :], "\n")
endfunction

function! s:qf_to_fzf() abort
  let l:qf = getqflist()
  if empty(l:qf) | return | endif
  cclose
  let l:lines = map(l:qf, 'bufname(v:val.bufnr) . ":" . v:val.lnum . ":" . v:val.col . ": " . trim(v:val.text)')
  call fzf#run(fzf#wrap({
  \ 'source': l:lines,
  \ 'sink': function('s:qf_fzf_sink'),
  \ 'options': ['--prompt', 'LSP (fzf)> ', '--delimiter', ':', '--preview-window', 'none']
  \ }))
endfunction

function! s:qf_fzf_sink(line) abort
  let l:m = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):')
  if !empty(l:m)
    execute 'edit ' . fnameescape(l:m[1])
    call cursor(str2nr(l:m[2]), str2nr(l:m[3]))
    normal! zz
  endif
endfunction

augroup LspQfToFzf
  autocmd!
  autocmd QuickFixCmdPost Lsp* call timer_start(10, {-> s:qf_to_fzf()})
augroup END

nnoremap <silent> <C-Up>    :resize +2<CR>
nnoremap <silent> <C-Down>  :resize -2<CR>
nnoremap <silent> <C-Right> :vertical resize +2<CR>
nnoremap <silent> <C-Left>  :vertical resize -2<CR>

" =================================================================
" 13. 翻訳設定 (ローカル辞書 + オンライン優先 + Local AIフォールバック版)
" =================================================================
let s:translate_popup_id = 0

function! s:url_encode(str) abort
  return substitute(iconv(a:str, &encoding, 'utf-8'), '[^A-Za-z0-9_.~-]', '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
endfunction

function! s:run_cmd(cmd_list) abort
  try
    return system(a:cmd_list)
  catch /E730/
    return system(join(map(copy(a:cmd_list), 'shellescape(v:val)'), ' '))
  endtry
endfunction

function! s:clean_code_comment(text) abort
  let l:lines = split(a:text, "\n")
  call map(l:lines, 'substitute(v:val, ''^\s*\(///\?!\?\|/\*\+\|\*\+/\|/\+\|#\+\|"\+\)\s*'', "", "")')
  return trim(join(l:lines, ' '))
endfunction

function! s:word_stem_candidates(word) abort
  let l:w = tolower(a:word)
  let l:cands = [l:w]
  if l:w =~# 'ied$'
    call add(l:cands, substitute(l:w, 'ied$', 'y', ''))
  elseif l:w =~# 'ed$'
    let l:base = substitute(l:w, 'ed$', '', '')
    call add(l:cands, l:base)
    call add(l:cands, l:base . 'e')
    if l:base =~# '\([a-z]\)\1$'
      call add(l:cands, substitute(l:base, '\([a-z]\)\1$', '\1', ''))
    endif
  elseif l:w =~# 'ing$'
    let l:base = substitute(l:w, 'ing$', '', '')
    call add(l:cands, l:base)
    call add(l:cands, l:base . 'e')
    if l:base =~# '\([a-z]\)\1$'
      call add(l:cands, substitute(l:base, '\([a-z]\)\1$', '\1', ''))
    endif
  elseif l:w =~# 'es$'
    call add(l:cands, substitute(l:w, 'es$', '', ''))
    call add(l:cands, substitute(l:w, 'es$', 'e', ''))
  elseif l:w =~# 's$'
    call add(l:cands, substitute(l:w, 's$', '', ''))
  endif
  return l:cands
endfunction

function! s:local_dict_lookup(text, sl) abort
  if a:sl ==# 'en' && a:text =~# '^[A-Za-z-]\+$'
    let l:dict = expand('~/.vim/plugged/ref-dicts-en/dict/gene/gene.txt')
    if filereadable(l:dict) && executable('grep')
      for l:cand in s:word_stem_candidates(a:text)
        let l:out = s:run_cmd(['grep', '-i', '-A', '1', '^' . l:cand . '$', l:dict])
        let l:lines = split(l:out, "\n")
        if len(l:lines) >= 2
          return printf('[Local Dict (%s)] %s', l:lines[0], l:lines[1])
        endif
      endfor
    endif
  endif
  return ''
endfunction

function! s:local_ai_translate(text, sl, tl) abort
  let l:argos = executable('argos-translate') ? 'argos-translate' : expand('~/.local/bin/argos-translate')
  if executable(l:argos)
    let l:raw = s:run_cmd([l:argos, '--from-lang', a:sl, '--to-lang', a:tl, a:text])
    if v:shell_error == 0 && !empty(l:raw)
      let l:lines = filter(split(l:raw, "\n"), 'v:val !~# ''^\d\{4}-\d\{2}-\d\{2}\s\+\d\{2}:\d\{2}:\d\{2}\s\+\(WARNING\|INFO\|ERROR\):'' && v:val !~# ''^which has been added''')
      return trim(join(l:lines, "\n"))
    endif
  endif
  return ''
endfunction

function! s:curl_get(url) abort
  let l:ua = 'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0'
  return s:run_cmd(['curl', '-4', '-sS', '-L', '--max-time', '4', '-A', l:ua, a:url])
endfunction

function! s:parse_translate_json(raw) abort
  if empty(a:raw) || a:raw =~# '^\s*<' | return '' | endif
  try
    let l:json = json_decode(a:raw)
  catch
    try
      let l:json = json_decode(iconv(a:raw, 'cp932', 'utf-8'))
    catch
      return ''
    endtry
  endtry

  let l:parts = []
  if type(l:json) == v:t_dict && has_key(l:json, 'sentences')
    for l:s in l:json.sentences
      if type(l:s) == v:t_dict && has_key(l:s, 'trans') && type(l:s.trans) == v:t_string
        call add(l:parts, l:s.trans)
      endif
    endfor
  elseif type(l:json) == v:t_dict && has_key(l:json, 'responseData') && type(l:json.responseData) == v:t_dict
    let l:t = get(l:json.responseData, 'translatedText', '')
    if type(l:t) == v:t_string && !empty(l:t) | call add(l:parts, l:t) | endif
  elseif type(l:json) == v:t_list && !empty(l:json)
    if type(l:json[0]) == v:t_string
      call add(l:parts, l:json[0])
    elseif type(l:json[0]) == v:t_list
      for l:item in l:json[0]
        if type(l:item) == v:t_string
          call add(l:parts, l:item) | break
        elseif type(l:item) == v:t_list && !empty(l:item) && type(l:item[0]) == v:t_string
          call add(l:parts, l:item[0])
        endif
      endfor
    endif
  endif
  return join(l:parts, '')
endfunction

function! s:start_translate(text, is_replace) abort
  let l:clean_text = a:is_replace ? trim(a:text) : s:clean_code_comment(a:text)
  if empty(l:clean_text) | echo '翻訳対象テキストが空です' | return | endif

  let l:sl = (l:clean_text =~# '[^\x01-\x7E]') ? 'ja' : 'en'
  let l:tl = (l:sl ==# 'ja') ? 'en' : 'ja'

  redraw | echo printf('翻訳中 (%s -> %s)...', l:sl, l:tl)

  let l:dict_res = (!a:is_replace) ? s:local_dict_lookup(l:clean_text, l:sl) : ''

  let l:online_res = ''
  let l:engine = 'Online'
  if executable('curl')
    let l:q = s:url_encode(l:clean_text)
    let l:url1 = printf('https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=%s&tl=%s&q=%s', l:sl, l:tl, l:q)
    let l:online_res = s:parse_translate_json(s:curl_get(l:url1))
    if empty(l:online_res)
      let l:url2 = printf('https://api.mymemory.translated.net/get?q=%s&langpair=%s|%s', l:q, l:sl, l:tl)
      let l:online_res = s:parse_translate_json(s:curl_get(l:url2))
    endif
  endif

  let l:main_res = l:online_res
  if empty(l:main_res) && empty(l:dict_res)
    let l:main_res = s:local_ai_translate(l:clean_text, l:sl, l:tl)
    if !empty(l:main_res)
      let l:engine = 'Local AI'
    endif
  elseif empty(l:main_res) && !empty(l:dict_res)
    let l:engine = 'Local Dict'
  endif

  let l:res = !empty(l:main_res) && !empty(l:dict_res) ? (l:main_res . "\n" . l:dict_res) : (!empty(l:main_res) ? l:main_res : l:dict_res)

  if empty(l:res)
    echohl ErrorMsg | redraw | echo '翻訳失敗: ローカル・オンライン共に結果を取得できませんでした' | echohl None
    return
  endif

  if a:is_replace
    let l:save_reg = getreg('z')
    let l:save_type = getregtype('z')
    call setreg('z', l:res, 'v')
    normal! gv
    if mode() =~# "^[sS\x13]" | execute "normal! \<C-g>" | endif
    normal! "zp
    call setreg('z', l:save_reg, l:save_type)
    redraw | echo printf('★翻訳置換完了 (%s -> %s)', l:sl, l:tl)
    return
  endif

  let l:lines = split(l:res, "\n")
  if exists('*popup_atcursor')
    if s:translate_popup_id != 0 | call popup_close(s:translate_popup_id) | endif
    redraw | echo ''
    let s:translate_popup_id = popup_atcursor(l:lines, {
          \ 'title': printf(' 翻訳 (%s -> %s [%s]) ', l:sl, l:tl, l:engine),
          \ 'padding': [0, 1, 0, 1],
          \ 'border': [],
          \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
          \ 'highlight': 'Pmenu',
          \ 'borderhighlight': ['VertSplit'],
          \ 'moved': 'any',
          \ 'maxwidth': 65,
          \ 'wrap': 1,
          \ })
  else
    redraw | echo printf('[%s->%s] %s', l:sl, l:tl, l:res)
  endif
endfunction

function! s:get_visual_text() abort
  let l:save_reg = getreg('z')
  let l:save_type = getregtype('z')
  normal! gv
  if mode() =~# "^[sS\x13]" | execute "normal! \<C-g>" | endif
  normal! "zy
  let l:text = getreg('z')
  call setreg('z', l:save_reg, l:save_type)
  return l:text
endfunction

function! s:smart_translate(mode) range abort
  let l:text = (a:mode ==# 'v') ? s:get_visual_text() : getline('.')
  call s:start_translate(l:text, 0)
endfunction

function! s:translate_cword() abort
  let l:word = expand('<cword>')
  if empty(l:word) | return | endif
  let l:phrase = substitute(l:word, '_', ' ', 'g')
  let l:phrase = substitute(l:phrase, '\(\l\)\(\u\)', '\1 \2', 'g')
  call s:start_translate(l:phrase, 0)
endfunction

function! s:translate_replace() range abort
  let l:text = s:get_visual_text()
  call s:start_translate(l:text, 1)
endfunction

command! TranslateWord call s:translate_cword()
command! TranslateLine call s:smart_translate('n')

nnoremap <silent> <C-c>t :<C-u>call <SID>translate_cword()<CR>
xnoremap <silent> <C-c>t :<C-u>call <SID>smart_translate('v')<CR>
snoremap <silent> <C-c>t <C-g>:<C-u>call <SID>smart_translate('v')<CR>
nnoremap <silent> <C-c>T :<C-u>call <SID>smart_translate('n')<CR>
xnoremap <silent> <C-c>r :<C-u>call <SID>translate_replace()<CR>
snoremap <silent> <C-c>r <C-g>:<C-u>call <SID>translate_replace()<CR>

nnoremap <silent> <leader>cu :call crates#update()<CR>

" =================================================================
" 14. LSP パンくずリスト & Context (シンボルキャッシュによる軽量化版)
" =================================================================
let s:breadcrumb_text = ''
let s:breadcrumb_popup_id = 0
let s:breadcrumb_enable_popup = 0 " 0 にすると上部ポップアップを無効化（ステータスラインのみ）

function! LspBreadcrumbs() abort
  return s:breadcrumb_text
endfunction

function! s:pos_in_range(line, col, range) abort
  if empty(a:range) | return 0 | endif
  let l:s = a:range['start']
  let l:e = a:range['end']
  if a:line < l:s['line'] || a:line > l:e['line'] | return 0 | endif
  if a:line == l:s['line'] && a:col < l:s['character'] | return 0 | endif
  if a:line == l:e['line'] && a:col > l:e['character'] | return 0 | endif
  return 1
endfunction

function! s:extract_breadcrumbs(symbols, line, col) abort
  let l:chain = []
  for l:sym in a:symbols
    if has_key(l:sym, 'range') && s:pos_in_range(a:line, a:col, l:sym['range'])
      call add(l:chain, l:sym['name'])
      if has_key(l:sym, 'children') && type(l:sym['children']) == v:t_list
        call extend(l:chain, s:extract_breadcrumbs(l:sym['children'], a:line, a:col))
      endif
      break
    endif
  endfor
  return l:chain
endfunction

function! s:render_breadcrumb_popup() abort
  if !exists('*popup_create') | return | endif
  if !s:breadcrumb_enable_popup || empty(s:breadcrumb_text) || get(s:, 'clean_copy_mode', 0)
    if s:breadcrumb_popup_id != 0
      call popup_close(s:breadcrumb_popup_id)
      let s:breadcrumb_popup_id = 0
    endif
    return
  endif

  let l:winpos = win_screenpos(winnr())
  let l:row = l:winpos[0]
  let l:col = l:winpos[1] + (&number ? &numberwidth : 0) + (&signcolumn ==# 'yes' ? 2 : 0)
  let l:text = ' 󰙅 ' . s:breadcrumb_text . ' '

  if s:breadcrumb_popup_id == 0
    let s:breadcrumb_popup_id = popup_create(l:text, {
          \ 'line': l:row,
          \ 'col': l:col,
          \ 'pos': 'topleft',
          \ 'wrap': 0,
          \ 'highlight': 'StatusLine',
          \ 'mousemoved': 'any',
          \ 'zindex': 40,
          \ })
  else
    call popup_move(s:breadcrumb_popup_id, {'line': l:row, 'col': l:col})
    call popup_settext(s:breadcrumb_popup_id, l:text)
  endif
endfunction

function! s:apply_breadcrumb_from_cache(line, col) abort
  let l:prev = s:breadcrumb_text
  let l:symbols = get(b:, 'lsp_breadcrumb_symbols', [])
  if empty(l:symbols) || type(l:symbols) != v:t_list || !has_key(l:symbols[0], 'range')
    let s:breadcrumb_text = ''
  else
    let s:breadcrumb_text = join(s:extract_breadcrumbs(l:symbols, a:line, a:col), ' > ')
  endif
  call s:render_breadcrumb_popup()
  if s:breadcrumb_text !=# l:prev
    redrawstatus
  endif
endfunction

function! s:handle_breadcrumb_symbols(buf, tick, line, col, data) abort
  if lsp#client#is_error(a:data['response']) || !has_key(a:data['response'], 'result')
    return
  endif
  let l:res = a:data['response']['result']
  call setbufvar(a:buf, 'lsp_breadcrumb_tick', a:tick)
  call setbufvar(a:buf, 'lsp_breadcrumb_symbols', type(l:res) == v:t_list ? l:res : [])
  if bufnr('%') == a:buf
    call s:apply_breadcrumb_from_cache(line('.') - 1, col('.') - 1)
  endif
endfunction

function! s:update_breadcrumbs() abort
  if line('$') > 4096 || expand('%:p') =~# '/flutter/packages/\|/\.pub-cache/\|/dart-sdk/'
    return
  endif
  if &buftype !=# ''
    if !empty(s:breadcrumb_text)
      let s:breadcrumb_text = ''
      call s:render_breadcrumb_popup()
      redrawstatus
    endif
    return
  endif

  let l:line = line('.') - 1
  let l:col = col('.') - 1
  let l:tick = b:changedtick

  " バッファ内容が未変更でキャッシュがあればLSP通信を省略して即座に更新
  if get(b:, 'lsp_breadcrumb_tick', -1) == l:tick
    call s:apply_breadcrumb_from_cache(l:line, l:col)
    return
  endif

  let l:servers = filter(lsp#get_allowed_servers(), 'lsp#capabilities#has_document_symbol_provider(v:val)')
  if empty(l:servers)
    if !empty(s:breadcrumb_text)
      let s:breadcrumb_text = ''
      call s:render_breadcrumb_popup()
      redrawstatus
    endif
    return
  endif

call lsp#send_request(l:servers[0], {
        \ 'method': 'textDocument/documentSymbol',
        \ 'params': {'textDocument': lsp#get_text_document_identifier()},
        \ 'on_notification': function('s:handle_breadcrumb_symbols', [bufnr('%'), l:tick, l:line, l:col]),
        \ })
endfunction

augroup MyLspBreadcrumbs
  autocmd!
  autocmd CursorHold,BufEnter,WinEnter * call s:update_breadcrumbs()
  autocmd WinLeave,BufLeave * if s:breadcrumb_popup_id != 0 | call popup_close(s:breadcrumb_popup_id) | let s:breadcrumb_popup_id = 0 | endif
augroup END

augroup ContextVisualFix
  autocmd!
  autocmd ModeChanged *:[vV\x16]* silent! ContextDisable
  autocmd ModeChanged [vV\x16]*:* silent! ContextEnable
augroup END

let g:context_autocmd = 'BufEnter,CursorHold,BufAdd,WinScrolled'
let g:context_max_scan_lines = 512
let g:context_max_height = 5
let g:context_max_per_indent = 2
let g:context_filetype_blacklist = ['nerdtree', 'tagbar', 'qf', 'help']

" 巨大ファイルやFlutter/Dart SDKを開く前に装飾プラグインと診断を停止
augroup FastLargeOrSdkFile
  autocmd!
  autocmd BufReadPre * if getfsize(expand('<afile>')) > 100000 || expand('<afile>:p') =~# '/flutter/packages/\|/\.pub-cache/\|/dart-sdk/' |
        \ let b:gitgutter_enabled = 0 |
        \ let b:indentLine_enabled = 0 |
        \ let b:context_enabled = 0 |
        \ let b:lsp_diagnostics_enabled = 0 |
        \ setlocal nocursorline noswapfile noundofile nobuflisted readonly nomodifiable synmaxcol=120 |
        \ endif
  autocmd BufWinEnter,BufEnter * if get(b:, 'indentLine_enabled', 1) == 0 |
        \ silent! IndentLinesDisable |
        \ silent! ContextDisable |
        \ endif
augroup END
