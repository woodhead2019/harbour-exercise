#!/usr/bin/env bash
#set -e

# 0. 自动 stash 本地未提交改动
git diff-index --quiet HEAD || git stash push -m "auto-stash before sync"

# 1. 更新上游跟踪分支
git checkout upstream-master
git fetch upstream
git merge upstream/master

# 2. 切回 main，仅把上游合到 hwbuilder/ 子目录
git checkout main
git subtree merge --prefix=hwbuilder upstream-master || {
    echo ">>> 冲突，请解决后重新运行"
    exit 1
}

# 3. 推送到 GitHub
git push origin main

# 4. 恢复 stash（如果有）
git stash pop && echo ">>> 已恢复之前未提交的改动" || true

echo ">>> 同步完成，main 分支已是最新上游 + 你的修改"
