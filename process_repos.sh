#!/bin/bash

if [ -z "$1" ]; then
   echo "Usage: $0 <base_dir>"
   exit 1
fi

BASE_DIR=$1
if [ ! -d "$BASE_DIR" ]; then
   echo "Error: $BASE_DIR is not a directory."
   exit 1
fi

> commits_by_branch.csv
echo "date,repo,branch,commit_count" > commits_by_branch.csv

lock_dir="/tmp/repo_processing_lock$$"

for REPO_DIR in "$BASE_DIR"/*; do
   if [ -d "$REPO_DIR" ] && [ "$(git -C "$REPO_DIR" rev-parse --is-bare-repository 2>/dev/null)" = "true" ]; then
      (
         REPO_NAME=$(basename "$REPO_DIR")
         BRANCHES=$(git --git-dir="$REPO_DIR" branch --format='%(refname:short)')

         temp_data=()
         for BRANCH in $BRANCHES; do
            COMMIT_COUNT=$(git --git-dir="$REPO_DIR" rev-list --count "$BRANCH" 2>/dev/null)
            LAST_DATE=$(git --git-dir="$REPO_DIR" log -1 --format=%ad "$BRANCH" --date=short 2>/dev/null)
            if [ -n "$LAST_DATE" ]; then
               temp_data+=("$LAST_DATE,$REPO_NAME,$BRANCH,$COMMIT_COUNT")
            fi
         done

         # Acquire lock
         while [ -d "$lock_dir" ]; do
             sleep 0.1
         done
         mkdir "$lock_dir"

         # Append collected data
         for line in "${temp_data[@]}"; do
             echo "$line" >> commits_by_branch.csv
         done

         # Release lock
         rmdir "$lock_dir"
      ) &
   fi
done

wait

# Generate commits_by_date.csv
echo "date,commit_count" > commits_by_date.csv
tail -n +2 commits_by_branch.csv | awk -F, '{sum[$1] += $4} END {for (d in sum) print d "," sum[d]}' | sort -k1,1 >> commits_by_date.csv

# Generate commits_by_year.csv
echo "year,commit_count" > commits_by_year.csv
tail -n +2 commits_by_branch.csv | awk -F, '{year=substr($1,1,4); sum[year] += $4} END {for (y in sum) print y "," sum[y]}' | sort -k1,1n >> commits_by_year.csv
