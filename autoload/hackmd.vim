" ~/dev/vim-hackmd/autoload/hackmd.vim

let s:workspace_file = '.hackmd-vim.json'

let s:default_command_templates = {
            \ 'create': '{cli} notes create --output=json',
            \ 'team_create': '{cli} team-notes create --teamPath={team} --output=json',
            \ 'write': '{cli} notes update --noteId={note_id} --content={content}',
            \ 'team_write': '{cli} team-notes update --teamPath={team} --noteId={note_id} --content={content}',
            \ 'read': '{cli} export --noteId={note_id}',
            \ 'list': '{cli} notes --output=json',
            \ 'team_list': '{cli} team-notes --teamPath={team} --output=json',
            \ 'workspace_list': '{cli} teams --output=json',
            \ 'delete': '{cli} notes delete --noteId={note_id}',
            \ 'team_delete': '{cli} team-notes delete --teamPath={team} --noteId={note_id}',
            \ }

function! s:EchoError(message) abort
    echohl ErrorMsg
    echom a:message
    echohl None
endfunction

function! s:GetCli() abort
    return get(g:, 'hackmd_cli', 'hackmd-cli')
endfunction

function! s:GetTemplates() abort
    return extend(copy(s:default_command_templates), get(g:, 'hackmd_command_templates', {}))
endfunction

function! s:FormatCommand(name, args) abort
    let l:templates = s:GetTemplates()
    if !has_key(l:templates, a:name)
        throw 'hackmd-vim: unknown command template: ' . a:name
    endif

    let l:cmd = l:templates[a:name]
    let l:values = extend({'cli': s:GetCli()}, a:args)
    for [l:key, l:value] in items(l:values)
        let l:cmd = substitute(l:cmd, '{' . l:key . '}', shellescape(l:value), 'g')
    endfor
    return l:cmd
endfunction

function! s:RunCommand(name, args, ...) abort
    try
        let l:cmd = s:FormatCommand(a:name, a:args)
    catch
        call s:EchoError(v:exception)
        return {'ok': 0, 'output': ''}
    endtry

    if get(g:, 'hackmd_use_shell_aliases', 0)
        let l:shell = get(g:, 'hackmd_alias_shell', &shell)
        let l:cmd = shellescape(l:shell) . ' -ic ' . shellescape(l:cmd)
    endif

    if a:0
        let l:output = system(l:cmd, a:1)
    else
        let l:output = system(l:cmd)
    endif
    if v:shell_error
        call s:EchoError('HackMD command failed: ' . l:cmd)
        if !empty(l:output)
            echom l:output
        endif
        return {'ok': 0, 'output': l:output}
    endif
    return {'ok': 1, 'output': l:output}
endfunction

function! s:CurrentFileDirOrCwd() abort
    if empty(bufname('%')) || !empty(&buftype)
        return getcwd()
    endif

    let l:file = expand('%:p')
    if empty(l:file)
        return getcwd()
    endif
    return fnamemodify(l:file, ':p:h')
endfunction

function! s:FindWorkspaceConfig() abort
    let l:start = s:CurrentFileDirOrCwd()
    return findfile(s:workspace_file, l:start . ';')
endfunction

function! s:WorkspaceRoot() abort
    let l:config = s:FindWorkspaceConfig()
    if !empty(l:config)
        return fnamemodify(l:config, ':p:h')
    endif
    return fnamemodify(get(g:, 'hackmd_workspace_root', getcwd()), ':p')
endfunction

function! s:ReadWorkspaceConfig() abort
    let l:path = s:FindWorkspaceConfig()
    let l:config = {'team': '', 'notes_dir': '.'}

    if empty(l:path)
        return l:config
    endif
    if !exists('*json_decode')
        call s:EchoError('hackmd-vim requires json_decode() to read ' . s:workspace_file)
        return l:config
    endif

    try
        let l:decoded = json_decode(join(readfile(l:path), "\n"))
        if type(l:decoded) == type({})
            return extend(l:config, l:decoded)
        endif
    catch
        call s:EchoError('Failed to parse workspace config: ' . l:path)
    endtry
    return l:config
endfunction

function! s:WriteWorkspaceConfig(path, config) abort
    if !exists('*json_encode')
        call s:EchoError('hackmd-vim requires json_encode() to write ' . s:workspace_file)
        return 0
    endif

    call writefile(split(json_encode(a:config), "\n"), a:path)
    return 1
endfunction

