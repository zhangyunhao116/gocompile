#!/usr/bin/env bash
set -e

BUILD_OS=$1
BUILD_ARCH=$2

HOST_OS=$(go env GOHOSTOS)
HOST_ARCH=$(go env GOHOSTARCH)

BUILD_DIRNAME=golang-go
TIME=$(date "+%Y-%m-%d %H:%M:%S")
export GOROOT_BOOTSTRAP=/usr/local/go

if [ "$BUILD_OS"x != ""x ]; then
  export GOOS=$BUILD_OS
else
  BUILD_OS=$(go env GOOS)
fi
if [ "$BUILD_ARCH"x != ""x ]; then
  export GOARCH=$BUILD_ARCH
else 
  BUILD_ARCH=$(go env GOARCH)
fi

# Get enough compile info.
cd "${BUILD_DIRNAME}"
COMMIT=$(git rev-parse HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "----------------------------"
echo BUILD_OS="${BUILD_OS}" BUILD_ARCH="${BUILD_ARCH}"
echo HOST_OS="${HOST_OS}" HOST_ARCH="${HOST_ARCH}"
echo BRANCH="${BRANCH}"
echo COMMIT="${COMMIT}"
echo "----------------------------"
cd ..

# Make a copy and build.
cp -r "${BUILD_DIRNAME}" go
cd go
git clean -xdf
cd src
./make.bash
cd ../..

# Remove unused files.
cd go
find . -name ".git"  | xargs rm -Rf
find . -name ".idea"  | xargs rm -Rf
find . -name ".DS_Store"  | xargs rm -Rf
rm -rf pkg/obj
rm -rf pkg/bootstrap
rm -rf pkg/"${HOST_OS}"_"${HOST_ARCH}"/cmd

# Remove unused HOST files in cross-compile situation.
if [ "$BUILD_OS" != "$HOST_OS" ] || [ "$BUILD_ARCH" != "$HOST_ARCH" ]; then
  rm -rf pkg/"${HOST_OS}"_"${HOST_ARCH}"
  rm -rf pkg/tool/"${HOST_OS}"_"${HOST_ARCH}"
  mv bin/"${BUILD_OS}"_"${BUILD_ARCH}"/* bin/
  rm -rf bin/"${BUILD_OS}"_"${BUILD_ARCH}"
  rm -rf pkg/"${BUILD_OS}"_"${BUILD_ARCH}"/cmd
fi

echo TIME="${TIME}" BRANCH="${BRANCH}" COMMIT="${COMMIT}" >> COMPILE_INFO
echo BUILD_OS="${BUILD_OS}" BUILD_ARCH="${BUILD_ARCH}" HOST_OS="${HOST_OS}" HOST_ARCH="${HOST_ARCH}" >> COMPILE_INFO
cd ..

# Handle result.
tar -zcf go.tar.gz go

# Remove temp files.
rm -rf go
