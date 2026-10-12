# History provenance and verifiable maintenance baseline

Audit baseline before remediation: `e9e3f76c530ca0208771c1a72d1744a5a6f9fd62`. Audit date: 2026-10-12. Maintained branch: `master`.

Git author/committer dates are user-controlled metadata. They do not independently establish when a project was written or first published. Original commits, tags and parent relationships are preserved. The cause of the discrepancies below is unknown; this document does not invent a migration explanation or attribute intent.

## DP-GIT-001 — main、master 没有共同祖先，发布 tag 位于另一条历史

远端 main 和 v1.0.16 指向 1cb979363407198b877cc13a98d816ad459d67bb，master 指向本地 HEAD e9e3f76c530ca0208771c1a72d1744a5a6f9fd62。mirror 中 git merge-base main master 退出 1、无共同祖先。两棵最终源码树只在 Android SDK 版本和 Gradle 下载地址等配置上有少量差异，但提交身份和发布基线不同。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## DP-GIT-002 — 本地 CI/Release 被 .gitignore 忽略，且 CI 只监听 main

.gitignore:44 忽略整个 .github/workflows/；本地确实存在 ci.yml 和 release.yml，但 git check-ignore 和远端 Git 树确认它们未提交。ci.yml 的 push/pull_request branches 只写 main，而默认分支为 master。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## DP-GIT-003 — Dependabot 更新 PR 都基于旧 main 且已关闭未合并

PR #1 更新 rusqlite 0.32.1→0.40.2，PR #2 更新 cupertino_icons 1.0.9→2.0.0，两者均 closed、merged_at=null、base.ref=main。Actions 的 github_actions 更新运行失败，当前远端没有自定义 workflow。

Disposition: current-source errors are fixed in the new audit commit; earlier history is kept as evidence. Dates and titles in these commits must not be quoted as verified development/release events. Future releases identify their exact source commit, tested toolchain and CI run.

## Branch and release policy

`master` is the sole maintenance and CI branch. Unrelated `main` is retained as a read-only historical branch; no claim is made that its old tag is the release source of master. New tag-triggered release checks require the tagged source to be an ancestor of master. Old release assets have not been rebuilt, re-signed or retrospectively authenticated.
