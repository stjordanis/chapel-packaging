#!/bin/bash

# Building a .deb/.dsc package from the release-source
# Most of this script should be handled with uscan / watch file eventually

source config.sh

### Preliminary setup ###

# Setup variables
configSetup

cd ${DEBIAN_RELEASE}

configClean

# Download tarball if tarball not already present
if [ -a ../cache/${SRC_TAR} ]; then
    echo "../cache/${SRC_TAR} found"
    echo "Using ../cache/${SRC_TAR} instead of downloading ${CHPL_RELEASE_URL}"
else
    wget ${CHPL_RELEASE_URL}
    mkdir -p ../cache
    mv ${SRC_TAR} ../cache/
fi

cp ../cache/${SRC_TAR} ${TARBALL}

# Create package workspace
mkdir -p ${PKG}

#cp ../${SRC_TAR} ${ORIG_TARBALL}
echo "mk-origtargz --copyright-file debian/copyright ${TARBALL} -C ."
# Spits out a lot of garbage, so we /dev/null it
mk-origtargz --copyright-file debian/copyright ${TARBALL} -C . 2> /dev/null

# Untar into workspace
echo "tar -zxf ${ORIG_TARBALL} -C ${PKG} --strip-components 1"
tar -zxf ${ORIG_TARBALL} -C ${PKG} --strip-components 1

# Move debian directory with custom debian files into source
cp -r ${DEB_SRC} ${PKG}/debian

if [ -z ${DRY+x} ]; then
    (cd ${PKG} && dpkg-buildpackage  -j4 -us -uc 2>&1 | tee ../../cache/build.log)
else
    echo "\$DRY is set, not building with dpkg-buildpackage..."
fi

