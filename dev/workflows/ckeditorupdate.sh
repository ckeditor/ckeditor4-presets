#!/bin/bash
# Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

# Updates "ckeditor" submodule in active branch - used by update.yml workflow.
branch=$(git rev-parse --abbrev-ref HEAD)
echo "Updating ckeditor4 submodule on ckeditor4-presets $branch branch..."

git submodule update --init --recursive

# Updates ckeditor submodule branch.
echo "Fetching latest ckeditor4 changes from $branch branch..."

cd "ckeditor"
oldHash=$(git log -1 --format="%h")
git fetch --all -p
git reset --hard "origin/$branch"
newHash=$(git log -1 --format="%h")

# Checks if anything changed and prepares commit.
if [ "$oldHash" = "$newHash" ]; then
	echo "Nothing changed (still on the latest $oldHash commit), aboritng..."
else
	echo "Preparing update for $branch branch from $oldHash to $newHash..."

	cd ".."
	git config --local user.email "ckeditor-bot@cksource.com"
	git config --local user.name "CKEditor Bot"
	git add ckeditor
	git commit -m "Update CKEditor 4 submodule HEAD."
fi
