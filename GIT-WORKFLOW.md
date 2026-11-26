# 本仓库的 git 用法（本地补充，不随上游提交）

这个目录在 2026-11-26 之前没有任何版本历史，现在建了仓库：

- `main`：导入时的 0.21.0 工作树（已含当天四项修复），tag `import-0.21.0-2026-11-26`。
- `fix/fullscreen-bg`：日常工作的分支，携带 `fixes/2026-11-26/` 下的修复快照、`FIXES.md`、`apply-fixes.ps1`。
- `fixes/` 与本文档都只属于本地；若将来向 `storytold/cadcraft` 提 PR，不要带上它们。

## 远端

- `origin` → `https://github.com/tufeiyn/cadcraft`。已推送 `fix/fullscreen-bg` 与 tag
  `import-0.21.0-2026-11-26`，**没有动它的 `main`**（远端 `main` 仍是 `12eef227`）。
- `backup` → 本机裸仓库 `..\cadcraft-fix.git`，同样有全部分支和 tag，断网时的兜底。

注意：`fix/fullscreen-bg` 的历史与本仓库 `main` 没有共同祖先（导入时本地树已带修复），所以
GitHub 上它相对 `main` 的 PR 页面没法审，只能当备份和产物用。

## 本地树与上游的关系（2026-11-26 实测）

- 本地导入树和远端 `main`（`12eef227`，2026-11-26）差 **212 个文件**；逐段回溯后最接近的上游
  提交是 `c048120a`（2026-11-24），仍差 109 个文件。也就是说本地这份是较旧的快照，不是上游主干。
- 六个改动文件里，上游自那以后改得最多的是 `crates/ui-egui/src/cmdline.rs`（+382/-…），
  `menus.rs` +73、`lib.rs` +65、`apps/cadcraft/src/main.rs` 94 行变动，`i18n/zh.tsv` 多了 4 行。
  因此**把四项功能原样 rebase 到远端 `main` 一定会冲突**，需要按锚点重落一遍（见 FIXES.md）。

## 上游更新后怎么跟

```powershell
git fetch origin
git diff origin/main -- crates/ui-egui/src apps/cadcraft/src/main.rs   # 看漂移
pwsh fixes/2026-11-26/apply-fixes.ps1 -Apply                           # 上游未动这些位置时的最快路径
```

上游动过这些位置时，按 `fixes/2026-11-26/FIXES.md` 的锚点表手工合并，再 `-Check` 确认 6 个文件都落地。

真正把工作转到上游主干上（建议尽快做一次，之后就不用再手工对）：

```powershell
git switch -c port/on-upstream origin/main
git checkout import-0.21.0-2026-11-26 -- crates/ui-egui/src/menus.rs crates/ui-egui/src/context_menu.rs `
    crates/ui-egui/src/lib.rs crates/ui-egui/src/cmdline.rs crates/ui-egui/src/i18n/zh.tsv apps/cadcraft/src/main.rs
pwsh fixes/2026-11-26/apply-fixes.ps1 -Apply    # 以快照为准覆盖 6 个文件
# 按 FIXES.md 锚点手工收敛 cmdline.rs / main.rs 等冲突，然后重编、重测
git commit -m "fix: full screen, background toggle, Esc leaves full screen"
```

之后这条分支上的日常提交就能直接 `git rebase origin/main`，冲突只会落在四个锚点附近。

## 常用检查

```powershell
git status --short
git log --oneline --graph --decorate -5
pwsh fixes/2026-11-26/apply-fixes.ps1 -Check
```
