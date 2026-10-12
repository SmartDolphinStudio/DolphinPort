# Audit remediation record

Original audit: 2026-10-12. This record maps the original finding IDs to changes in the new maintenance baseline. Historical facts retain their provenance limitations; code changes do not retrospectively authenticate old dates or commit titles.

## Repository policy

The maintained branch uses the `Verify` CI check. Branch policy requires PRs, zero additional approvals for the single maintainer, resolved conversations and a current passing CI check, and rejects force pushes/deletion. Remote enforcement and exact new commit/CI IDs are verified after the audit push and recorded in the delivered cross-repository report. Security scan language scope is in `docs/SECURITY_SCAN_SCOPE.md`.

## GIT-001 — 六个默认分支均无保护规则或仓库 ruleset

Original evidence: GitHub branches API 对六个默认分支返回 protected=false；rulesets API 均返回空数组。分支保护 API 的 404 与这两个成功响应交叉印证。

Changes: Remote branch rules described above are enabled after the successful audit CI run.

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## GIT-002 — 远端没有验证项目代码的自定义 CI 工作流

Original evidence: 六个默认分支均没有已跟踪的 .github/workflows 文件。DolphinPort Actions 中的动态 Dependabot Updates 不构成 Flutter/Rust/Android 构建验证；其余仓库 workflows 列表为空。DolphinPort 本地有被忽略的工作流，详见 DP-GIT-002。

Changes: 六仓库提交固定action SHA/Node/npm/pnpm/Go/Rust/Flutter/Foundry版本的可运行CI; CI包含构建、安全回归、官方依赖审计和Android APK原生payload检查

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## GIT-003 — 安全告警 API 存在权限或功能缺口，不能以“无告警”判定安全

Original evidence: 六个仓库 Dependabot alerts 查询均失败，响应包含功能未启用和权限要求；多个 code-scanning/secret-scanning 查询返回 403/404。evm-patterns、MiniEVM 的 secret-scanning 查询成功且返回空列表，code-scanning 返回 no analysis found。逐接口状态在各项目远端表中完整列出。

Changes: 使用各仓库实际owner凭据消除安全告警读取权限缺口，启用Dependabot/secret scanning/push protection; 提交固定SHA CodeQL Actions/JS/Go/Rust扫描，明确Solidity/Dart不在CodeQL覆盖范围，区分404未配置与200无告警

Source references: workflow/configuration and history documents.

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DEP-ENV-001 — 默认 npm 镜像不支持本次 audit 接口

Original evidence: 初次 npm audit 使用本机 registry.npmmirror.com，返回 404 Not Found / NOT_IMPLEMENTED。切换官方 registry.npmjs.org 后得到实际漏洞结果。该配置属于本机环境，不是六个项目均写入了此设置。

Changes: npm用户默认registry改官方npmjs，六仓库提交.npmrc并由CI显式审计; 移除冲突用户级GOROOT，默认go1.25.12与机器GOROOT一致；服务CI和本地验证显式使用Go1.26.5

Source references: workflow/configuration and history documents.

Validation: 默认go version/ go env GOROOT一致; npm config get registry=https://registry.npmjs.org/

## ENV-GO-001 — 默认 Go 可执行文件与 GOROOT 不匹配

Original evidence: 默认 go 是 1.25.12，但本机 GOROOT 指向 1.26.5，导致标准库 compile: version mismatch。改用 1.25.12 的目录后又出现标准库源码缺失。使用 C:\Dev\Go\1.26.5\bin\go.exe 并匹配 GOROOT 后，HerbTable API 和 UI captcha 后端 go vet 成功，HerbTable captcha 的未使用 import 被明确检出。

Changes: npm用户默认registry改官方npmjs，六仓库提交.npmrc并由CI显式审计; 移除冲突用户级GOROOT，默认go1.25.12与机器GOROOT一致；服务CI和本地验证显式使用Go1.26.5

Source references: workflow/configuration and history documents.

Validation: 默认go version/ go env GOROOT一致; npm config get registry=https://registry.npmjs.org/

## DP-GIT-001 — main、master 没有共同祖先，发布 tag 位于另一条历史

Original evidence: 远端 main 和 v1.0.16 指向 1cb979363407198b877cc13a98d816ad459d67bb，master 指向本地 HEAD e9e3f76c530ca0208771c1a72d1744a5a6f9fd62。mirror 中 git merge-base main master 退出 1、无共同祖先。两棵最终源码树只在 Android SDK 版本和 Gradle 下载地址等配置上有少量差异，但提交身份和发布基线不同。

Changes: 逐仓库提交历史可信边界/维护与发布基线文档，不改写或美化旧时间戳; Dolphin master唯一维护分支、旧main只读与新tag来源检查；EVM悬空commit建立本地保留ref; 疑点原因仍未知，不伪造迁移说明；未来开发事实以修复commit/CI/产物校验为据

Source references: workflow/configuration and history documents.

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## DP-GIT-002 — 本地 CI/Release 被 .gitignore 忽略，且 CI 只监听 main

Original evidence: .gitignore:44 忽略整个 .github/workflows/；本地确实存在 ci.yml 和 release.yml，但 git check-ignore 和远端 Git 树确认它们未提交。ci.yml 的 push/pull_request branches 只写 main，而默认分支为 master。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `.gitignore`, `.github/workflows/ci.yml`, `.github/workflows/release.yml`

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## DP-GIT-003 — Dependabot 更新 PR 都基于旧 main 且已关闭未合并

