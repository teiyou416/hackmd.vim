" ~/dev/vim-hackmd/autoload/hackmd.vim

let s:workspace_file = '.hackmd-vim.json'

let s:messages = {
            \ 'en': {
            \   'command_failed': 'HackMD command failed: %s',
            \   'login_required': 'Not logged in to HackMD. Run :HLogin first.',
            \   'json_decode_read_required': 'hackmd-vim requires json_decode() to read %s',
            \   'workspace_config_parse_failed': 'Failed to parse workspace config: %s',
            \   'json_encode_write_required': 'hackmd-vim requires json_encode() to write %s',
            \   'creating_note': 'No bound Note ID found. Creating a remote note: %s',
            \   'wrote_note_id': 'Wrote hackmd_id: %s',
            \   'write_note_id_hint': 'Tip: write the returned Note ID to hackmd_id at the top of the file for future sync.',
            \   'remote_changed': 'Remote content changed. Push stopped to avoid overwriting: %s',
            \   'force_push_hint': 'Use :HPush! or :HWorkspacePush! to overwrite the remote note.',
            \   'updating_note': 'Found ID: %s. Updating remote note: %s',
            \   'sync_succeeded': 'Sync succeeded: %s',
            \   'missing_note_id_pull': 'Missing hackmd_id. Cannot pull: %s',
            \   'pull_updated': 'Pull succeeded. Updated local file: %s',
            \   'pull_unchanged': 'Pull succeeded. Local file unchanged: %s',
            \   'missing_note_id_delete': 'Missing hackmd_id. Cannot delete remote note: %s',
            \   'delete_confirm': 'Delete remote HackMD note %s?',
            \   'canceled_delete': 'Delete canceled: %s',
            \   'remote_deleted': 'Remote note deleted and local file unbound: %s',
            \   'json_decode_import_required': 'hackmd-vim requires json_decode() to import workspace notes.',
            \   'notes_json_parse_failed': 'Failed to parse hackmd-cli notes JSON output.',
            \   'json_decode_parse_required': 'hackmd-vim requires json_decode() to parse %s.',
            \   'context_json_parse_failed': 'Failed to parse hackmd-cli %s JSON output.',
            \   'workspaces_count': 'HackMD workspaces: %s',
            \   'workspace_import_done': 'Workspace import complete: created %s, updated %s',
            \   'login_canceled': 'HackMD login canceled: empty API token.',
            \   'login_succeeded': 'HackMD login succeeded.',
            \   'logout_succeeded': 'HackMD logout succeeded.',
            \   'buffer_no_file_push': 'Current buffer has no file. Cannot push.',
            \   'buffer_no_file_pull': 'Current buffer has no file. Cannot pull.',
            \   'buffer_modified_pull': 'Current buffer has unsaved changes. Save or discard them before pulling.',
            \   'buffer_no_file_delete': 'Current buffer has no file. Cannot delete remote note.',
            \   'buffer_modified_delete': 'Current buffer has unsaved changes. Save or discard them before deleting.',
            \   'workspace_config_exists': 'Workspace config already exists: %s',
            \   'workspace_config_created': 'Created workspace config: %s',
            \   'workspace_team_updated': 'Updated workspace team: %s',
            \   'workspace_no_markdown': 'No Markdown files found in workspace.',
            \   'workspace_push_done': 'Workspace push complete: %s/%s',
            \   'workspace_pull_done': 'Workspace pull complete: %s/%s, skipped files without hackmd_id: %s, updated local files: %s',
            \   'updated_files': 'Updated files:',
            \   'workspace_delete_bang_required': 'Batch remote note deletion requires :HWorkspaceDelete!',
            \   'workspace_delete_done': 'Workspace delete complete: %s/%s, skipped files without hackmd_id: %s',
            \   'workspace_info_title': 'HackMD workspace info',
            \   'workspace_info_config': '  config: %s',
            \   'workspace_info_none_fallback': '(none; using fallback)',
            \   'workspace_info_root': '  root: %s',
            \   'workspace_info_notes_dir': '  notes_dir: %s',
            \   'workspace_info_scan_dir': '  scan_dir: %s',
            \   'workspace_info_team': '  team: %s',
            \   'workspace_info_none': '(none)',
            \   'workspace_info_markdown_files': '  markdown_files: %s',
            \   'language_current': 'HackMD prompt language: %s',
            \   'language_updated': 'HackMD prompt language set to: %s',
            \   'language_invalid': 'Unsupported HackMD prompt language: %s. Use en or zh.',
            \   'api_token_prompt': 'HackMD API token: ',
            \   'confirm_choices': "&Yes\n&No",
            \ },
            \ 'zh': {
            \   'command_failed': 'HackMD 命令执行失败: %s',
            \   'login_required': '尚未登录 HackMD，请先执行 :HLogin 登录账户。',
            \   'json_decode_read_required': 'hackmd-vim 需要 json_decode() 才能读取 %s',
            \   'workspace_config_parse_failed': '无法解析 workspace 配置: %s',
            \   'json_encode_write_required': 'hackmd-vim 需要 json_encode() 才能写入 %s',
            \   'creating_note': '未检测到绑定的 Note ID，正在云端创建新笔记: %s',
            \   'wrote_note_id': '已写入 hackmd_id: %s',
            \   'write_note_id_hint': '提示：请将返回的 Note ID 写入文件顶部的 hackmd_id 中以供日后同步。',
            \   'remote_changed': '远端内容已变化，停止 push 以避免覆盖: %s',
            \   'force_push_hint': '使用 :HPush! 或 :HWorkspacePush! 可强制覆盖远端。',
            \   'updating_note': '检测到 ID: %s，正在同步更新: %s',
            \   'sync_succeeded': '同步成功: %s',
            \   'missing_note_id_pull': '缺少 hackmd_id，无法拉取: %s',
            \   'pull_updated': '拉取成功，已更新本地文件: %s',
            \   'pull_unchanged': '拉取成功，本地文件无变化: %s',
            \   'missing_note_id_delete': '缺少 hackmd_id，无法删除远端 note: %s',
            \   'delete_confirm': '删除远端 HackMD note %s?',
            \   'canceled_delete': '取消删除: %s',
            \   'remote_deleted': '远端 note 已删除，本地文件已解绑: %s',
            \   'json_decode_import_required': 'hackmd-vim 需要 json_decode() 才能导入 workspace notes。',
            \   'notes_json_parse_failed': '无法解析 hackmd-cli notes JSON 输出。',
            \   'json_decode_parse_required': 'hackmd-vim 需要 json_decode() 才能解析 %s。',
            \   'context_json_parse_failed': '无法解析 hackmd-cli %s JSON 输出。',
            \   'workspaces_count': 'HackMD workspaces: %s',
            \   'workspace_import_done': 'Workspace import 完成: 新建 %s，更新 %s',
            \   'login_canceled': 'HackMD 登录已取消: API token 为空。',
            \   'login_succeeded': 'HackMD 登录成功。',
            \   'logout_succeeded': 'HackMD 登出成功。',
            \   'buffer_no_file_push': '当前 buffer 没有关联文件，无法上传。',
            \   'buffer_no_file_pull': '当前 buffer 没有关联文件，无法拉取。',
            \   'buffer_modified_pull': '当前 buffer 有未保存修改，请先保存或放弃修改后再拉取。',
            \   'buffer_no_file_delete': '当前 buffer 没有关联文件，无法删除远端 note。',
            \   'buffer_modified_delete': '当前 buffer 有未保存修改，请先保存或放弃修改后再删除。',
            \   'workspace_config_exists': 'Workspace config 已存在: %s',
            \   'workspace_config_created': '已创建 workspace config: %s',
            \   'workspace_team_updated': '已更新 workspace team: %s',
            \   'workspace_no_markdown': 'Workspace 中没有找到 Markdown 文件。',
            \   'workspace_push_done': 'Workspace push 完成: %s/%s',
            \   'workspace_pull_done': 'Workspace pull 完成: %s/%s，跳过无 hackmd_id 文件: %s，更新本地文件: %s',
            \   'updated_files': '更新的文件:',
            \   'workspace_delete_bang_required': '批量删除远端 note 需要使用 :HWorkspaceDelete!',
            \   'workspace_delete_done': 'Workspace delete 完成: %s/%s，跳过无 hackmd_id 文件: %s',
            \   'workspace_info_title': 'HackMD workspace 信息',
            \   'workspace_info_config': '  config: %s',
            \   'workspace_info_none_fallback': '(无；使用 fallback)',
            \   'workspace_info_root': '  root: %s',
            \   'workspace_info_notes_dir': '  notes_dir: %s',
            \   'workspace_info_scan_dir': '  scan_dir: %s',
            \   'workspace_info_team': '  team: %s',
            \   'workspace_info_none': '(无)',
            \   'workspace_info_markdown_files': '  markdown_files: %s',
            \   'language_current': 'HackMD 提示语言: %s',
            \   'language_updated': 'HackMD 提示语言已设为: %s',
            \   'language_invalid': '不支持的 HackMD 提示语言: %s。请使用 en 或 zh。',
            \   'api_token_prompt': 'HackMD API token: ',
            \   'confirm_choices': "&是\n&否",
            \ },
            \ }

