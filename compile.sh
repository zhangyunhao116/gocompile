#!/usr/bin/env bash
set -e

SCRIPT_VERSION=v0.1.0

BUILD_OS=$1             # Default `(go env GOOS)`
BUILD_ARCH=$2           # Default `(go env GOARCH)`
BUILD_DIRNAME=$3        # Default `golang-go`

# Default values.
if [ "$BUILD_OS"x != ""x ];      then  export GOOS=$BUILD_OS;     else BUILD_OS=$(go env GOOS); fi
if [ "$BUILD_ARCH"x != ""x ];    then  export GOARCH=$BUILD_ARCH; else BUILD_ARCH=$(go env GOARCH); fi
if [ -z "${BUILD_DIRNAME}" ];    then  BUILD_DIRNAME=golang-go; fi

# Directory info.
CUR_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
WORKSPACE=workspace
RESULTSPACE=results
WORKSPACE_ABS="$CUR_DIR/$WORKSPACE"
RESULTSPACE_ABS="$CUR_DIR/$RESULTSPACE"
rm -rf "$CUR_DIR/$WORKSPACE" 2> /dev/null
rm -rf "$CUR_DIR/$RESULTSPACE" 2> /dev/null
mkdir -p "$CUR_DIR/$WORKSPACE"
mkdir -p "$CUR_DIR/$RESULTSPACE"

# HOST info.
HOST_OS=$(go env GOHOSTOS)
HOST_ARCH=$(go env GOHOSTARCH)
HOST_GO=$(go version)
GCCVERSION=$(gcc --version | grep ^gcc | sed 's/^.* //g')
TIME=$(date "+%Y-%m-%d %H:%M:%S")" UTC+8"
export GOROOT_BOOTSTRAP=/usr/local/go

# Get enough compile info.
cd "${BUILD_DIRNAME}"
COMMIT=$(git rev-parse HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
MODIFIED=$(git ls-files -m)
echo "----------------------------" 
echo WORKSPACE "  ${WORKSPACE}" "${WORKSPACE_ABS}"
echo RESULTSPACE "${RESULTSPACE}" "${RESULTSPACE_ABS}"
echo TIME "    ${TIME}" # keep sync with below
echo BUILD "   ${BUILD_OS}"/"${BUILD_ARCH}"
echo SCRIPT "  ${SCRIPT_VERSION}"
echo HOST_GO " ${HOST_GO}"
echo HOST_GCC "${GCCVERSION}"
echo FromHOST "${HOST_OS}"/"${HOST_ARCH}"
echo BRANCH "  ${BRANCH}"
echo COMMIT "  ${COMMIT}"
echo "\nMODIFIED:\n${MODIFIED}"
echo "----------------------------"
cd ..

# Step1: make a copy and build. (now we in ROOT directory)
cp -r "${BUILD_DIRNAME}" "${WORKSPACE}"/go
cd "${WORKSPACE}"/go
git clean -xdf # remove all files in .gitignore
cd src
./make.bash
cd ../..

# Step2: remove unused files and move binary if need. (now we in WORKSPACE)
cd go
find . -name ".git"  | xargs rm -Rf
find . -name ".idea"  | xargs rm -Rf
find . -name ".DS_Store"  | xargs rm -Rf
rm -rf pkg/obj
rm -rf pkg/bootstrap
rm -rf pkg/"${HOST_OS}"_"${HOST_ARCH}"/cmd

if [ "$BUILD_OS" != "$HOST_OS" ] || [ "$BUILD_ARCH" != "$HOST_ARCH" ]; then # cross-compile situation
  rm -rf pkg/"${HOST_OS}"_"${HOST_ARCH}"
  rm -rf pkg/tool/"${HOST_OS}"_"${HOST_ARCH}"
  mv bin/"${BUILD_OS}"_"${BUILD_ARCH}"/* bin/
  rm -rf bin/"${BUILD_OS}"_"${BUILD_ARCH}"
  rm -rf pkg/"${BUILD_OS}"_"${BUILD_ARCH}"/cmd
fi

# Make `COMPILE_INFO`, keep sync with above.
echo TIME "    ${TIME}" >> COMPILE_INFO 
echo BUILD "   ${BUILD_OS}"/"${BUILD_ARCH}" >> COMPILE_INFO
echo SCRIPT "  ${SCRIPT_VERSION}" >> COMPILE_INFO
echo HOST_GO " ${HOST_GO}" >> COMPILE_INFO
echo HOST_GCC "${GCCVERSION}" >> COMPILE_INFO
echo FromHOST "${HOST_OS}"/"${HOST_ARCH}" >> COMPILE_INFO
echo BRANCH "  ${BRANCH}" >> COMPILE_INFO
echo COMMIT "  ${COMMIT}" >> COMPILE_INFO
echo "\nMODIFIED:\n${MODIFIED}" >> COMPILE_INFO

# Step3: Make result.
cd "${RESULTSPACE_ABS}"
tar -zcf go.tar.gz -C "${WORKSPACE_ABS}" go
