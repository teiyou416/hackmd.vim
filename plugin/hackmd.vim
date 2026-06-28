" ~/dev/vim-hackmd/plugin/hackmd.vim

if exists('g:loaded_vim_hackmd')
    finish
endif
let g:loaded_vim_hackmd = 1

" 定义一个自动命令组：当文件类型为 markdown 时，绑定 buffer 级别的命令和快捷键
augroup vim_hackmd
    autocmd!
    autocmd FileType markdown call s:SetupHackmdMaps()
augroup END

function! s:SetupHackmdMaps()
    " 注册命令，调用 autoload 里的函数
    command! -buffer HPush call hackmd#BufferPush()
    
    " 绑定快捷键，同样只对当前 Markdown buffer 生效
    if !hasmapto(':HPush<CR>', 'n')
        nnoremap <buffer> <leader>hp :HPush<CR>
    endif
endfunction
