#!/bin/bash

data_file_path="./commits_log.csv"

if ! test -f "$data_file_path"; then
    echo "Error: Data file $data_file_path not found!" >&2
    exit 1
fi

active_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

branch_info=$(grep "^[^,]\+,[^,]\+,$active_branch," "$data_file_path")

if [ -z "$branch_info" ]; then
    echo "Error: No data found for branch '$active_branch' in $data_file_path" >&2
    exit 1
fi

issue_id=$(echo "$branch_info" | sed 's/^\([^,]\+\),.*/\1/')
issue_desc=$(echo "$branch_info" | sed 's/[^,]\+,\([^,]\+\),.*/\1/')
priority=$(echo "$branch_info" | sed 's/.*,\([^,]\+\),[^,]\+,.*/\1/')
developer=$(echo "$branch_info" | sed 's/.*,\([^,]\+\),[^,]\+,[^,]\+,.*/\1/')
repo_url=$(echo "$branch_info" | sed 's/.*,\([^,]\+\),[^,]\+,[^,]\+,[^,]\+,.*/\1/')
github_url=$(echo "$branch_info" | sed 's/.*,\([^,]\+\)$/\1/')


time_stamp=$(date '+%d/%m/%Y %H:%M')

commit_note="$issue_id: $time_stamp: $active_branch: $developer: $priority: $issue_desc"

if [ $# -eq 1 ] && [ -n "$1" ]; then
    commit_note="$commit_note: $1"
fi

echo "Adding changes to Git..."
git add --all

echo "Committing changes with message: $commit_note"
git commit -m "$commit_note"

echo "Pushing to remote branch $active_branch..."
git push origin "$active_branch"

if [ $? -eq 0 ]; then
    echo "Changes successfully committed and pushed to branch '$active_branch'!"
else
    echo "Failed to commit or push changes to branch '$active_branch'!" >&2
    exit 1
fi
