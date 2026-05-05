#!/bin/bash

# Colors
GREEN='\033[0;32m'
NO_COLOR='\033[0m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

branch_width=30
commit_width=20
remote_width=30
max_branch_length=$branch_width
max_remote_length=$remote_width

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Print header
printf "${BLUE}%-${branch_width}s ${YELLOW}%-${commit_width}s ${GREEN}%-${remote_width}s${NO_COLOR}\n" "Branch" "Last Commit" "Remote"
printf "${BLUE}%-${branch_width}s ${YELLOW}%-${commit_width}s ${GREEN}%-${remote_width}s${NO_COLOR}\n" "------------------------------" "-------------------" "------------------------------"

format_string="%(refname:short)%09%(committerdate:relative)%09%(upstream:short)"
IFS=$'\n'

for line in $(git for-each-ref --sort=-committerdate --format="$format_string" refs/heads/); do
  IFS=$'\t' read -r branch time remote <<< "$line"
  IFS=$'\n'

  if [ "$branch" = "$current_branch" ]; then
    mark="*"
  else
    mark=" "
  fi

  # Truncate long branch name
  short_branch=$branch
  if [ ${#branch} -gt $max_branch_length ]; then
    short_branch="${branch:0:$((max_branch_length - 3))}..."
  fi

  if [ -z "$remote" ]; then
    remote="-"
  fi

  short_remote=$remote
  if [ ${#remote} -gt $max_remote_length ]; then
    short_remote="${remote:0:$((max_remote_length - 3))}..."
  fi

  printf "${BLUE}${mark}%-${branch_width}s ${YELLOW}%-${commit_width}s ${GREEN}%-${remote_width}s${NO_COLOR}\n" "$short_branch" "$time" "$short_remote"
done
