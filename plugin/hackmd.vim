" ~/dev/vim-hackmd/plugin/hackmd.vim

if exists('g:loaded_vim_hackmd')
    finish
endif
let g:loaded_vim_hackmd = 1

" 注册命令，workspace 命令需要能在 startify 等无文件 buffer 中使用。
command! -nargs=? HLogin call hackmd#Login(<q-args>)
command! HLogout call hackmd#Logout()
command! -bang HPush call hackmd#BufferPush(<bang>0)
command! HPull call hackmd#BufferPull()
command! -bang HDelete call hackmd#BufferDelete(<bang>0)
command! HSync call hackmd#BufferSync()
command! -nargs=? HWorkspaceInit call hackmd#WorkspaceInit(<q-args>)
command! -nargs=1 HWorkspaceUse call hackmd#WorkspaceUse(<q-args>)
command! -bang HWorkspacePush call hackmd#WorkspacePush(<bang>0)
command! HWorkspacePull call hackmd#WorkspacePull()
command! -bang HWorkspaceDelete call hackmd#WorkspaceDelete(<bang>0)
command! HWorkspaceImport call hackmd#WorkspaceImport()
command! HWorkspaceList call hackmd#WorkspaceList()
command! HWorkspaceInfo call hackmd#WorkspaceInfo()

" 定义一个自动命令组：当文件类型为 markdown 时，绑定 buffer 级别的快捷键
augroup vim_hackmd
    autocmd!
    autocmd FileType markdown call s:SetupHackmdMaps()
augroup END

function! s:SetupHackmdMaps()
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
