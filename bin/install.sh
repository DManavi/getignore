#!/usr/bin/env bash

{
# this method is copied from https://github.com/nvm-sh/nvm/blob/master/install.sh#L5-L7
is_available() {
    type "$1" > /dev/null 2>&1
}

# Detect operating system
[[ "$OSTYPE" =~ ^"linux" ]] && OS_NAME="linux"
[[ "$OSTYPE" =~ ^"darwin" ]] && OS_NAME="mac"

# OS not supported? 
if [ -z $OS_NAME ]
then
    echo 'Operating system is not supported.'
    exit 1
fi
############################

# get CPU architecture
[[ "$OS_NAME" == "linux" ]] && CPU_ARCH=$(uname -i)
[[ "$OS_NAME" == "mac" ]] && CPU_ARCH=$(uname -m)

# CPU_ARCH not supported? 
if [ -z $CPU_ARCH ]
then
    echo 'CPU architecture command not found.'
    exit 1
fi

[[ "$CPU_ARCH" == "x86_64" ]] && CPU_ARCH_NAME="x64"
[[ "$CPU_ARCH" =~ ^"armv*" ]] && CPU_ARCH_NAME="arm64"

# CPU architecture not supported? 
if [ -z $CPU_ARCH ]
then
    echo 'CPU architecture is not supported.'
    exit 1
fi
############################


# Get the most recent version
if is_available "curl"; then
    LATEST_VERSION=$(curl -L --silent https://api.github.com/repos/getignore/getignore/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
elif is_available "wget"; then
    LATEST_VERSION=$(wget -q -O - https://api.github.com/repos/getignore/getignore/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
fi

# Download OS-specific artifact
ARTIFACT_URL="https://github.com/GetIgnore/getignore/releases/download/${LATEST_VERSION}/getignore-${OS_NAME}_${CPU_ARCH_NAME}.zip"
DOWNLOAD_PATH=$(pwd)/getignore_$(date +%s).zip

if is_available "curl"; then
    curl $ARTIFACT_URL --output $DOWNLOAD_PATH -L
elif is_available "wget"; then
    wget $ARTIFACT_URL -O $DOWNLOAD_PATH
fi

# Install downloaded artifact into user bin folder
[[ "$OS_NAME" == "linux" ]] && INSTALL_PATH=/usr/local/bin/
[[ "$OS_NAME" == "mac" ]] && INSTALL_PATH=/usr/local/bin/

unzip $DOWNLOAD_PATH -d $INSTALL_PATH

# cleanup
rm $DOWNLOAD_PATH
}