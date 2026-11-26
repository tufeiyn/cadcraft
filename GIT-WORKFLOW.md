# 本仓库的 git 用法（本地补充，不随上游提交）

这个目录在 2026-11-26 之前没有任何版本历史，现在建了仓库：

- `main`：导入时的 0.21.0 工作树（已含当天四项修复），tag `import-0.21.0-2026-11-26`。
- `fix/fullscreen-bg`：日常工作的分支，携带 `fixes/2026-11-26/` 下的修复快照、`FIXES.md`、`apply-fixes.ps1`。
- `fixes/` 与本文档都只属于本地，若将来向 `storytold/cadcraft` 提 PR，不要带上它们。

## 上游更新后怎么跟

导入时没有上游源码的干净基线（本地树在导入前就已经改过），所以第一次接上游要手工对一次：

```powershell
git remote add upstream <上游仓库地址>
git fetch upstream
# 用上游版本建一个参考分支，与本地版本比对
git switch -c upstream-base upstream/main
git diff main -- crates/ui-egui/src apps/cadcraft/src/main.rs
```

比对重点就是 `fixes/2026-11-26/FIXES.md` 里那四个锚点：全屏命令与状态请求、背景互切、Esc 守卫、
`workspace_ui()`。上游没动过这些位置时，直接把 `fixes/2026-11-26/files/` 覆盖回去最快；
动过时按锚点手工合并，再跑 `pwsh fixes/2026-11-26/apply-fixes.ps1 -Check` 确认 6 个文件都已落地。

一旦 `main` 变成真正的上游版本（`git reset --hard upstream/main` 之类），后续更新就只是：

```powershell
git fetch upstream
git rebase upstream/main        # fix/fullscreen-bg 上的提交逐个重放
```

之后每天的改动都提交在 `fix/fullscreen-bg` 上，冲突只可能出现在那几个锚点附近。

## 常用检查

```powershell
git status --short
git log --oneline --graph --decorate -5
pwsh fixes/2026-11-26/apply-fixes.ps1 -Check
```