function! s:NormalizeLanguage(language) abort
    let l:language = tolower(trim(a:language))
    if l:language ==# 'zh'
        return 'zh'
    endif
    if l:language ==# 'en' || l:language ==# ''
        return 'en'
    endif
    return ''
endfunction

function! s:Language() abort
    let l:language = s:NormalizeLanguage(get(g:, 'hackmd_language', 'en'))
    return empty(l:language) ? 'en' : l:language
endfunction

function! s:Msg(key, ...) abort
    let l:language = s:Language()
    let l:template = get(get(s:messages, l:language, s:messages.en), a:key, get(s:messages.en, a:key, a:key))
    if a:0
        return call('printf', [l:template] + a:000)
    endif
    return l:template
endfunction

function! s:Echo(key, ...) abort
    echom call('s:Msg', [a:key] + a:000)
endfunction

let s:default_command_templates = {
            \ 'login': '{cli} login',
            \ 'logout': '{cli} logout',
            \ 'whoami': '{cli} whoami',
            \ 'create': '{cli} notes create --title={title} --output=json',
            \ 'team_create': '{cli} team-notes create --teamPath={team} --title={title} --output=json',
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
    let l:has_input = 0
    let l:input = ''
    let l:options = {}
    if a:0
        if type(a:1) == type({})
            let l:options = a:1
        else
            let l:has_input = 1
            let l:input = a:1
            if a:0 > 1 && type(a:2) == type({})
                let l:options = a:2
            endif
        endif
    endif

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

    if l:has_input
        let l:output = system(l:cmd, l:input)
    else
        let l:output = system(l:cmd)
    endif
    if v:shell_error
        if !get(l:options, 'quiet', 0)
            call s:EchoError(s:Msg('command_failed', l:cmd))
            if !empty(l:output)
                echom l:output
            endif
        endif
        return {'ok': 0, 'output': l:output}
    endif
    return {'ok': 1, 'output': l:output}
endfunction

function! s:EnsureLoggedIn() abort
    let l:result = s:RunCommand('whoami', {}, {'quiet': 1})
    if l:result.ok
        return 1
    endif

    call s:EchoError(s:Msg('login_required'))
    return 0
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
        call s:EchoError(s:Msg('json_decode_read_required', s:workspace_file))
        return l:config
    endif

    try
        let l:decoded = json_decode(join(readfile(l:path), "\n"))
        if type(l:decoded) == type({})
            return extend(l:config, l:decoded)
        endif
    catch
        call s:EchoError(s:Msg('workspace_config_parse_failed', l:path))
    endtry
    return l:config
endfunction

function! s:WriteWorkspaceConfig(path, config) abort
    if !exists('*json_encode')
        call s:EchoError(s:Msg('json_encode_write_required', s:workspace_file))
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

function! s:TitleForFile(file) abort
    let l:title = fnamemodify(a:file, ':t:r')
    return empty(l:title) ? 'Untitled' : l:title
endfunction

function! s:PushFile(file, force) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    let l:team = s:DefaultTeamForFile(l:file)
    let l:content = s:FileContentForRemote(l:file)
    let l:title = s:TitleForFile(l:file)

    if empty(l:note_id)
        call s:Echo('creating_note', l:file)
        if empty(l:team)
            let l:result = s:RunCommand('create', {'file': l:file, 'content': l:content, 'title': l:title}, l:content)
        else
            let l:result = s:RunCommand('team_create', {'file': l:file, 'team': l:team, 'content': l:content, 'title': l:title}, l:content)
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
            call s:Echo('wrote_note_id', l:new_note_id)
        else
            echom l:result.output
            call s:Echo('write_note_id_hint')
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
            call s:EchoError(s:Msg('remote_changed', l:file))
            call s:Echo('force_push_hint')
            return 0
        endif
    endif

    call s:Echo('updating_note', l:note_id, l:file)
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
        call s:Echo('sync_succeeded', l:file)
    endif
    return l:result.ok
endfunction

function! s:PullFileResult(file) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    if empty(l:note_id)
        call s:EchoError(s:Msg('missing_note_id_pull', l:file))
        return {'ok': 0, 'updated': 0, 'file': l:file}
    endif

    let l:result = s:RunCommand('read', {'note_id': l:note_id})
    if !l:result.ok
        return {'ok': 0, 'updated': 0, 'file': l:file}
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

    let l:updated = s:ReadFileLines(l:file) !=# l:lines
    if l:updated
        call writefile(l:lines, l:file)
        call s:Echo('pull_updated', l:file)
    else
        call s:Echo('pull_unchanged', l:file)
    endif
    return {'ok': 1, 'updated': l:updated, 'file': l:file}
endfunction

function! s:PullFile(file) abort
    return s:PullFileResult(a:file).ok
endfunction

function! s:DeleteFile(file, force) abort
    let l:file = fnamemodify(a:file, ':p')
    let l:note_id = s:GetFileProperty(l:file, 'hackmd_id')
    if empty(l:note_id)
        call s:EchoError(s:Msg('missing_note_id_delete', l:file))
        return 0
    endif

    if !a:force
        let l:choice = confirm(s:Msg('delete_confirm', l:note_id), s:Msg('confirm_choices'), 2)
        if l:choice != 1
            call s:Echo('canceled_delete', l:file)
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
    call s:Echo('remote_deleted', l:file)
    return 1
endfunction

function! s:WorkspaceFiles() abort
    let l:base = s:WorkspaceBase()
    return sort(globpath(l:base, '**/*.md', 0, 1))
endfunction

function! s:ParseNotesList(output) abort
    if !exists('*json_decode')
        call s:EchoError(s:Msg('json_decode_import_required'))
        return []
    endif

    try
        let l:decoded = json_decode(a:output)
    catch
        call s:EchoError(s:Msg('notes_json_parse_failed'))
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
        call s:EchoError(s:Msg('json_decode_parse_required', a:context))
        return []
    endif

    try
        let l:decoded = json_decode(a:output)
    catch
        call s:EchoError(s:Msg('context_json_parse_failed', a:context))
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
        call s:Echo('workspaces_count', 0)
        return []
    endif

    call s:Echo('workspaces_count', len(l:workspaces))
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

    call s:Echo('workspace_import_done', l:created, l:updated)
    return 1
endfunction

" 辅助函数：读取当前 buffer 的 YAML front matter 属性。
function! hackmd#GetFrontMatterProperty(prop_name) abort
    return s:GetBufferProperty(a:prop_name)
endfunction

function! hackmd#Language(...) abort
    if !a:0 || empty(trim(a:1))
        call s:Echo('language_current', s:Language())
        return s:Language()
    endif

    let l:language = s:NormalizeLanguage(a:1)
    if empty(l:language)
        call s:EchoError(s:Msg('language_invalid', a:1))
        return s:Language()
    endif

    let g:hackmd_language = l:language
    call s:Echo('language_updated', l:language)
    return l:language
endfunction

function! hackmd#CompleteLanguage(arg_lead, cmd_line, cursor_pos) abort
    return filter(['en', 'zh'], 'v:val =~# "^" . a:arg_lead')
endfunction

function! hackmd#Login(...) abort
    let l:api_token = a:0 ? a:1 : ''
    if empty(l:api_token)
        let l:api_token = inputsecret(s:Msg('api_token_prompt'))
        echo ''
    endif
    if empty(l:api_token)
        call s:EchoError(s:Msg('login_canceled'))
        return 0
    endif

    let l:result = s:RunCommand('login', {'api_token': l:api_token}, l:api_token . "\n")
    if l:result.ok
        call s:Echo('login_succeeded')
    endif
    return l:result.ok
endfunction

function! hackmd#Logout() abort
    let l:result = s:RunCommand('logout', {})
    if l:result.ok
        call s:Echo('logout_succeeded')
    endif
    return l:result.ok
endfunction

" 一键保存并上传当前文件。
function! hackmd#BufferPush(force) abort
    if empty(bufname('%')) || !empty(&buftype) || empty(expand('%:p'))
        call s:EchoError(s:Msg('buffer_no_file_push'))
        return
    endif
    if !s:EnsureLoggedIn()
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
        call s:EchoError(s:Msg('buffer_no_file_pull'))
        return
    endif
    if &modified
        call s:EchoError(s:Msg('buffer_modified_pull'))
        return
    endif
    if !s:EnsureLoggedIn()
        return
    endif

    if s:PullFile(l:file)
        edit!
    endif
endfunction

function! hackmd#BufferDelete(force) abort
    let l:file = expand('%:p')
    if empty(l:file)
        call s:EchoError(s:Msg('buffer_no_file_delete'))
        return
    endif
    if &modified
        call s:EchoError(s:Msg('buffer_modified_delete'))
        return
    endif
    if !s:EnsureLoggedIn()
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
        call s:EchoError(s:Msg('workspace_config_exists', l:path))
        return
    endif

    let l:config = {'team': a:team, 'notes_dir': '.'}
    if s:WriteWorkspaceConfig(l:path, l:config)
        call s:Echo('workspace_config_created', l:path)
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
        call s:Echo('workspace_team_updated', a:team)
        call hackmd#WorkspaceInfo()
    endif
endfunction

function! hackmd#WorkspacePush(force) abort
    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError(s:Msg('workspace_no_markdown'))
        return
    endif
    if !s:EnsureLoggedIn()
        return
    endif

    let l:success = 0
    for l:file in l:files
        if s:PushFile(l:file, a:force)
            let l:success += 1
        endif
    endfor
    call s:Echo('workspace_push_done', l:success, len(l:files))
endfunction

function! hackmd#WorkspacePull() abort
    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError(s:Msg('workspace_no_markdown'))
        return {'success': 0, 'skipped': 0, 'updated': []}
    endif
    if !s:EnsureLoggedIn()
        return {'success': 0, 'skipped': 0, 'updated': []}
    endif

    let l:success = 0
    let l:skipped = 0
    let l:updated = []
    for l:file in l:files
        if empty(s:GetFileProperty(l:file, 'hackmd_id'))
            let l:skipped += 1
            continue
        endif
        let l:result = s:PullFileResult(l:file)
        if l:result.ok
            let l:success += 1
            if l:result.updated
                call add(l:updated, l:result.file)
            endif
        endif
    endfor
    call s:Echo('workspace_pull_done', l:success, len(l:files), l:skipped, len(l:updated))
    if !empty(l:updated)
        call s:Echo('updated_files')
        for l:file in l:updated
            echom '  ' . l:file
        endfor
    endif
    return {'success': l:success, 'skipped': l:skipped, 'updated': l:updated}
endfunction

function! hackmd#WorkspaceDelete(force) abort
    if !a:force
        call s:EchoError(s:Msg('workspace_delete_bang_required'))
        return
    endif

    let l:files = s:WorkspaceFiles()
    if empty(l:files)
        call s:EchoError(s:Msg('workspace_no_markdown'))
        return
    endif
    if !s:EnsureLoggedIn()
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
    call s:Echo('workspace_delete_done', l:success, len(l:files), l:skipped)
endfunction

function! hackmd#WorkspaceImport() abort
    if !s:EnsureLoggedIn()
        return
    endif
    call s:ImportWorkspaceNotes()
endfunction

function! hackmd#WorkspaceList() abort
    if !s:EnsureLoggedIn()
        return []
    endif
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

    call s:Echo('workspace_info_title')
    call s:Echo('workspace_info_config', empty(l:config_path) ? s:Msg('workspace_info_none_fallback') : fnamemodify(l:config_path, ':p'))
    call s:Echo('workspace_info_root', l:root)
    call s:Echo('workspace_info_notes_dir', l:notes_dir)
    call s:Echo('workspace_info_scan_dir', l:base)
    call s:Echo('workspace_info_team', empty(l:team) ? s:Msg('workspace_info_none') : l:team)
    call s:Echo('workspace_info_markdown_files', len(l:files))
endfunction
