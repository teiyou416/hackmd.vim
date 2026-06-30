# hackmd-vim

[English](README.md) | [中文](README.zh.md)

Vim plugin for editing Markdown locally and syncing notes with HackMD through `hackmd-cli`.

## Requirements

- Vim with `+eval`
- `hackmd-cli`
- an authenticated `hackmd-cli` session, or log in from Vim with `:HLogin`

```sh
hackmd-cli whoami
hackmd-cli login
```

You can also run `:HLogin` in Vim and enter your HackMD API token there.
Remote commands check the current login first and ask you to run `:HLogin` when needed.

## Installation

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
call plug#begin('~/.vim/plugged')
Plug 'teiyou416/hackmd.vim'
call plug#end()
```

Then run:

```vim
:PlugInstall
```

Update later with:

```vim
:PlugUpdate hackmd.vim
```

## Quick Start

Create or edit a Markdown file:

```markdown
---
team: your-team-path
---

# Note title
```

New remote notes use the local Markdown filename, without `.md`, as the HackMD title.

Common commands:

| Command | Description |
| --- | --- |
| `:HLogin` | Log in to `hackmd-cli` from Vim with a HackMD API token |
| `:HLogout` | Log out of `hackmd-cli` from Vim |
| `:HLanguage [en\|zh]` | Show or set the prompt language |
| `:HPush` | Create or update the current note |
| `:HPush!` | Force push and overwrite remote changes |
| `:HPull` | Pull the current note by `hackmd_id` |
| `:HSync` | Push when new, pull when already linked |
| `:HDelete!` | Delete the remote note and unlink the local file |
| `:HWorkspaceInit [team]` | Create `.hackmd-vim.json` |
| `:HWorkspaceUse {team}` | Set the workspace team |
| `:HWorkspaceImport` | Import remote notes into local Markdown files |
| `:HWorkspaceList` | List joined HackMD workspaces/teams |
| `:HWorkspacePush` | Push all workspace Markdown files |
| `:HWorkspacePull` | Pull linked workspace files and list changed local files |
| `:HWorkspaceDelete!` | Delete linked remote notes in the workspace |
| `:HWorkspaceInfo` | Show workspace settings |

Default mappings for Markdown buffers:

| Mapping | Command |
| --- | --- |
| `<leader>hp` | `:HPush` |
| `<leader>hl` | `:HPull` |
| `<leader>hs` | `:HSync` |

## Workspace

A workspace is a directory containing `.hackmd-vim.json`:

```json
{
  "team": "your-team-path",
  "notes_dir": "."
}
```

Workspace commands search upward from the current file. In no-file buffers such as startify, they search from Vim's current working directory.

## Configuration

Defaults:

```vim
let g:hackmd_cli = 'hackmd-cli'
let g:hackmd_language = 'en'
```

Use an absolute path if needed:

```vim
let g:hackmd_cli = '/path/to/hackmd-cli'
```

Prompt messages default to English. Switch to Chinese with:

```vim
:HLanguage zh
```

Or set it in your vimrc:

```vim
let g:hackmd_language = 'zh'
```

If your installed `hackmd-cli` uses different subcommands, override only the command templates you need:

```vim
let g:hackmd_command_templates = {
      \ 'whoami': '{cli} whoami',
      \ 'workspace_list': '{cli} teams --output=json',
      \ }
```

For full help:

```vim
:help hackmd-vim
```