Original evidence: PR #1 更新 rusqlite 0.32.1→0.40.2，PR #2 更新 cupertino_icons 1.0.9→2.0.0，两者均 closed、merged_at=null、base.ref=main。Actions 的 github_actions 更新运行失败，当前远端没有自定义 workflow。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `.github/dependabot.yml`

Validation: original Git object/metadata evidence is preserved; see HISTORY_PROVENANCE.md.

## DP-BUILD-001 — Android 标准构建没有生成和打包 Rust 原生库的步骤

Original evidence: Rust Android 构建依赖独立脚本，jniLibs 被忽略；Gradle 未配置执行 Rust 构建的 task，本地被忽略的 Flutter CI/Release 也只运行 flutter build apk。Dart 加载失败时静默关闭 native core。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `rust/build_android.sh`, `android/app/build.gradle`, `lib/services/native_core.dart`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-BUILD-002 — 交叉编译脚本硬编码机器路径且工具未锁定

Original evidence: 脚本直接使用 /home/user/flutter_dev/android-sdk 和固定 NDK 目录，cargo ndk 的版本及 Rust toolchain 未在仓库固定，cargo build 命令未使用 --locked。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `rust/build_android.sh`, `rust/build_android.sh`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-BUILD-003 — Gradle wrapper 使用第三方镜像且没有 distributionSha256Sum

Original evidence: master 的 distributionUrl 指向 mirrors.cloud.tencent.com 的 Gradle 9.3.1 分发；wrapper properties 没有 distributionSha256Sum。remote main 对应地址不同。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `android/gradle/wrapper/gradle-wrapper.properties`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-BUILD-004 — 正式 release 构建会在缺少签名材料时回退 debug 签名

Original evidence: Gradle 的 release signingConfig 在 key.properties 缺失时使用 debug。被忽略的 release workflow 写入 secrets 但未显式验证全部必需项非空。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `android/app/build.gradle`, `.github/workflows/release.yml`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-DOC-001 — Flutter/Dart/Android SDK 版本说明彼此矛盾

Original evidence: README、BUILD 文档和 master 的 compileSdk/targetSdk 使用不同版本说明，README 的 Android SDK 37 与 master 的 36 不一致；remote main 又采用 37。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `README.md`, `docs/BUILD_AND_RELEASE.md`, `android/app/build.gradle`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-001 — 卡片验证空密码也会成功

Original evidence: 确认按钮无条件 Navigator.pop(..., true)，没有检查 TextEditingController 内容；输入为空也返回验证成功。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `lib/widgets/card_verify_dialog.dart`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-002 — 同步 FFI 和数据库操作在 Dart UI isolate 上执行，加载错误被隐藏

Original evidence: Dart 直接同步调用 dp_call，Rust 内部执行 SQLite 并持有数据库 mutex。加载失败 catch 后返回 disabled，登录记录调用方没有向用户报告失败。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `lib/services/native_core.dart`, `lib/services/native_store.dart`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-003 — panic=unwind 并不能自动阻止 extern C panic 终止进程

Original evidence: release profile 注释宣称 panic 可被 FFI 层包含，但 unsafe extern "C" dp_call 没有 catch_unwind。unwind 穿过普通 C ABI 边界会触发 abort。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `rust/Cargo.toml`, `rust/core/src/ffi.rs`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-004 — 登录标识符明文进入 SQLite，备份和删除策略未明确

Original evidence: 记录和用户数据含用户自行输入的邮箱/手机号等标识符，SQLite 没有应用层加密。Android manifest 未显式配置数据备份排除规则，也没有明确记录保留/清除策略。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `rust/core/src/db.rs`, `android/app/src/main/AndroidManifest.xml`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-005 — 登录记录查询允许无界 limit，用户列表也没有分页

Original evidence: 查询 limit 直接接受传入 i64，SQLite 的负数 LIMIT 可返回全部结果；用户列表没有分页上限。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `rust/core/src/db.rs`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-006 — Dart 解引用 FFI 返回指针前未检查 nullptr

Original evidence: Rust into_c_string 以null作为失败fallback；Dart直接responsePointer.toDartString。当前serde_json会转义字符串中的NUL，因此正常RPC没有找到可实际生成null的输入。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `lib/services/native_core.dart`, `rust/core/src/ffi.rs`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.

## DP-CODE-007 — 扫码新增交易会改变流水总额，但图表仍使用固定数组

Original evidence: addTransaction直接插入MockData.transactions；totalIncome/totalExpense按该列表求和，但monthlySeries、expenseSlices和ranking直接返回static const数组。

Changes: Gradle集成cargo-ndk原生打包、固定工具与SDK、官方Gradle分发校验、缺release签名失败; 工作流纳入Git/维护分支master/Dependabot策略及升级决定记录; 后台Dart isolate和可见存储错误，nullptr检查，FFI catch_unwind; 登录标识去个人信息、关闭Android备份/提供删除，查询上限/游标; 卡片非空演示校验、同一流水聚合图表和排名

Source references: `lib/data/repositories/wallet_repository.dart`, `lib/data/repositories/wallet_repository.dart`, `lib/models/mock_data.dart`

Validation: applicable local builds/regression checks completed before committing; the committed Audit CI reproduces the build and tests on GitHub. Exact results are in the cross-repository delivery report.
