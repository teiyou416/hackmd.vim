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
    command! -buffer -bang HPush call hackmd#BufferPush(<bang>0)
    command! -buffer HPull call hackmd#BufferPull()
    command! -buffer -bang HDelete call hackmd#BufferDelete(<bang>0)
    command! -buffer HSync call hackmd#BufferSync()
    command! -buffer -nargs=? HWorkspaceInit call hackmd#WorkspaceInit(<q-args>)
    command! -buffer -nargs=1 HWorkspaceUse call hackmd#WorkspaceUse(<q-args>)
    command! -buffer -bang HWorkspacePush call hackmd#WorkspacePush(<bang>0)
    command! -buffer HWorkspacePull call hackmd#WorkspacePull()
    command! -buffer -bang HWorkspaceDelete call hackmd#WorkspaceDelete(<bang>0)
    command! -buffer HWorkspaceImport call hackmd#WorkspaceImport()
    command! -buffer HWorkspaceInfo call hackmd#WorkspaceInfo()
    
    " 绑定快捷键，同样只对当前 Markdown buffer 生效
    if !hasmapto(':HPush<CR>', 'n')
        nnoremap <buffer> <leader>hp :HPush<CR>
    endif
    if !hasmapto(':HPull<CR>', 'n')
        nnoremap <buffer> <leader>hl :HPull<CR>
    endif
    if !hasmapto(':HSync<CR>', 'n')
        nnoremap <buffer> <leader>hs :HSync<CR>
    endif
endfunction
