# hackmd-vim

[中文](README.zh.md) | [English](README.md)

## 简介

`hackmd-vim` 是一个 Vim 插件，用来在本地编辑 Markdown 文件，并通过 `hackmd-cli` 与 HackMD 同步。

插件会在本地文件的 YAML front matter 中保存同步元数据：

```markdown
---
hackmd_id: your-note-id
hackmd_remote_hash: last-synced-content-hash
team: your-team-path
---

# Note title
```

- `hackmd_id`：远端 HackMD note 的 ID
- `hackmd_remote_hash`：最近一次成功同步时的远端内容哈希
- `team`：可选，指定共享工作区的 team path

## 依赖

- 支持 `+eval` 的 Vim
- 已安装 `hackmd-cli`
- `hackmd-cli` 已完成登录认证

先确认 CLI 可用：

```sh
hackmd-cli whoami
```

如果还没登录：

```sh
hackmd-cli login
```

如果你平时用的是 shell alias `hack` 指向 `hackmd-cli`，要注意 Vim 的 `system()` 默认不一定会读取交互式 shell alias。插件默认直接调用真实命令 `hackmd-cli`，这是推荐配置。

## 安装

最简单的方式是把仓库放进 Vim package 目录：

```sh
mkdir -p ~/.vim/pack/plugins/start
ln -s /Users/teiyou/dev/hackmd-vim ~/.vim/pack/plugins/start/hackmd-vim
```

然后重新打开 Vim。

如果你的插件管理器没有自动生成 help tags，可以手动执行：

```vim
:helptags ~/.vim/pack/plugins/start/hackmd-vim/doc
:help hackmd-vim
```

## 命令

这些命令只会在 `markdown` buffer 中注册。

| 命令 | 作用 |
| --- | --- |
| `:HPush` | 保存当前文件，然后创建或更新远端 note |
| `:HPush!` | 强制覆盖远端 note，即使本地保存的远端 hash 已经过期 |
| `:HPull` | 根据 `hackmd_id` 拉取远端内容覆盖当前文件 |
| `:HDelete` | 删除当前文件绑定的远端 note，成功后保留本地文件并移除绑定元数据 |
| `:HDelete!` | 跳过确认，直接删除当前文件绑定的远端 note |
| `:HSync` | 没有 `hackmd_id` 时执行 `:HPush`，已有 `hackmd_id` 时执行 `:HPull` |
| `:HWorkspaceInit [team]` | 在当前目录创建 `.hackmd-vim.json` |
| `:HWorkspaceUse {team}` | 设置当前 workspace 的 team，必要时自动创建 `.hackmd-vim.json` |
| `:HWorkspacePush` | 批量推送 workspace 下的所有 Markdown 文件 |
| `:HWorkspacePush!` | 强制批量覆盖远端 |
| `:HWorkspacePull` | 批量拉取 workspace 下所有带 `hackmd_id` 的文件 |
| `:HWorkspaceDelete!` | 批量删除 workspace 下所有带 `hackmd_id` 的远端 note |
| `:HWorkspaceImport` | 列出远端 notes，为缺失文件创建本地 `.md`，然后拉取内容 |
| `:HWorkspaceList` | 列出当前账号已加入的 HackMD workspace/team |
| `:HWorkspaceInfo` | 显示当前 workspace 配置文件、根目录、扫描目录、team 和 Markdown 文件数量 |

默认快捷键：

| 快捷键 | 命令 |
| --- | --- |
| `<leader>hp` | `:HPush` |
| `<leader>hl` | `:HPull` |
| `<leader>hs` | `:HSync` |

## Workspace

workspace 是一个包含 `.hackmd-vim.json` 的目录。插件会从当前文件目录向上查找这个配置文件。
如果当前 buffer 没有关联文件，例如在 startify 页面，workspace 命令会从 Vim 的当前工作目录向上查找。

示例：

```json
{
  "team": "your-team-path",
  "notes_dir": "."
}
```