function! s:WorkspaceBase() abort
    let l:config = s:ReadWorkspaceConfig()
    let l:root = s:WorkspaceRoot()
    let l:notes_dir = get(l:config, 'notes_dir', '.')
    return fnamemodify(l:root . '/' . l:notes_dir, ':p')
endfunction

function! s:FrontMatterBounds(lines) abort
    if empty(a:lines) || a:lines[0] !=# '---'
        return [0, -1]
    endif

    let l:index = 1
    while l:index < len(a:lines)
        if a:lines[l:index] ==# '---'
            return [1, l:index]
        endif
        let l:index += 1
    endwhile
    return [0, -1]
endfunction

function! s:GetFrontMatterPropertyFromLines(lines, prop_name) abort
    let [l:start, l:end] = s:FrontMatterBounds(a:lines)
    if l:end < 0
        let l:start = 0
        let l:end = min([len(a:lines), 10])
    endif

    let l:index = l:start
    while l:index < l:end
        let l:line = a:lines[l:index]
        if l:line =~# '^' . escape(a:prop_name, '\') . '\s*:'
            return trim(strpart(l:line, match(l:line, ':') + 1))
        endif
        let l:index += 1
    endwhile
    return ''
endfunction

function! s:SetFrontMatterPropertyInLines(lines, prop_name, value) abort
    let l:lines = copy(a:lines)
    let [l:start, l:end] = s:FrontMatterBounds(l:lines)
    let l:property = a:prop_name . ': ' . a:value

    if l:end < 0
        return ['---', l:property, '---'] + l:lines
    endif

    let l:index = l:start
    while l:index < l:end
        if l:lines[l:index] =~# '^' . escape(a:prop_name, '\') . '\s*:'
            let l:lines[l:index] = l:property
            return l:lines
        endif
        let l:index += 1
    endwhile

    call insert(l:lines, l:property, l:end)
    return l:lines
endfunction

function! s:RemoveFrontMatterPropertyInLines(lines, prop_name) abort
    let l:lines = copy(a:lines)
    let [l:start, l:end] = s:FrontMatterBounds(l:lines)
    if l:end < 0
        return l:lines
    endif

    let l:index = l:end - 1
    while l:index >= l:start
        if l:lines[l:index] =~# '^' . escape(a:prop_name, '\') . '\s*:'
            call remove(l:lines, l:index)
        endif
        let l:index -= 1
    endwhile
    return l:lines
endfunction

function! s:StripHackmdFrontMatter(lines) abort
    let l:lines = copy(a:lines)
    let [l:start, l:end] = s:FrontMatterBounds(l:lines)
    if l:end < 0
        return l:lines
    endif

    let l:kept = []
    let l:index = l:start
    while l:index < l:end
        let l:line = l:lines[l:index]
        if l:line !~# '^\%(hackmd_id\|hackmd_remote_hash\|team\)\s*:'
            call add(l:kept, l:line)
        endif
        let l:index += 1
    endwhile

    if empty(l:kept)
        return l:lines[(l:end + 1):]
    endif
    return ['---'] + l:kept + ['---'] + l:lines[(l:end + 1):]
endfunction

function! s:FileContentForRemote(file) abort
    return join(s:StripHackmdFrontMatter(s:ReadFileLines(a:file)), "\n")
endfunction

function! s:HashContent(content) abort
    if !exists('*sha256')
        return ''
    endif
    let l:content = substitute(a:content, "\r\n", "\n", 'g')
    let l:content = substitute(l:content, "\n\\+$", '', '')
    return sha256(l:content)
endfunction

function! s:ReadFileLines(file) abort
    if !filereadable(a:file)
        return []
    endif
    return readfile(a:file)
endfunction

function! s:GetFileProperty(file, prop_name) abort
    return s:GetFrontMatterPropertyFromLines(s:ReadFileLines(a:file), a:prop_name)
endfunction

function! s:GetBufferProperty(prop_name) abort
    return s:GetFrontMatterPropertyFromLines(getline(1, '$'), a:prop_name)
endfunction

function! s:SetFileProperty(file, prop_name, value) abort
    let l:lines = s:SetFrontMatterPropertyInLines(s:ReadFileLines(a:file), a:prop_name, a:value)
    call writefile(l:lines, a:file)
endfunction

function! s:RemoveFileProperty(file, prop_name) abort
    let l:lines = s:RemoveFrontMatterPropertyInLines(s:ReadFileLines(a:file), a:prop_name)
    call writefile(l:lines, a:file)
endfunction

