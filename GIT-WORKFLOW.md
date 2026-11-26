# 本仓库的 git 用法（本地补充，不随上游提交）

2026-11-26 建仓，当天两项工作：先在旧快照上做修复，随后把修复重做到上游主干。

## 分支

- `main`：**上游最新 + 四项修复**。历史是 `origin/main` 的 `12eef227`（2026-11-26）之上一个提交
  `6cd0fb46`，2026-11-26 用 `git reset --hard port/on-upstream` 从旧导入树切过来。
- `port/on-upstream`：移植用的分支，与 `main` 同一个提交。
- `fix/fullscreen-bg`：旧导入树（0.21.0 快照）+ 修复。它保留 `fixes/2026-11-26/`（FIXES.md、快照文件、
  `apply-fixes.ps1`）与旧版实现，历史与 `main` 无共同祖先，只作存档，不要基于它开发。
- tag `import-0.21.0-2026-11-26`：导入时的旧快照。

`fixes/` 和本文档都只属于本地，向上游提 PR 时不要带上。

## 远端

- `origin` → `https://github.com/tufeiyn/cadcraft`。已推送 `fix/fullscreen-bg` 与 tag，**远端 `main`
  未动**（仍 `12eef227`）。`port/on-upstream` 推送时 GitHub 直连 TLS 反复失败（`schannel: failed to
  receive handshake`），尚未上去；网络恢复后 `git push origin port/on-upstream` 即可。
- `backup` → 本机裸仓库 `..\cadcraft-fix.git`，全部分支已推，断网兜底。

GitHub 要 `http.schannelCheckRevoke false` 才能握手（见仓库级配置）。

## 移植后的代码位置（上游主干版）

只动四个文件加一份翻译，没有保存/还原布局状态的代码：

- `crates/ui-egui/src/lib.rs`：`fullscreen` / `fullscreen_request` / `fullscreen_settle` 三个字段，
  `set_fullscreen`，`logic()` 里发 `ViewportCommand::Fullscreen` 并在窗口确认前重发，
  `draw()` 里用 `!self.fullscreen` 跳过标题栏、工具栏、菜单、状态栏、文件标签、工具集条与停靠区，
  全屏时 `CentralPanel` 直接画 `canvas::show`。
- `crates/ui-egui/src/menus.rs`：`ui.toggle.fullscreen`（Cmd+0）、`ui.background.toggle` 两条命令，
  `live_label` 让菜单显示「进入/退出全屏」「白色/黑色背景」，`background_is_white` 读
  `options.model_background`，背景经 `OPTIONS` 的 `modelBackground` 改，Options 对话框与配置文件同步。
- `crates/ui-egui/src/context_menu.rs`：绘图区右键菜单的 `display_entries` 提供同两项。
- `crates/ui-egui/src/cmdline.rs`：`Key::Escape` 守卫分支，仅在全屏且无对话框、无输入、无命令运行时退出全屏。
- `crates/ui-egui/src/canvas.rs`：全屏时浮动命令行默认不画，用户开始输入或有提示时才出现。

`apps/cadcraft/src/main.rs` **不改**（旧版需要保存/恢复布局，新版不需要）。

## 上游更新后怎么跟

```powershell
git fetch origin
git log --oneline -3 origin/main
git rebase origin/main          # 冲突只会落在上面几个锚点
cargo test -p cadcraft-ui-egui --lib   # 见下面的已知问题
```

## 已知构建/测试环境问题（本机，非改动引起）

- `cargo test -p cadcraft-ui-egui --lib` 的测试二进制在本机加载失败（`0xC0000139`
  `STATUS_ENTRYPOINT_NOT_FOUND`）：测试链引入 `comctl32.dll!TaskDialog*`，而 mingw 产出的测试 exe
  没有 comctl32 v6 的 SxS manifest。`apps/cadcraft` 产出的 exe 不导入这两个符号，正常运行。
  验收请用真机 + 控制通道（`cadcraft.exe --sample --control PORT`）。
- `cargo test -p cadcraft-engine --lib`：587 通过 / 1 失败
  （`file_access::tests::a_case_sensitive_windows_folder_can_hold_a_sibling_of_the_root`，
  依赖文件系统大小写策略，属上游既有）。

## 常用检查

```powershell
git status --short
git log --oneline --graph --decorate -5
```
