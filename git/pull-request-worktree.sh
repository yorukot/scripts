#!/usr/bin/env bash
set -euo pipefail

pr_number="${1:-}"

if [[ -z "$pr_number" ]]; then
  echo "Usage: git prwt <PR_NUMBER>" >&2
  exit 1
fi

local_branch="pr-$pr_number"

canonical_repo_from_url() {
  local url="${1%.git}"

  url="${url%%\?*}"
  url="${url%%#*}"

  if [[ "$url" == *"://"* ]]; then
    printf '%s' "${url#*://*/}"
  elif [[ "$url" == *":"* ]]; then
    printf '%s' "${url#*:}"
  else
    printf '%s' "$url"
  fi
}

repo_root=$(git rev-parse --show-toplevel)
repo_parent=$(dirname "$repo_root")
path="$repo_parent/$local_branch"

base_remote="${PRWT_BASE_REMOTE:-origin}"

if ! base_remote_url=$(git -C "$repo_root" remote get-url "$base_remote" 2>/dev/null); then
  echo "Unable to read base remote '$base_remote'" >&2
  echo "Set PRWT_BASE_REMOTE to the remote that owns the PR, or add an origin remote." >&2
  exit 1
fi

base_repo=$(canonical_repo_from_url "$base_remote_url")

if [[ "$base_repo" != */* ]]; then
  echo "Unable to determine GitHub repository from remote '$base_remote': $base_remote_url" >&2
  exit 1
fi

if [[ -e "$path/.git" ]]; then
  echo "Using existing worktree $path"
else
  git -C "$repo_root" worktree add --detach "$path"
  echo "Created detached worktree $path"
fi

cd "$path"

gh pr checkout "$pr_number" --repo "$base_repo" --branch "$local_branch" --force

echo "Checked out PR #$pr_number in $path"
