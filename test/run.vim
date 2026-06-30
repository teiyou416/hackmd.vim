set nocompatible
set nomore

let s:repo = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
let s:root = '/private/tmp/hackmd-vim-tests'
let s:remote = s:root . '/remote'
let s:workspace = s:root . '/workspace'

call delete(s:root, 'rf')
call mkdir(s:remote, 'p')
call mkdir(s:workspace, 'p')

let $HACKMD_FAKE_DIR = s:remote
let g:hackmd_cli = s:repo . '/test/fake-hackmd-cli'

execute 'source' fnameescape(s:repo . '/autoload/hackmd.vim')
execute 'source' fnameescape(s:repo . '/plugin/hackmd.vim')

function! s:Fail(message) abort
    throw a:message
endfunction

function! s:AssertEqual(expected, actual, message) abort
    if a:expected !=# a:actual
        call s:Fail(a:message . ' expected=' . string(a:expected) . ' actual=' . string(a:actual))
    endif
endfunction

function! s:AssertMatch(pattern, actual, message) abort
    if a:actual !~# a:pattern
        call s:Fail(a:message . ' pattern=' . string(a:pattern) . ' actual=' . string(a:actual))
    endif
endfunction

function! s:Read(path) abort
    return join(readfile(a:path), "\n")
endfunction

execute 'cd' fnameescape(s:workspace)
call hackmd#WorkspaceInit('')
call hackmd#WorkspaceUse('test-team')
call s:AssertMatch('"team":"test-team"', s:Read(s:workspace . '/.hackmd-vim.json'), 'workspace use should update team')
call hackmd#WorkspaceInfo()
enew
setlocal buftype=nofile
setlocal filetype=startify
call s:AssertEqual(2, exists(':HWorkspaceInfo'), 'workspace commands should be available outside markdown buffers')
call s:AssertEqual(2, exists(':HPush'), 'buffer commands should be available outside markdown buffers')
call s:AssertEqual(2, exists(':HLogin'), 'login command should be available outside markdown buffers')
call s:AssertEqual(2, exists(':HLogout'), 'logout command should be available outside markdown buffers')
call hackmd#WorkspaceInfo()
setlocal buftype=

call s:AssertEqual(1, hackmd#Login('test-api-token'), 'login should succeed with an API token')
call s:AssertEqual('test-api-token', s:Read(s:remote . '/.api-token'), 'login should pass the API token to hackmd-cli')
call s:AssertEqual(1, hackmd#Logout(), 'logout should succeed')
call s:AssertEqual(0, filereadable(s:remote . '/.api-token'), 'logout should remove the fake API token')

let s:workspaces = hackmd#WorkspaceList()
call s:AssertEqual(2, len(s:workspaces), 'workspace list should parse joined teams')
call s:AssertEqual('test-team', s:workspaces[0].path, 'workspace list should include team path')
call s:AssertEqual('Test Team', s:workspaces[0].name, 'workspace list should include team name')

" Push creates a remote note, strips plugin front matter, and writes metadata.
let s:note = s:workspace . '/local.md'
call writefile(['# Local title', '', 'body'], s:note)
execute 'edit' fnameescape(s:note)
call hackmd#BufferPush(0)
let s:local = s:Read(s:note)
call s:AssertMatch('hackmd_id: note1', s:local, 'push should write note id')
call s:AssertMatch('hackmd_remote_hash:', s:local, 'push should write remote hash')
call s:AssertEqual("# Local title\n\nbody", s:Read(s:remote . '/note1.md'), 'remote content should not contain plugin front matter')

" Pull refreshes local content and preserves metadata.
call writefile(['# Remote title', '', 'remote body'], s:remote . '/note1.md')
call hackmd#BufferPull()
let s:pulled = s:Read(s:note)
call s:AssertMatch('hackmd_id: note1', s:pulled, 'pull should preserve note id')
call s:AssertMatch('# Remote title', s:pulled, 'pull should write remote content')

" Normal push refuses to overwrite a changed remote note.
silent %delete _
call setline(1, ['---', 'hackmd_id: note1', 'hackmd_remote_hash: ' . matchstr(s:pulled, 'hackmd_remote_hash: \zs\S\+'), '---', '# Local edit'])
write
call writefile(['# Concurrent remote edit'], s:remote . '/note1.md')
call hackmd#BufferPush(0)
call s:AssertEqual('# Concurrent remote edit', s:Read(s:remote . '/note1.md'), 'conflict should keep remote content')

" Forced push overwrites remote content.
call hackmd#BufferPush(1)
call s:AssertEqual('# Local edit', s:Read(s:remote . '/note1.md'), 'forced push should overwrite remote content')

" Workspace import creates missing local files from the remote list.
call writefile(['# Imported note', '', 'imported body'], s:remote . '/note2.md')
call hackmd#WorkspaceImport()
let s:imported = glob(s:workspace . '/imported-note*.md', 0, 1)
call s:AssertEqual(1, len(s:imported), 'workspace import should create a missing note file')
call s:AssertMatch('hackmd_id: note2', s:Read(s:imported[0]), 'imported note should have note id')
call s:AssertMatch('# Imported note', s:Read(s:imported[0]), 'imported note should contain remote content')

" Workspace pull reports only files whose local content changed.
call writefile(['# Workspace remote update', '', 'changed by remote'], s:remote . '/note1.md')
let s:pull_result = hackmd#WorkspacePull()
call s:AssertEqual(2, s:pull_result.success, 'workspace pull should pull bound files')
call s:AssertEqual(1, len(s:pull_result.updated), 'workspace pull should report one changed local file')
call s:AssertEqual(fnamemodify(s:note, ':p'), s:pull_result.updated[0], 'workspace pull should report the changed file')
call s:AssertMatch('# Workspace remote update', s:Read(s:note), 'workspace pull should update changed local file')

" Delete removes the remote note and unbinds the local file.
let s:delete_note = s:workspace . '/delete-me.md'
call writefile(['# Delete me'], s:delete_note)
execute 'edit' fnameescape(s:delete_note)
call hackmd#BufferPush(0)
call s:AssertEqual(1, filereadable(s:remote . '/note3.md'), 'delete test should create a remote note')
call hackmd#BufferDelete(1)
call s:AssertEqual(0, filereadable(s:remote . '/note3.md'), 'delete should remove the remote note')
call s:AssertEqual('', hackmd#GetFrontMatterProperty('hackmd_id'), 'delete should remove local note id')

qa
