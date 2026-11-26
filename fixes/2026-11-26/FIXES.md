# 2026-11-26 修复快照（全屏 / 背景色 / Esc）

本目录把 2026-11-26 的四项改动固定在 6 个文件里，供上游更新后快速重新落回。

- 基线：本仓库 `main` 的导入提交（tag `import-0.21.0-2026-11-26`），版本 0.21.0。
- 上游：`storytold/cadcraft`。导入时本地树已包含这些改动、且没有任何版本历史，因此改动以
  `files/` 下的整文件快照 + 本说明来携带，而不是一个能直接 cherry-pick 的源码提交。
- 目录结构：`files/<相对仓库根的路径>`，与工作树完全对应。

## 四项改动

1. **右键菜单「全屏」**：UI 命令 `ui.toggle.fullscreen`（`Enter Full Screen` / `Exit Full Screen`，
   菜单 View，快捷键 `Cmd+0` 即 Ctrl+0）。真全屏＝收走菜单栏、工具栏、文件标签、状态栏、命令行、
   工具集竖条、面板与停靠布局，只剩绘图区；退出时连 `docking::Workspace` 一起还原。
2. **背景色互切**：UI 命令 `ui.background.toggle`，经 `options.modelBackground` 设成 `#ffffff`
   或 `#000000`；菜单项标签随之在 `White Background` / `Black Background` 之间切换，颜色随 profile 持久化。
3. **全屏时 Esc 退出**：Esc 在「全屏 且 无对话框 且 命令行为空 且 无进行中的提示」时退出全屏，
   否则保持原有「清输入 / 取消命令」语义。
4. **全屏中退出程序不丢界面**：`CadApp::workspace_ui()` 在全屏时返回恢复后的布局克隆，
   `apps/cadcraft/src/main.rs` 的 `persist_workspace` 改用它写 profile。

## 冲突时按这些锚点找（上游改过同一文件时手工合并）

| 文件 | 关键字 |
| --- | --- |
| `crates/ui-egui/src/menus.rs` | `ENTER_FULLSCREEN` `EXIT_FULLSCREEN` `FULLSCREEN` `TOGGLE_BACKGROUND` `fn enter_fullscreen` `fn leave_fullscreen` `fullscreen_request` |
| `crates/ui-egui/src/context_menu.rs` | `fn fullscreen_entry` `fn background_entry` |
| `crates/ui-egui/src/lib.rs` | `fullscreen_request` `struct FullscreenLayout` `pub fn workspace_ui` |
| `crates/ui-egui/src/cmdline.rs` | `Key::Escape` 分支里的 `app.fullscreen` 守卫 |
| `crates/ui-egui/src/i18n/zh.tsv` | `Enter Full Screen` `Exit Full Screen` `White Background` `Black Background` |
| `apps/cadcraft/src/main.rs` | `persist_workspace` 里的 `workspace_ui()` |

## 用法

```powershell
# 看当前工作树与快照是否一致（0 = 一致）
pwsh fixes/2026-11-26/apply-fixes.ps1 -Check

# 上游更新后把 6 个文件覆盖回去（覆盖前会先备份到 .bak 同目录）
pwsh fixes/2026-11-26/apply-fixes.ps1 -Apply
```

覆盖后按本机环境重编（仓库路径含中文，target 目录必须放纯英文路径）：

```powershell
$env:CARGO_TARGET_DIR="D:\cadcraft-target"
$env:PATH="D:\mingw64\bin;"+$env:PATH
$env:CC_x86_64_pc_windows_gnu="D:\mingw64\bin\gcc.exe"
cargo build --release -p cadcraft -p cadcraft-cli
```

验证口径：`cargo test -p cadcraft-ui-egui --lib`（当日 389 passed / 1 ignored）、
`cargo fmt --all -- --check`、`cargo xtask layers`；clippy 的 3 处 `hatchdlg.rs` / `grip_dyn.rs`
布尔简化 lint 是改动前就有的，可忽略。