- `team`：默认使用的 HackMD team path
- `notes_dir`：workspace 中用于扫描 Markdown 文件的目录，路径相对 workspace 根目录

可以在 Vim 中直接初始化：

```vim
:HWorkspaceInit your-team-path
```

如果没有 `.hackmd-vim.json`，workspace 命令会回退到 `g:hackmd_workspace_root`，再回退到当前工作目录。

## 配置

默认 CLI：

```vim
let g:hackmd_cli = 'hackmd-cli'
```

如果可执行文件路径不同：

```vim
let g:hackmd_cli = '/path/to/hackmd-cli'
```

如果你坚持复用 shell alias `hack`：

```vim
let g:hackmd_cli = 'hack'
let g:hackmd_use_shell_aliases = 1
let g:hackmd_alias_shell = 'zsh'
```

默认命令模板如下：

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

可用占位符：

- `{cli}`
- `{file}`
- `{note_id}`
- `{team}`
- `{content}`

所有占位符值都会经过 shell escaping。

`:HWorkspaceList` 依赖 `workspace_list` 输出 JSON。如果你安装的 `hackmd-cli` 使用不同命令列出已加入的 team/workspace，可以覆盖这个模板。

## 使用流程

### 1. 新建并推送一篇共享工作区 note

先创建本地文件，例如 `test.md`：

```markdown
---
team: your-team-path
---

# Vim HackMD Test

This note was created from vim.
```

在 Vim 中执行：

```vim
:HPush
```

第一次 push 会在 HackMD 上创建 note，并自动把 `hackmd_id` 和 `hackmd_remote_hash` 写回本地文件。

### 2. 更新远端 note

修改本地内容后执行：

```vim
:HPush
```

普通 `:HPush` 会先比较本地保存的 `hackmd_remote_hash` 和当前远端内容，防止无意覆盖别人刚改过的内容。

明确要覆盖远端时：

```vim
:HPush!
```

### 3. 拉取远端内容

在 HackMD 网页或其他客户端改过内容后，可以执行：

```vim
:HPull
```

插件会拉取远端正文，覆盖本地文件，并更新 `hackmd_remote_hash`。

### 4. 导入整个 workspace

如果你想把某个 team workspace 的 notes 拉到本地：

```vim
:HWorkspaceInit your-team-path
:HWorkspaceInfo
:HWorkspaceImport
```

之后想切换远端 team workspace：

```vim
:HWorkspaceUse another-team-path
:HWorkspaceInfo
```

`HWorkspaceImport` 会：

- 调用 `hackmd-cli notes --output=json` 或 `hackmd-cli team-notes --teamPath=... --output=json`
- 根据远端列表匹配本地已有文件
- 对缺失文件自动创建本地 Markdown 文件
- 对每个 note 执行拉取

### 5. 批量 push / pull

```vim
:HWorkspacePush
:HWorkspacePull
```

## 同步行为

插件只会把正文同步到 HackMD，不会把以下本地元数据上传到远端：

- `hackmd_id`
- `hackmd_remote_hash`
- `team`

这些字段只保留在本地 front matter 中。

## 冲突保护

每次成功 push 或 pull 后，插件都会更新 `hackmd_remote_hash`。

普通 `:HPush` 会先 `export` 当前远端 note，再比较内容 hash：

- 一致：允许 push
- 不一致：停止 push，避免覆盖远端内容

确定要覆盖时才使用：

```vim
:HPush!
:HWorkspacePush!
```

## 限制

- 命令是同步执行的，网络慢时 Vim 会阻塞
- `:HPull` 会覆盖本地文件，但会先检查当前 buffer 是否有未保存修改
- 更新远端时目前通过 `--content` 传正文，超大笔记后续更适合做成 stdin 或临时文件适配
- 批量删除必须使用 `:HWorkspaceDelete!`，避免误删远端 note

## 测试

离线测试命令：

```sh
vim --clean --not-a-term -Nu NONE -n -es -S test/run.vim
```

测试使用 `test/fake-hackmd-cli`，不需要真实 HackMD 凭证。