function! s:SetBufferProperty(prop_name, value) abort
    let l:lines = s:SetFrontMatterPropertyInLines(getline(1, '$'), a:prop_name, a:value)
    silent %delete _
    call setline(1, l:lines)
endfunction

function! s:DefaultTeamForFile(file) abort
    let l:team = s:GetFileProperty(a:file, 'team')
    if !empty(l:team)
        return l:team
    endif
    return get(s:ReadWorkspaceConfig(), 'team', '')
endfunction

function! s:ParseNoteId(output) abort
    if exists('*json_decode')
        try
            let l:decoded = json_decode(a:output)
            let l:items = type(l:decoded) == type([]) ? l:decoded : [l:decoded]
            for l:item in l:items
                if type(l:item) != type({})
                    continue
                endif
                for l:key in ['id', 'ID', 'noteId', 'note_id']
                    if has_key(l:item, l:key) && !empty(l:item[l:key])
                        return printf('%s', l:item[l:key])
                    endif
                endfor
            endfor
        catch
        endtry
    endif

    let l:patterns = [
                \ 'hackmd_id\s*[:=]\s*\zs[-_[:alnum:]]\+',
                \ 'note[_ -]\?id\s*[:=]\s*\zs[-_[:alnum:]]\+',
                \ '^\s*\zs[-_[:alnum:]]\{6,}\ze\s\+',
                \ '/\zs[-_[:alnum:]]\{6,}\ze\%([?#[:space:]]\|$\)',
                \ ]
    for l:pattern in l:patterns
        let l:match = matchstr(a:output, l:pattern)
        if !empty(l:match)
            return l:match
        endif
    endfor
    return ''
endfunction

function! s:PushFile(file, force) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    let l:team = s:DefaultTeamForFile(l:file)
    let l:content = s:FileContentForRemote(l:file)

    if empty(l:note_id)
        echom '未检测到绑定的 Note ID，正在云端创建新笔记: ' . l:file
        if empty(l:team)
            let l:result = s:RunCommand('create', {'file': l:file, 'content': l:content}, l:content)
        else
            let l:result = s:RunCommand('team_create', {'file': l:file, 'team': l:team, 'content': l:content}, l:content)
        endif

        if !l:result.ok
            return 0
        endif

        let l:new_note_id = s:ParseNoteId(l:result.output)
        if !empty(l:new_note_id)
            call s:SetFileProperty(l:file, 'hackmd_id', l:new_note_id)
            let l:hash = s:HashContent(l:content)
            if !empty(l:hash)
                call s:SetFileProperty(l:file, 'hackmd_remote_hash', l:hash)
            endif
            echom '已写入 hackmd_id: ' . l:new_note_id
        else
            echom l:result.output
            echom '提示：请将返回的 Note ID 写入文件顶部的 hackmd_id 中以供日后同步。'
        endif
        return 1
    endif

    let l:local_remote_hash = s:GetFileProperty(l:file, 'hackmd_remote_hash')
    if !a:force && !empty(l:local_remote_hash)
        let l:remote = s:RunCommand('read', {'note_id': l:note_id})
        if !l:remote.ok
            return 0
        endif
        let l:actual_hash = s:HashContent(l:remote.output)
        if !empty(l:actual_hash) && l:actual_hash !=# l:local_remote_hash
            call s:EchoError('远端内容已变化，停止 push 以避免覆盖: ' . l:file)
            echom '使用 :HPush! 或 :HWorkspacePush! 可强制覆盖远端。'
            return 0
        endif
    endif

    echom '检测到 ID: ' . l:note_id . '，正在同步更新: ' . l:file
    if empty(l:team)
        let l:result = s:RunCommand('write', {'note_id': l:note_id, 'file': l:file, 'content': l:content})
    else
        let l:result = s:RunCommand('team_write', {'note_id': l:note_id, 'file': l:file, 'team': l:team, 'content': l:content})
    endif
    if l:result.ok
        let l:hash = s:HashContent(l:content)
        if !empty(l:hash)
            call s:SetFileProperty(l:file, 'hackmd_remote_hash', l:hash)
        endif
        echom '同步成功: ' . l:file
    endif
    return l:result.ok
endfunction

