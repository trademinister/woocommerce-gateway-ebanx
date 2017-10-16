#!/usr/bin/env bash

if [[ -z "$TRAVIS" ]]; then
	echo "Script is only to be run by Travis CI" 1>&2
	exit 1
fi

if [[ -z "$WP_ORG_PASSWORD" ]]; then
	echo "WordPress.org password not set" 1>&2
	exit 1
fi

if [[ -z "$TRAVIS_TAG" ]]; then
	echo "Build must be tag" 1>&2
	exit 0
fi

WP_ORG_USERNAME="ebanxwp"
PLUGIN="woocommerce-gateway-ebanx"
SLUG="ebanx-payment-gateway-for-woocommerce"
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
PLUGIN_BUILDS_PATH="$PROJECT_ROOT/build"
VERSION=$TRAVIS_TAG
ZIP_FILE="$PROJECT_ROOT/woocommerce-gateway-ebanx/$PLUGIN.zip"

# Ensure the zip file for the current version has been built
if [ ! -f "$ZIP_FILE" ]; then
    echo "Built zip file $ZIP_FILE does not exist" 1>&2
    exit 1
fi

cd "$PLUGIN_BUILDS_PATH"
cp "$ZIP_FILE" "$PLUGIN_BUILDS_PATH/$PLUGIN.zip"
ZIP_FILE="$PLUGIN_BUILDS_PATH/$PLUGIN.zip"
# Remove any unzipped dir so we start from scratch
rm -fR "$PLUGIN"
# Unzip the built plugin
unzip -q -o "$ZIP_FILE"

# Clean up any previous svn dir
rm -fR svn

# Checkout the SVN repo
svn co -q "http://svn.wp-plugins.org/$SLUG" svn

# Move out the trunk directory to a temp location
mv svn/trunk ./svn-trunk
# Create trunk directory
mkdir svn/trunk
# Copy our new version of the plugin into trunk
rsync -r -p $PLUGIN/* svn/trunk

# Copy all the .svn folders from the checked out copy of trunk to the new trunk.
# This is necessary as the Travis container runs Subversion 1.6 which has .svn dirs in every sub dir
cd svn/trunk/
TARGET=$(pwd)
cd ../../svn-trunk/

# Find all .svn dirs in sub dirs
SVN_DIRS=`find . -type d -iname .svn`

for SVN_DIR in $SVN_DIRS; do
    SOURCE_DIR=${SVN_DIR/.}
    TARGET_DIR=$TARGET${SOURCE_DIR/.svn}
    TARGET_SVN_DIR=$TARGET${SVN_DIR/.}
    if [ -d "$TARGET_DIR" ]; then
        # Copy the .svn directory to trunk dir
        cp -r $SVN_DIR $TARGET_SVN_DIR
    fi
done

# Back to builds dir
cd ../

# Remove checked out dir
rm -fR svn-trunk

# Add new version tag
mkdir svn/tags/$VERSION
rsync -r -p $PLUGIN/* svn/tags/$VERSION

# Add new files to SVN
svn stat svn | grep '^?' | awk '{print $2}' | xargs -I x svn add x@
# Remove deleted files from SVN
svn stat svn | grep '^!' | awk '{print $2}' | xargs -I x svn rm --force x@
svn stat svn

# Commit to SVN
svn ci --no-auth-cache --username $WP_ORG_USERNAME --password $WP_ORG_PASSWORD svn -m "Deploy version $VERSION"

# Remove SVN temp dir
rm -fR svn