" Place this file at the place: ~/.vimrc
" This vim config need to set up Vundle:
" $ git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim



syntax enable " 顯示語法高亮
syntax on " 開啓文件類型語法檢測
set shell=/bin/bash " 設置默認 shell
set nocompatible " 關閉 vi 兼容模式
set number " 顯示行號
set cursorline " 突出顯示當前行
set ruler " 打開狀態欄標尺
set shiftwidth=4 " 設定 << 和 >> 命令移動時的寬度爲 4
set softtabstop=4 " 使得按退格鍵時可以一次刪掉 4 個空格
set tabstop=4 " 設定 tab 長度爲 4
set nobackup " 覆蓋文件時不備份
set autochdir " 自動切換當前目錄爲當前文件所在的目錄
set backupcopy=yes " 設置備份時的行爲爲覆蓋
set ignorecase smartcase " 搜索時忽略大小寫，但在有一個或以上大寫字母時仍保持對大小寫敏感
set nowrapscan " 禁止在搜索到文件兩端時重新搜索
set incsearch " 輸入搜索內容時就顯示搜索結果
set hlsearch " 搜索時高亮顯示被找到的文本
set noerrorbells " 關閉錯誤信息響鈴
set novisualbell " 關閉使用可視響鈴代替呼叫
set showmatch " 插入括號時，短暫地跳轉到匹配的對應括號
set matchtime=2 " 短暫跳轉到匹配括號的時間
set magic " 設置魔術
set hidden " 允許在有未保存的修改時切換緩衝區，此時的修改由 vim 負責保存
set smartindent " 開啓新行時使用智能自動縮進
set backspace=indent,eol,start " 不設定在插入狀態無法用退格鍵和 Delete 鍵刪除回車符
set cmdheight=1 " 設定命令行的行數爲 1
set laststatus=2 " 顯示狀態欄 (默認值爲 1, 無法顯示狀態欄)
set wildmenu " 使用命令行補全
set mouse=i " 在插入模式下支持鼠標點擊定位，值爲 a 時爲任意模式支持鼠標定位
set completeopt=longest,menu " 支持自動補全
set scrolloff=4 " 光標移到buffer頂部或底部時保持4行距離(文本到達頂端或末尾時除外)
set iskeyword+=_,$,@,%,#,- " 帶有這些字符的內容不被自動換行分割
set autoindent " 使用autoindent縮進結構，每一行的縮進與上一行類似
set cindent " 使用C語言風格的cindent縮進結構
set expandtab " 用空格代替製表符
set smarttab " 在行和段開始處使用製表符
set confirm " 處理只讀或未保存文件時，彈出確認
set showcmd " 在命令欄右側顯示輸入的命令
set linebreak " 使用整詞換行
set noswapfile " 打開文件時不生成以'swp'後綴的臨時交換文件
set lbr " 不在單詞中間拆行
set list " 顯示特殊符號
set cursorcolumn " 打開縱向高亮對齊
" set t_vb= " 置空錯誤鈴聲的終端代碼
" set guioptions-=T " 隱藏工具欄
" set guioptions-=m " 隱藏菜單欄



" --- 設置GUI模式下的額外配置 ---
if has("gui_running")
    set lines=50 columns=130 " 設置GUI模式下的寬高
endif



" --- 設置快捷鍵 ---
map <S-Left> :bp<CR> " shift + 左方向鍵 切換到前一個文件buffer
map <S-Right> :bn<CR> " shift + 右方向鍵 切換到後一個文件buffer



" --- 設置文件讀取 ---
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.MD set filetype=markdown " 將*.md/MD格式的文件作爲markdown文件進行語法解析
autocmd BufNewFile,BufReadPost *.m set filetype=objc " 將*.m格式的文件作爲Objective-C源碼進行解析
autocmd BufNewFile,BufReadPost *.mm set filetype=objcpp " 將*.mm格式的文件作爲Objective-C++源碼進行解析