function! s:PullFile(file) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    if empty(l:note_id)
        call s:EchoError('缺少 hackmd_id，无法拉取: ' . l:file)
        return 0
    endif

    let l:result = s:RunCommand('read', {'note_id': l:note_id})
    if !l:result.ok
        return 0
    endif

    let l:lines = split(l:result.output, "\n", 1)
    let l:lines = s:SetFrontMatterPropertyInLines(l:lines, 'hackmd_id', l:note_id)
    let l:hash = s:HashContent(l:result.output)
    if !empty(l:hash)
        let l:lines = s:SetFrontMatterPropertyInLines(l:lines, 'hackmd_remote_hash', l:hash)
    endif
    let l:team = s:GetFileProperty(l:file, 'team')
    if !empty(l:team)
        let l:lines = s:SetFrontMatterPropertyInLines(l:lines, 'team', l:team)
    endif
    call writefile(l:lines, l:file)
    echom '拉取成功: ' . l:file
    return 1
endfunction

function! s:DeleteFile(file, force) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    if empty(l:note_id)
        call s:EchoError('缺少 hackmd_id，无法删除远端 note: ' . l:file)
        return 0
    endif

    if !a:force
        let l:choice = confirm('Delete remote HackMD note ' . l:note_id . '?', "&Yes\n&No", 2)
        if l:choice != 1
            echom '取消删除: ' . l:file
            return 0
        endif
    endif

    let l:team = s:DefaultTeamForFile(l:file)
    if empty(l:team)
        let l:result = s:RunCommand('delete', {'note_id': l:note_id, 'file': l:file})
    else
        let l:result = s:RunCommand('team_delete', {'note_id': l:note_id, 'file': l:file, 'team': l:team})
    endif
    if !l:result.ok
        return 0
    endif

    call s:RemoveFileProperty(l:file, 'hackmd_id')
    call s:RemoveFileProperty(l:file, 'hackmd_remote_hash')
    echom '远端 note 已删除，本地文件已解绑: ' . l:file
    return 1
endfunction

function! s:WorkspaceFiles() abort
    let l:base = s:WorkspaceBase()
    return sort(globpath(l:base, '**/*.md', 0, 1))
endfunction

function! s:ParseNotesList(output) abort
    if !exists('*json_decode')
        call s:EchoError('hackmd-vim requires json_decode() to import workspace notes.')
        return []
    endif

    try
        let l:decoded = json_decode(a:output)
    catch
        call s:EchoError('无法解析 hackmd-cli notes JSON 输出。')
        return []
    endtry

    let l:items = type(l:decoded) == type([]) ? l:decoded : [l:decoded]
    let l:notes = []
    for l:item in l:items
        if type(l:item) != type({})
            continue
        endif
        let l:id = ''
        let l:title = ''
        for l:key in ['id', 'ID', 'noteId', 'note_id']
            if has_key(l:item, l:key) && !empty(l:item[l:key])
                let l:id = printf('%s', l:item[l:key])
                break
            endif
        endfor
        for l:key in ['title', 'Title', 'name', 'Name']
            if has_key(l:item, l:key) && !empty(l:item[l:key])
                let l:title = printf('%s', l:item[l:key])
                break
            endif
        endfor
        if !empty(l:id)
            call add(l:notes, {'id': l:id, 'title': empty(l:title) ? l:id : l:title})
        endif
    endfor
    return l:notes
endfunction

function! s:JsonItems(output, context) abort
    if !exists('*json_decode')
        call s:EchoError('hackmd-vim requires json_decode() to parse ' . a:context . '.')
        return []
    endif

    try
        let l:decoded = json_decode(a:output)
    catch
        call s:EchoError('无法解析 hackmd-cli ' . a:context . ' JSON 输出。')
        return []
    endtry

    if type(l:decoded) == type([])
        return l:decoded
    endif
    if type(l:decoded) == type({})
        for l:key in ['workspaces', 'teams', 'data', 'items', 'result']
            if has_key(l:decoded, l:key) && type(l:decoded[l:key]) == type([])
                return l:decoded[l:key]
            endif
        endfor
        return [l:decoded]
    endif
    return []
endfunction

function! s:FirstStringValue(item, keys) abort
    for l:key in a:keys
        if has_key(a:item, l:key) && !empty(a:item[l:key])
            return printf('%s', a:item[l:key])
        endif
    endfor
    return ''
endfunction

