#!/bin/bash
# Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.html or http://ckeditor.com/license

# Build CKEditor using the default settings (and build.js)

set -e

echo "CKBuilder - Builds CKEditor preset releases."
echo ""

CKBUILDER_VERSION="1.6"
CKBUILDER_URL="http://download.cksource.com/CKBuilder/$CKBUILDER_VERSION/ckbuilder.jar"

PROGNAME=$(basename $0)
MSG_UPDATE_FAILED="Warning: The attempt to update ckbuilder.jar failed. The existing file will be used."
MSG_DOWNLOAD_FAILED="It was not possible to download ckbuilder.jar"

function error_exit
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

function command_exists
{
	command -v "$1" > /dev/null 2>&1;
}

# Move to the script directory.
cd $(dirname $0)

# Download/update ckbuilder.jar
mkdir -p ckbuilder/$CKBUILDER_VERSION
cd ckbuilder/$CKBUILDER_VERSION
if [ -f ckbuilder.jar ]; then
	echo "Checking/Updating CKBuilder..."
	if command_exists curl ; then
	curl -O -R -z ckbuilder.jar $CKBUILDER_URL || echo "$MSG_UPDATE_FAILED"
	else
	wget -N $CKBUILDER_URL || echo "$MSG_UPDATE_FAILED"
	fi
else
	echo "Downloading CKBuilder..."
	if command_exists curl ; then
	curl -O -R $CKBUILDER_URL || error_exit "$MSG_DOWNLOAD_FAILED"
	else
	wget -N $CKBUILDER_URL || error_exit "$MSG_DOWNLOAD_FAILED"
	fi
fi
cd ../..

echo ""
echo "Deleting releases/..."
rm -rf releases/

echo ""
echo "Copying extra plugins..."

cp -r plugins/ ckeditor/plugins/


# Run the builder.
echo ""
echo "Building the Basic Preset..."

java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ckeditor releases/basic -s --version="4 DEV (Basic)" --build-config presets/basic-build-config.js --overwrite "$@"

rm releases/basic/*.gz
rm releases/basic/*.zip

cp presets/basic-ckeditor-config.js releases/basic/ckeditor/config.js
cp presets/README.md releases/basic/ckeditor/

echo ""
echo "Building the Standard Preset..."

java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ckeditor releases/standard -s --version="4 DEV (Standard)" --build-config presets/standard-build-config.js --overwrite "$@"

rm releases/standard/*.gz
rm releases/standard/*.zip

cp presets/standard-ckeditor-config.js releases/standard/ckeditor/config.js
cp presets/README.md releases/standard/ckeditor/


echo ""
echo "Building the Full Preset..."

java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ckeditor releases/full -s --version="4 DEV (Full)" --build-config presets/full-build-config.js --overwrite "$@"

rm releases/full/*.gz
rm releases/full/*.zip

cp presets/README.md releases/full/ckeditor/

echo ""
echo "Removing added plugins..."
cd ckeditor
git clean -d -f -f
cd ..


echo ""
echo "Releases created in the \"releases\" directory."