" --- 括號自動補全 ---
" 設置補全模式
" 花括號的補全方式：輸入'{'後按快速按下回車鍵後會按照c語言格式進行括號補全，如果未快速按下回車鍵則不進行補全操作
" 其餘符號補全功能由插件提供
:inoremap {<CR> {<CR>}<Esc>O



" --- 設置編碼以及備選編碼 ---
set termencoding=utf-8
set encoding=utf-8
let &termencoding=&encoding
set fileencodings=utf-8,gbk,gb2312,gb18030



" --- Vundle插件管理器 ---
filetype off
set rtp+=~/.vim/bundle/Vundle.vim " 設置Vundle插件的路徑
call vundle#begin()

" 插件列表
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
Plugin 'vim-airline/vim-airline' " 相比vim-powerline而言功能更加強大
Plugin 'vim-airline/vim-airline-themes' " vim-airline的主題插件
Plugin 'vim-syntastic/syntastic' " 語法檢測插件
Plugin 'flazz/vim-colorschemes' " vim主題配色集
Plugin 'terryma/vim-multiple-cursors' " 多點編輯插件，選中目標後可以用ctrl+n鍵批量重構同名變量
" Plugin 'Shougo/neocomplcache.vim' " 輕量級的代碼補全插件
Plugin 'winmanager--Fox' " 窗口管理插件
Plugin 'derekwyatt/vim-scala' " vim默認沒有提供scala語言的支持，使用插件添加對scala語言支持
Plugin 'rust-lang/rust.vim' " rust插件
Plugin 'vim-ruby/vim-ruby' " ruby插件
Plugin 'plasticboy/vim-markdown' " markdown語法高亮插件
Plugin 'Raimondi/delimitMate' " 符號智能補全插件
Plugin 'udalov/kotlin-vim' " Kotlin語法高亮
Plugin 'dag/vim-fish' " Fish shell plugin for VIM.
" Plugin 'taglist.vim' " 來自github中vim-scripts收集的插件直接寫名字,不過很可能獲得的是舊版本
" Plugin 'fatih/vim-go' " golang插件，使用指令:GoInstallBinaries安裝補全工具
" Plugin 'klen/python-mode' " python插件
" Plugin 'fholgado/minibufexpl.vim' " 窗口標籤插件，功能已由vim-airline提供
" Plugin 'Valloric/YouCompleteMe' " 高級補全插件，支持語法補全
" Plugin 'ervandew/eclim' " 類似eclipse的java插件
" Plugin 'tpope/vim-rails' " ROR插件
call vundle#end() " required
filetype plugin indent on " 開啓插件

" Vundle常用指令
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" :PluginUpdate     - update all the plugins which you have installed



" --- WinManager配置 ---
" let g:winManagerWindowLayout = "TagList|FileExplorer" " 設置WinManager管理的插件
let g:winManagerWindowLayout = "FileExplorer" " 設置WinManager管理的插件
let g:winManagerWidth = 35 " 設置WinManager側邊欄的大小
let g:persistentBehaviour = 0 " 設置關閉所有文件時自動關閉WinManager
nmap wm :WMToggle<cr> " 定義打開關閉WinManager快捷鍵爲wm



" --- Taglist 配置 ---
let Tlist_Show_Menu = 1 " 顯示taglist菜單
let Tlist_Auto_Update = 1 " 默認更新taglist
let Tlist_Exit_OnlyWindow = 1 " 關閉vim時關閉tag窗口
" nmap tl :TlistToggle<cr> " 設置taglist的快捷鍵爲tl。
" let Tlist_Use_Horiz_Window = 1 " 設置tag窗口橫向顯示
" let Tlist_Show_One_File = 1 " 不同時顯示多個文件的tag，只顯示當前文件的
" let Tlist_Auto_Open = 1 " 打開vim時自動打開tag窗口
" let Tlist_File_Fold_Auto_Close = 1 " 只顯示當前文件的taglist，其它的taglist都被摺疊
" let Tlist_Use_SingleClick = 0 " 設置點擊跳轉tag的方式，0爲雙擊跳轉，1爲單擊跳轉
" let Tlist_Use_Right_Window = 1 " 設置tag窗口靠右顯示（默認窗口靠左）
" let Tlist_Process_File_Always = 1 " taglist始終解析文件中的tag，不管taglist窗口有沒有打開



" --- vim-arline 配置 ---
let g:airline#extensions#tabline#enabled = 1 " 顯示標籤欄
" let g:airline_left_sep = '' " 設置下標籤欄左分隔符
" let g:airline_right_sep = '' " 設置下標籤欄右分隔符
" let g:airline#extensions#tabline#left_sep = '✎' " 設置上標籤欄左前分隔符
" let g:airline#extensions#tabline#left_alt_sep = '◀' " 設置上標籤欄左後分隔符
" let g:airline#extensions#tabline#right_sep = '☰' " 設置上標籤欄右分隔符
" let g:airline_symbols = {'crypt':'1', 'inenr':'¶', 'branch':'⎇', 'paste':'∥', 'whitespace':'Ξ'} " 自定義特殊符號集



" --- vim-markdown 配置 ---
let g:vim_markdown_folding_disabled = 1 " 關閉插件默認的語法摺疊
let g:vim_markdown_math = 1 " 開啓LaTex數學公式解析



" --- neocomplcache配置 ---
let g:neocomplcache_enable_at_startup = 1 " 在vim打開的時候啓動
let g:neocomplcache_enable_auto_select = 1 " 提示的時候默認選擇地一個，否則需要手動選取
let g:neocomplcache_enable_smart_case = 1 " 開啓智能匹配
let g:neocomplcache_min_syntax_length = 3 " 設置最小匹配長度
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_enable_cursor_hold_i = 1 " 在輸入模式下，移動光標時不會觸發補全菜單
let g:neocomplcache_enable_insert_char_pre = 1 " 快速匹配先前輸入的內容，加快匹配速度
let g:neocomplcache_enable_auto_select = 1 " 默認補全光標自動開啓

" 定義補全字典
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" 定義補全關鍵字
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" ctrl+z撤銷已補全的內容再次匹配，ctrl+j主動彈出補全菜單
inoremap <expr><C-z> neocomplcache#undo_completion()
inoremap <expr><C-j> neocomplcache#complete_common_string()

" 啓動vim自帶的omni補全
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" 使用重度omni補全特性
if !exists('g:neocomplcache_force_omni_patterns')
    let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'



" --- syntastic配置 ---
let g:syntastic_check_on_open = 1 " 首次打開文件時即開始檢測語法錯誤
let g:syntastic_c_compiler_options = "-std=c11" " 檢測c語法時使用c11語法
let g:syntastic_cpp_compiler_options = "-std=c++17" " 檢測c++語法時支持c++1y的新特性
let g:syntastic_ignore_files = [".*\.m$"] " 忽略objective-C語言的語法檢測(objc的檢測體驗很差)
let g:syntastic_python_python_exe = "python3" " 檢查python語法時使用python3語法



" --- 常用的幾個主題 ---
" 編輯器主題
" colorschem molokai
" colorschem materialbox
" colorschem xterm16
" colorscheme grb256
" colorschem hybrid-light
" colorscheme hybrid_reverse

" Airline主題
" let g:airline_theme = 'papercolor'
" let g:airline_theme = 'powerlineish'
" let g:airline_theme = 'sol'



" --- 根據OS環境加載設置 ---
if has("win32unix") " Other platform: macunix, unix
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:.,eol:\ " 設置Windows環境下vim的tab、行尾等位置的特殊符號的顯示

    " syntastic配置
    let g:syntastic_error_symbol = "X" " 設置語法錯誤的提示
    let g:syntastic_warning_symbol = "!" " 設置語法警告的提示
else
    set t_Co=256 " 告知終端支持256色顯示
    set listchars=tab:➛\ ,trail:•,extends:#,nbsp:.,eol:\ " 設置Unix環境下vim的tab、行尾等位置的特殊符號的顯示
    let g:syntastic_error_symbol = "✗" " 設置語法錯誤的提示
    let g:syntastic_warning_symbol = "⚠" " 設置語法警告的提示

    " vim-arline配置
    let g:airline_theme = 'powerlineish' " 設置主題
    let g:airline_powerline_fonts = 1 " 使用powerline字體

    " 主題設置
    colorschem molokai
    highlight Normal ctermbg=None " 強制設置主題背景透明

    " 白色主題
    " let g:airline_theme = 'sol'
    " colorscheme hybrid_reverse
endif
