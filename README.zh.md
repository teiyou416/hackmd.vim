# hackmd-vim

[中文](README.zh.md) | [English](README.md)

一个 Vim 插件，用来在本地编辑 Markdown，并通过 `hackmd-cli` 同步到 HackMD。

## 依赖

- 支持 `+eval` 的 Vim
- `hackmd-cli`
- 已登录的 `hackmd-cli`，或在 Vim 里用 `:HLogin` 登录

```sh
hackmd-cli whoami
hackmd-cli login
```

也可以在 Vim 中执行 `:HLogin`，然后输入自己的 HackMD API token。
远端命令会先检查当前登录状态；未登录时会提示先执行 `:HLogin`。

## 安装

使用 [vim-plug](https://github.com/junegunn/vim-plug)：

```vim
call plug#begin('~/.vim/plugged')
Plug 'teiyou416/hackmd.vim'
call plug#end()
```

然后执行：

```vim
:PlugInstall
```

之后更新：

```vim
:PlugUpdate hackmd.vim
```

## 快速开始

创建或编辑一个 Markdown 文件：

```markdown
---
team: your-team-path
---

# Note title
```

常用命令：

| 命令 | 作用 |
| --- | --- |
| `:HLogin` | 在 Vim 里用 HackMD API token 登录 `hackmd-cli` |
| `:HLogout` | 在 Vim 里登出 `hackmd-cli` |
| `:HPush` | 创建或更新当前 note |
| `:HPush!` | 强制推送并覆盖远端修改 |
| `:HPull` | 根据 `hackmd_id` 拉取当前 note |
| `:HSync` | 新 note 执行 push，已绑定 note 执行 pull |
| `:HDelete!` | 删除远端 note，并解除本地文件绑定 |
| `:HWorkspaceInit [team]` | 创建 `.hackmd-vim.json` |
| `:HWorkspaceUse {team}` | 设置 workspace team |
| `:HWorkspaceImport` | 导入远端 notes 为本地 Markdown 文件 |
| `:HWorkspaceList` | 列出已加入的 HackMD workspace/team |
| `:HWorkspacePush` | 推送 workspace 下所有 Markdown 文件 |
| `:HWorkspacePull` | 拉取已绑定文件，并列出本地发生变化的文件 |
| `:HWorkspaceDelete!` | 删除 workspace 下已绑定的远端 notes |
| `:HWorkspaceInfo` | 显示 workspace 设置 |

Markdown buffer 默认快捷键：

| 快捷键 | 命令 |
| --- | --- |
| `<leader>hp` | `:HPush` |
| `<leader>hl` | `:HPull` |
| `<leader>hs` | `:HSync` |

## Workspace

workspace 是包含 `.hackmd-vim.json` 的目录：

```json
{
  "team": "your-team-path",
  "notes_dir": "."
}
```

workspace 命令会从当前文件目录向上查找配置。在 startify 这类无文件 buffer 中，会从 Vim 当前工作目录开始查找。

## 配置

默认配置：

```vim
let g:hackmd_cli = 'hackmd-cli'
```

如果命令路径不同：

```vim
let g:hackmd_cli = '/path/to/hackmd-cli'
```

如果你安装的 `hackmd-cli` 子命令不同，只覆盖需要调整的模板：

```vim
let g:hackmd_command_templates = {
      \ 'whoami': '{cli} whoami',
      \ 'workspace_list': '{cli} teams --output=json',
      \ }
```

完整帮助：

```vim
:help hackmd-vim
```
