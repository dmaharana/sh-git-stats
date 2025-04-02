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

echo "date,repo,branch,commit_count" > commits_by_branch.csv

for REPO_DIR in "$BASE_DIR"/*; do
   if [ -d "$REPO_DIR" ] && [ "$(git -C "$REPO_DIR" rev-parse --is-bare-repository 2>/dev/null)" = "true" ]; then
      REPO_NAME=$(basename "$REPO_DIR")
      BRANCHES=$(git --git-dir="$REPO_DIR" branch --format='%(refname:short)')
      for BRANCH in $BRANCHES; do
         COMMIT_COUNT=$(git --git-dir="$REPO_DIR" rev-list --count "$BRANCH" 2>/dev/null)
         LAST_DATE=$(git --git-dir="$REPO_DIR" log -1 --format=%ad "$BRANCH" --date=short 2>/dev/null)
         if [ -n "$LAST_DATE" ]; then
            echo "$LAST_DATE,$REPO_NAME,$BRANCH,$COMMIT_COUNT" >> commits_by_branch.csv
         fi
      done
   fi
done

echo "date,commit_count" > commits_by_date.csv
tail -n +2 commits_by_branch.csv | awk -F, '{sum[$1] += $4} END {for (d in sum) print d "," sum[d]}' | sort -k1,1 >> commits_by_date.csv

echo "year,commit_count" > commits_by_year.csv
tail -n +2 commits_by_branch.csv | awk -F, '{year=substr($1,1,4); sum[year] += $4} END {for (y in sum) print y "," sum[y]}' | sort -k1,1n >> commits_by_year.csv