function! s:ParseWorkspaceList(output) abort
    let l:items = s:JsonItems(a:output, 'workspace list')
    let l:workspaces = []
    for l:item in l:items
        if type(l:item) == type('')
            call add(l:workspaces, {'path': l:item, 'name': l:item})
            continue
        endif
        if type(l:item) != type({})
            continue
        endif

        let l:path = s:FirstStringValue(l:item, ['path', 'teamPath', 'team_path', 'workspacePath', 'workspace_path', 'urlPath', 'url_path', 'slug', 'id'])
        let l:name = s:FirstStringValue(l:item, ['name', 'title', 'displayName', 'display_name'])
        if empty(l:path)
            let l:path = l:name
        endif
        if empty(l:name)
            let l:name = l:path
        endif
        if !empty(l:path)
            call add(l:workspaces, {'path': l:path, 'name': l:name})
        endif
    endfor
    return l:workspaces
endfunction

function! s:ListWorkspaces() abort
    let l:result = s:RunCommand('workspace_list', {})
    if !l:result.ok
        return []
    endif

    let l:workspaces = s:ParseWorkspaceList(l:result.output)
    if empty(l:workspaces)
        echom 'HackMD workspaces: 0'
        return []
    endif

    echom 'HackMD workspaces: ' . len(l:workspaces)
    for l:workspace in l:workspaces
        let l:line = '  ' . l:workspace.path
        if l:workspace.name !=# l:workspace.path
            let l:line .= '  ' . l:workspace.name
        endif
        echom l:line
    endfor
    return l:workspaces
endfunction

function! s:SlugifyTitle(title) abort
    let l:slug = tolower(a:title)
    let l:slug = substitute(l:slug, '[\/:*?"<>|]', '-', 'g')
    let l:slug = substitute(l:slug, '\s\+', '-', 'g')
    let l:slug = substitute(l:slug, '[^[:alnum:]_.-]', '', 'g')
    let l:slug = substitute(l:slug, '-\+', '-', 'g')
    let l:slug = substitute(l:slug, '^\.\+', '', '')
    return empty(l:slug) ? 'untitled' : l:slug
endfunction

function! s:FindFileByNoteId(files, note_id) abort
    for l:file in a:files
        if s:GetFileProperty(l:file, 'hackmd_id') ==# a:note_id
            return l:file
        endif
    endfor
    return ''
endfunction

function! s:ImportWorkspaceNotes() abort
    let l:config = s:ReadWorkspaceConfig()
    let l:team = get(l:config, 'team', '')
    if empty(l:team)
        let l:result = s:RunCommand('list', {})
    else
        let l:result = s:RunCommand('team_list', {'team': l:team})
    endif
    if !l:result.ok
        return 0
    endif

    let l:notes = s:ParseNotesList(l:result.output)
    let l:files = s:WorkspaceFiles()
    let l:base = s:WorkspaceBase()
    if !isdirectory(l:base)
        call mkdir(l:base, 'p')
    endif

    let l:created = 0
    let l:updated = 0
    for l:note in l:notes
        let l:file = s:FindFileByNoteId(l:files, l:note.id)
        if empty(l:file)
            let l:file = l:base . s:SlugifyTitle(l:note.title) . '.md'
            let l:counter = 2
            while filereadable(l:file)
                let l:file = l:base . s:SlugifyTitle(l:note.title) . '-' . l:counter . '.md'
                let l:counter += 1
            endwhile
            call writefile(['---', 'hackmd_id: ' . l:note.id, '---', ''], l:file)
            let l:created += 1
            call add(l:files, l:file)
        else
            let l:updated += 1
        endif
        if !empty(l:team)
            call s:SetFileProperty(l:file, 'team', l:team)
        endif
        call s:PullFile(l:file)
    endfor

    echom 'Workspace import 完成: 新建 ' . l:created . '，更新 ' . l:updated
    return 1
endfunction

" 辅助函数：读取当前 buffer 的 YAML front matter 属性。
function! hackmd#GetFrontMatterProperty(prop_name) abort
    return s:GetBufferProperty(a:prop_name)
endfunction

" 一键保存并上传当前文件。
function! hackmd#BufferPush(force) abort
    if empty(bufname('%')) || !empty(&buftype) || empty(expand('%:p'))
        call s:EchoError('当前 buffer 没有关联文件，无法上传。')
        return
    endif
    write
    call s:PushFile(expand('%:p'), a:force)
    edit
endfunction

" 从 HackMD 拉取当前 note 内容到本地文件。
function! hackmd#BufferPull() abort
    let l:file = expand('%:p')
    if empty(l:file)
        call s:EchoError('当前 buffer 没有关联文件，无法拉取。')
        return
    endif
    if &modified
        call s:EchoError('当前 buffer 有未保存修改，请先保存或放弃修改后再拉取。')
        return
    endif

    if s:PullFile(l:file)
        edit!
    endif
