# hackmd-vim

[English](README.md) | [中文](README.zh.md)

## Overview

`hackmd-vim` is a Vim plugin for editing Markdown locally and syncing notes to HackMD through `hackmd-cli`.

The plugin stores sync metadata in YAML front matter:

```markdown
---
hackmd_id: your-note-id
hackmd_remote_hash: last-synced-content-hash
team: your-team-path
---

# Note title
```

- `hackmd_id`: the remote HackMD note ID
- `hackmd_remote_hash`: the last synced remote content hash
- `team`: optional HackMD team path

## Requirements

- Vim with `+eval`
- `hackmd-cli` installed
- `hackmd-cli` already authenticated

Check your login state:

```sh
hackmd-cli whoami
```

Log in if needed:

```sh
hackmd-cli login
```

If you normally use a shell alias such as `hack` for `hackmd-cli`, note that Vim's `system()` does not reliably load interactive shell aliases. The default and recommended setup is to call `hackmd-cli` directly.

## Installation

Install it as a Vim package:

```sh
mkdir -p ~/.vim/pack/plugins/start
ln -s /Users/teiyou/dev/hackmd-vim ~/.vim/pack/plugins/start/hackmd-vim
```

Then restart Vim.

Generate help tags if your plugin manager does not do it automatically:

```vim
:helptags ~/.vim/pack/plugins/start/hackmd-vim/doc
:help hackmd-vim
```

For temporary local development, you can also load it manually:

```vim
:set runtimepath^=/Users/teiyou/dev/hackmd-vim
:filetype plugin on
:set filetype=markdown
:runtime plugin/hackmd.vim
```

## Commands

Commands are available globally. The default mappings are only registered for Markdown buffers.

| Command | Description |
| --- | --- |
| `:HPush` | Save the current file, then create or update the remote note |
| `:HPush!` | Force-push even when the stored remote hash is stale |
| `:HPull` | Pull remote content into the current file using `hackmd_id` |
| `:HDelete` | Delete the remote note bound to the current file, then keep the local file and remove sync metadata |
| `:HDelete!` | Delete the bound remote note without confirmation |
| `:HSync` | Run `:HPush` when there is no `hackmd_id`, otherwise run `:HPull` |
| `:HWorkspaceInit [team]` | Create `.hackmd-vim.json` in the current directory |
| `:HWorkspaceUse {team}` | Set the current workspace team, creating `.hackmd-vim.json` if needed |
| `:HWorkspacePush` | Push all Markdown files under the workspace |
| `:HWorkspacePush!` | Force-push all workspace Markdown files |
| `:HWorkspacePull` | Pull all workspace files that already have `hackmd_id` |
| `:HWorkspaceDelete!` | Delete remote notes for all workspace files that have `hackmd_id` |
| `:HWorkspaceImport` | List remote notes, create missing local files, then pull note content |
| `:HWorkspaceList` | List HackMD workspaces/teams joined by the authenticated account |
| `:HWorkspaceInfo` | Show the workspace config, root, scan directory, team, and Markdown file count |

Default mappings:

| Mapping | Command |
| --- | --- |
| `<leader>hp` | `:HPush` |
| `<leader>hl` | `:HPull` |
| `<leader>hs` | `:HSync` |

## Workspace

A workspace is any directory containing `.hackmd-vim.json`. The plugin searches upward from the current file location to find it.
When the current buffer has no file, such as on a startify screen, workspace commands search upward from Vim's current working directory.

Example:

```json
{
  "team": "your-team-path",
  "notes_dir": "."
}
```

- `team`: default HackMD team path
- `notes_dir`: directory to scan for Markdown files, relative to the workspace root

Initialize one from Vim:

```vim
:HWorkspaceInit your-team-path
```

If no `.hackmd-vim.json` exists, workspace commands fall back to `g:hackmd_workspace_root`, then to the current working directory.

## Configuration

Default CLI:

```vim
let g:hackmd_cli = 'hackmd-cli'
```

Use a different executable or absolute path if needed:

```vim
let g:hackmd_cli = '/path/to/hackmd-cli'
```

If you want to reuse a shell alias:

```vim
let g:hackmd_cli = 'hack'
let g:hackmd_use_shell_aliases = 1
let g:hackmd_alias_shell = 'zsh'
```

Default command templates:

```vim
let g:hackmd_command_templates = {
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
```

Available placeholders:

- `{cli}`
- `{file}`
- `{note_id}`
- `{team}`
- `{content}`

All placeholder values are shell-escaped.

`:HWorkspaceList` expects JSON output from `workspace_list`. If your installed `hackmd-cli` uses a different command to list joined teams/workspaces, override that template.

## Typical workflow

### 1. Create and push a team note

Create a local file such as `test.md`:

```markdown
---
team: your-team-path
---

# Vim HackMD Test

This note was created from vim.
```

Run:

```vim
:HPush
```

The first push creates a remote note and writes `hackmd_id` and `hackmd_remote_hash` back into the local file.

### 2. Update a remote note

Edit the local file and run:

```vim
:HPush
```

Normal `:HPush` checks the stored `hackmd_remote_hash` against the current remote content to avoid accidental overwrites.

Use force only when you intentionally want to replace the remote content:

```vim
:HPush!
```

### 3. Pull remote content

If the note was edited on the HackMD web UI or elsewhere, run:

```vim
:HPull
```

The plugin pulls the remote body into the local file and updates `hackmd_remote_hash`.

### 4. Import a whole workspace

To mirror a team workspace locally:

```vim
:HWorkspaceInit your-team-path
:HWorkspaceInfo
:HWorkspaceImport
```

To switch the remote team workspace later:

```vim
:HWorkspaceUse another-team-path
:HWorkspaceInfo
```

`HWorkspaceImport` will:

- call `hackmd-cli notes --output=json` or `hackmd-cli team-notes --teamPath=... --output=json`
- match remote notes with local files by note ID
- create missing local Markdown files
- pull each note into the workspace

### 5. Batch push or pull

```vim
:HWorkspacePush
:HWorkspacePull
```

## Sync behavior

Only note body content is sent to HackMD. The following fields remain local and are stripped before upload:

- `hackmd_id`
- `hackmd_remote_hash`
- `team`

## Conflict protection

After each successful push or pull, the plugin updates `hackmd_remote_hash`.

Normal `:HPush` first exports the current remote note and compares content hashes:

- match: push is allowed
- mismatch: push stops to avoid overwriting remote content

Use force only when you mean to overwrite the remote note:

```vim
:HPush!
:HWorkspacePush!
```

## Limitations

- Commands are synchronous and will block Vim while the CLI is running
- `:HPull` overwrites the local file, but only after checking that the current buffer has no unsaved changes
- Remote updates currently pass content through `--content`; very large notes may be better handled by a future stdin or temp-file adapter
- Batch deletion requires `:HWorkspaceDelete!` to avoid accidental remote note deletion

## Tests

Run the offline test suite:

```sh
vim --clean --not-a-term -Nu NONE -n -es -S test/run.vim
```

The tests use `test/fake-hackmd-cli` and do not require real HackMD credentials.
