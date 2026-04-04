#!/usr/bin/env bash
set -euo pipefail

pr_number="${1:-}"

if [[ -z "$pr_number" ]]; then
  echo "Usage: git prwt <PR_NUMBER>" >&2
  exit 1
fi

branch="pr-$pr_number"
path="../$branch"

git fetch origin "pull/$pr_number/head:$branch"
git worktree add "$path" "$branch"

cd $path

echo "Created & CD to worktree $path"
