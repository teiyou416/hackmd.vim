" ~/dev/vim-hackmd/autoload/hackmd.vim

" 辅助函数：用来读取文件头部的 YAML 属性
function! hackmd#GetFrontMatterProperty(prop_name)
    let l:lines = getline(1, 10)
    for l:line in l:lines
        if l:line =~ '^' . a:prop_name . '\s*:'
            return trim(split(l:line, ':')[1])
        endif
    endfor
    return ''
endfunction

" 主函数：一键保存并上传当前文件
function! hackmd#BufferPush()
    write
    " 调用同文件下的辅助函数
    let l:note_id = hackmd#GetFrontMatterProperty('hackmd_id')
    let l:current_file = expand('%:p')

    if empty(l:note_id)
        echo "未检测到绑定的 Note ID，正在云端创建新笔记..."
        let l:team_path = hackmd#GetFrontMatterProperty('team')
        
        let l:cmd = 'hack notes:create ' . shellescape(l:current_file)
        if !empty(l:team_path)
            let l:cmd = 'hack team-notes:create ' . shellescape(l:current_file) . ' --teamPath=' . shellescape(l:team_path)
        endif
        
        let l:output = system(l:cmd)
        echo l:output
        echo "💡 提示：请将返回的 Note ID 写入文件顶部的 hackmd_id 中以供日后同步。"
    else
        echo "检测到 ID: " . l:note_id . " ，正在同步更新..."
        let l:cmd = 'hack notes:write ' . shellescape(l:note_id) . ' ' . shellescape(l:current_file)
        let l:output = system(l:cmd)
        echo "同步成功！"
    endif
endfunction
