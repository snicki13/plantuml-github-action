#!/bin/bash

set -eu

git_is_dirty() {
  [ -n "$(git status -s)" ]
}

if git_is_dirty; then
    git config --global user.name "$COMMIT_USERNAME"
    git config --global user.email "$COMMIT_EMAIL"
    git add .
    git commit -m "$COMMIT_MESSAGE"
    git push
else
    echo "No local changes to commit."
fi
