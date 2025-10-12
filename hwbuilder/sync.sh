#!/usr/bin/env bash
set -e
git checkout upstream-master
git fetch upstream && git merge upstream/master
git checkout hwbuilder-subtree
git merge upstream-master
git subtree push --prefix=hwbuilder origin hwbuilder-subtree
echo ">>> 现在去 GitHub 把 hwbuilder-subtree → main 合并即可"
