#!/bin/bash

START="2025-01-01"
END="2025-03-31"

TIMEZONE="+0700"

TYPES=("feat" "fix" "docs" "refactor" "test" "chore" "perf")
SCOPES=("auth" "api" "ui" "core" "db" "config")
ACTIONS=("add" "improve" "update" "remove" "handle" "optimize")

FILE="progress.log"

touch $FILE

git checkout -B main

current="$START"

while [[ "$current" < "$END" || "$current" == "$END" ]]; do

  DAY=$(date -d "$current" +%u)

  # Skip Sunday
  if [ "$DAY" -ne 7 ]; then

    COMMITS=$((RANDOM % 2 + 1))
    ISSUE=$((RANDOM % 400 + 100))

    FEATURE="feature/issue-$ISSUE"

    git checkout -B $FEATURE main

    for ((i=1;i<=COMMITS;i++)); do

      TYPE=${TYPES[$RANDOM % ${#TYPES[@]}]}
      SCOPE=${SCOPES[$RANDOM % ${#SCOPES[@]}]}
      ACTION=${ACTIONS[$RANDOM % ${#ACTIONS[@]}]}

      HOUR=$((RANDOM % 8 + 9))
      MIN=$((RANDOM % 60))

      DATE_STR="$current $HOUR:$MIN:00 $TIMEZONE"

      MSG="$TYPE($SCOPE): $ACTION feature #$ISSUE"

      echo "$DATE_STR - $MSG" >> $FILE

      git add $FILE

      GIT_AUTHOR_DATE="$DATE_STR" \
      GIT_COMMITTER_DATE="$DATE_STR" \
      git commit -m "$MSG"

    done

    # Merge
    git checkout main

    MERGE_DATE="$current 18:00:00 $TIMEZONE"

    GIT_AUTHOR_DATE="$MERGE_DATE" \
    GIT_COMMITTER_DATE="$MERGE_DATE" \
    git merge --no-ff $FEATURE -m "merge: issue #$ISSUE into main"

    git branch -D $FEATURE
  fi

  current=$(date -d "$current +1 day" +"%Y-%m-%d")
done