endfunction

function! hackmd#BufferDelete(force) abort
    let l:file = expand('%:p')
    if empty(l:file)
        call s:EchoError('当前 buffer 没有关联文件，无法删除远端 note。')
        return
    endif
    if &modified
        call s:EchoError('当前 buffer 有未保存修改，请先保存或放弃修改后再删除。')
        return
    endif

    if s:DeleteFile(l:file, a:force)
        edit!
    endif
endfunction

" 当前 buffer 的保守同步：已有 hackmd_id 时先 pull；否则创建/上传。
function! hackmd#BufferSync() abort
    if empty(s:GetBufferProperty('hackmd_id'))
        call hackmd#BufferPush(0)
    else
        call hackmd#BufferPull()
    endif
endfunction

function! hackmd#WorkspaceInit(team) abort
    let l:path = getcwd() . '/' . s:workspace_file
    if filereadable(l:path)
        call s:EchoError('Workspace config already exists: ' . l:path)
        return
    endif

    let l:config = {'team': a:team, 'notes_dir': '.'}
    if s:WriteWorkspaceConfig(l:path, l:config)
        echom 'Created workspace config: ' . l:path
    endif
endfunction

function! hackmd#WorkspaceUse(team) abort
    let l:path = s:FindWorkspaceConfig()
    if empty(l:path)
        let l:path = getcwd() . '/' . s:workspace_file
        let l:config = {'team': '', 'notes_dir': '.'}
    else
        let l:config = s:ReadWorkspaceConfig()
    endif

    let l:config.team = a:team
    if s:WriteWorkspaceConfig(l:path, l:config)
        echom 'Updated workspace team: ' . a:team
        call hackmd#WorkspaceInfo()
    endif
endfunction

function! hackmd#WorkspacePush(force) abort
    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError('Workspace 中没有找到 Markdown 文件。')
        return
    endif

    let l:success = 0
    for l:file in l:files
        if s:PushFile(l:file, a:force)
            let l:success += 1
        endif
    endfor
    echom 'Workspace push 完成: ' . l:success . '/' . len(l:files)
endfunction

function! hackmd#WorkspacePull() abort
    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError('Workspace 中没有找到 Markdown 文件。')
        return
    endif

    let l:success = 0
    let l:skipped = 0
    for l:file in l:files
        if empty(s:GetFileProperty(l:file, 'hackmd_id'))
            let l:skipped += 1
            continue
        endif
        if s:PullFile(l:file)
            let l:success += 1
        endif
    endfor
    echom 'Workspace pull 完成: ' . l:success . '/' . len(l:files) . '，跳过无 hackmd_id 文件: ' . l:skipped
endfunction

function! hackmd#WorkspaceDelete(force) abort
    if !a:force
        call s:EchoError('批量删除远端 note 需要使用 :HWorkspaceDelete!')
        return
    endif

    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError('Workspace 中没有找到 Markdown 文件。')
        return
    endif

    let l:success = 0
    let l:skipped = 0
    for l:file in l:files
        if empty(s:GetFileProperty(l:file, 'hackmd_id'))
            let l:skipped += 1
            continue
        endif
        if s:DeleteFile(l:file, 1)
            let l:success += 1
        endif
    endfor
    echom 'Workspace delete 完成: ' . l:success . '/' . len(l:files) . '，跳过无 hackmd_id 文件: ' . l:skipped
endfunction

function! hackmd#WorkspaceImport() abort
    call s:ImportWorkspaceNotes()
endfunction

function! hackmd#WorkspaceList() abort
    return s:ListWorkspaces()
endfunction

function! hackmd#WorkspaceInfo() abort
    let l:config_path = s:FindWorkspaceConfig()
    let l:config = s:ReadWorkspaceConfig()
    let l:root = s:WorkspaceRoot()
    let l:base = s:WorkspaceBase()
    let l:files = s:WorkspaceFiles()
    let l:team = get(l:config, 'team', '')
    let l:notes_dir = get(l:config, 'notes_dir', '.')

    echom 'HackMD workspace info'
    echom '  config: ' . (empty(l:config_path) ? '(none; using fallback)' : fnamemodify(l:config_path, ':p'))
    echom '  root: ' . l:root
    echom '  notes_dir: ' . l:notes_dir
    echom '  scan_dir: ' . l:base
    echom '  team: ' . (empty(l:team) ? '(none)' : l:team)
    echom '  markdown_files: ' . len(l:files)
endfunction
