#!/bin/bash
# Copyright (c) 2003-2021, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see https://ckeditor.com/legal/ckeditor-oss-license

# Build CKEditor using the default settings (and build.js)

# Move to the script directory.
cd $(dirname $0)

# Install NPM deps and move external plugins from `node_modules` to `plugins` directory.
if [ "$1" != "-v" ]; then
	echo ""
	echo "Installing NPM dependencies..."

	npm i

	if [[ ! -d "plugins" ]]; then
		echo "Creating plugins directory..."
		mkdir "plugins"
	fi

	echo ""
	echo "Copying plugins from NPM directory..."
	echo ""

	cp -r "node_modules/ckeditor4-plugin-exportpdf" "plugins/exportpdf"
	cp -r "node_modules/ckeditor-plugin-scayt" "plugins/scayt"
	cp -r "node_modules/ckeditor-plugin-wsc" "plugins/wsc"
fi

# Use the ckeditor4 commit hash as the revision.
cd ckeditor/
rev=$(git rev-parse --verify --short HEAD)
CKEDITOR_VERSION=$(node -pe "require('./package.json').version")
cd ..

versionFolder="${CKEDITOR_VERSION// /-}"

if [ "$1" == "-v" ]
then
	echo $versionFolder
	exit 0
fi

set -e

# Variables
CKBUILDER_VERSION="2.4.2"
CKBUILDER_URL="https://download.cksource.com/CKBuilder/$CKBUILDER_VERSION/ckbuilder.jar"
MATHJAX_LIB_PATH="../mathjax/2.2"

RED='\033[0;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
UNDERLINE='\033[4m'
RESET_STYLE='\033[0m'

MSG_UPDATE_FAILED="Warning: The attempt to update ckbuilder.jar failed. The existing file will be used."
MSG_DOWNLOAD_FAILED="It was not possible to download ckbuilder.jar"
MSG_INCORRECT_JDK_VERSION="${RED}Your JDK version is not supported, there may be a problem to finish build process. Please change the JDK version to 15 or lower.${RED} ${GREEN}https://jdk.java.net/archive/${GREEN}"

PROGNAME=$(basename "$0")
ARGS=" $@ "
JAVA_ARGS=${ARGS// -t / } # Remove -t from args

echo "CKEditor Presets Builder"
echo "========================"

case $1 in
	basic) name="Basic" ;;
	standard) name="Standard" ;;
	full) name="Full" ;;
	# Standard below is used by design.
        demo) name="Standard";;
	*)
		if [[ -f "presets/$1-build-config.js" && -f "presets/$1-ckeditor-config.js" ]]; then
			name="${1}"
		else
			echo ""
			echo "Error: Could not find 'presets/$1-build-config.js' or 'presets/$1-ckeditor-config.js' config files."
			echo ""
			echo "Usage:"
			echo "$0 -v"
			echo "$0 basic|standard|full [all] [-t]"
			echo "$0 custom_config_name [all] [-t]"
			echo ""
			exit 1
		fi
		;;
esac

skip="-s"
target="build/$versionFolder/$1"
require_plugin=""

if [ "$2" == "all" ]
then
	skip=""
	target="$target-all"
fi

# Add WebSpellchecker Dialog plugin to Standard and Full presets, but disabled by default (until EOL 2021/12/31).
if [ "$1" == "standard" ] || [ "$1" == "full" ]
then
	require_plugin="-r wsc"
fi

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

jdk_version=$( echo `java -version 2>&1 | grep 'version' 2>&1 | awk -F\" '{ split($2,a,"."); print a[1]}'` | bc -l)
regex='^[0-9]+$'
# Builder is crashing when JDK version is newer than 15.
if ! [[ $jdk_version =~ $regex ]] || [ $jdk_version -gt 15 ]; then
	echo -e "${MSG_INCORRECT_JDK_VERSION}"
	echo -e "${UNDERLINE}${YELLOW}Actual version of JDK: ${jdk_version}${RESET_STYLE}"
fi

{
	java -jar ckbuilder/$CKBUILDER_VERSION/ckbuilder.jar --build ckeditor $target $skip $require_plugin --version="$CKEDITOR_VERSION ($name)" --revision $rev --build-config presets/$1-build-config.js --no-zip --no-tar --overwrite $JAVA_ARGS
} || {
	if ! [[ $jdk_version =~ $regex ]] || [ $jdk_version -gt 15 ]; then
		echo -e "\n${RED}The build has been stopped. Please verify the eventual error messages above.${RESET_STYLE}"
	fi
}

if [ -f "presets/$1-contents.css" ]; then
	cp presets/$1-contents.css $target/ckeditor/contents.css
fi
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
	echo "Copying External Plugins tests..."

	for dir in plugins/*/
	do
		dir=${dir%*/}
		dir=${dir##*/}

		if [ -d "plugins/$dir/tests" ] && [ -d "$target/ckeditor/plugins/$dir" ]; then
			cp -r "plugins/$dir/tests" "$target/ckeditor/plugins/$dir/tests"
			echo "    $dir"
		fi
	done

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

# Clean up `plugins` directory from copied NPM plugins.
echo ""
echo "Cleaning plugins directory from NPM artifacts..."

rm -rf "plugins"

echo ""
echo "Build created into the \"build\" directory."
echo ""
