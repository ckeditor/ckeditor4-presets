#!/bin/bash
# Copyright (c) 2003-2018, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see https://ckeditor.com/legal/ckeditor-oss-license

# Build CKEditor using the default settings (and build.js)

# Move to the script directory.
cd $(dirname $0)

# Use the ckeditor-dev commit hash as the revision.
cd ckeditor/
rev=`git rev-parse --verify --short HEAD`
CKEDITOR_VERSION=`node -pe "require('./package.json').version"`
cd ..

CKBUILDER_VERSION="2.3.2"
CKBUILDER_URL="http://download.cksource.com/CKBuilder/$CKBUILDER_VERSION/ckbuilder.jar"

MATHJAX_LIB_PATH="../mathjax/2.2"

versionFolder="${CKEDITOR_VERSION// /-}"

if [ "$1" == "-v" ]
then
	echo $versionFolder
	exit 0
fi

set -e

echo "CKEditor Presets Builder"
echo "========================"

case $1 in
	basic) name="Basic" ;;
	standard) name="Standard" ;;
	full) name="Full" ;;
	*)
		echo ""
		echo "Usage:"
		echo "$0 -v"
		echo "$0 basic|standard|full [all] [-t]"
		echo ""
		exit 1
		;;
esac

skip="-s"
target="build/$versionFolder/$1"

if [ "$2" == "all" ]
then
	skip=""
	target="$target-all"
fi

PROGNAME=$(basename $0)
MSG_UPDATE_FAILED="Warning: The attempt to update ckbuilder.jar failed. The existing file will be used."
MSG_DOWNLOAD_FAILED="It was not possible to download ckbuilder.jar"
ARGS=" $@ "

function error_exit
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

function command_exists
{
	command -v "$1" > /dev/null 2>&1;
}

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
echo "Copying extra plugins..."
cp -r plugins/* ckeditor/plugins/


echo ""
echo "Deleting $target..."
rm -rf $target


# Run the builder.
echo ""
echo "Building the '$1' preset..."

JAVA_ARGS=${ARGS// -t / } # Remove -t from arrgs

java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ckeditor $target $skip --version="$CKEDITOR_VERSION ($name)" --revision $rev --build-config presets/$1-build-config.js --no-zip --no-tar --overwrite $JAVA_ARGS

cp presets/$1-ckeditor-config.js $target/ckeditor/config.js
cp presets/README.md $target/ckeditor/


echo "Removing added plugins..."
cd ckeditor
git clean -d -f -f
cd ..

# Copy and build tests
if [[ "$ARGS" == *\ \-t\ * ]]; then
	echo ""
	echo "Copying tests..."

	cp -r ckeditor/tests $target/ckeditor/tests
	cp ckeditor/package.json $target/ckeditor/package.json
	cp ckeditor/bender.js $target/ckeditor/bender.js

	echo ""
	echo "Copying MathJax library..."

	if [ -d "$MATHJAX_LIB_PATH" ]; then
		mkdir $target/ckeditor/tests/plugins/mathjax/_assets
		cp -r "$MATHJAX_LIB_PATH" $target/ckeditor/tests/plugins/mathjax/_assets/mathjax
		echo "" >> $target/ckeditor/bender.js
		echo "config.mathJaxLibPath = '/tests/plugins/mathjax/_assets/mathjax/MathJax.js?config=TeX-AMS_HTML';" >> $target/ckeditor/bender.js
	else
		echo "WARNING: No MathJax lib in $MATHJAX_LIB_PATH." >&2
	fi

	echo ""
	echo "Installing tests..."

	(cd $target/ckeditor &&	npm install && bender init)
fi


echo ""
echo "Build created into the \"build\" directory."
echo ""
