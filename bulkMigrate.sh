#!/bin/bash
# 
# Usage: bulkTransfer.sh \
#   target.registry.com replacementValue \
#   "$repo/$image1:{tag1,tag2,tag3} $repo/$image2:{tag4,tag5,tag6,latest}" 
#
# Example: ./bulkTransfer.sh target.registry.com newValue library/ubuntu:18.04
# This will move docker.io/library/ubuntu:18.04 to target.registry.com/newValue/ubuntu:18.04

destRegistry="$1"
destRegistryReplacement="$2"
listOfContainers="${@:3}"

## Set Colors
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"
##

if [ -z "$destRegistry" ]; then
    echo "You need to pass in a destination registry."
    exit 1
else :
fi
# Check if the list of containers is empty
if [ -z "$listOfContainers" ]; then
    echo 'You need to pass in a list of containers'
    exit 1
else :
fi

function installToolWithBrew() {
    tool="$1"
    # On MacOS using Brew; install a list of tools
    # If Brew is not installed, then...install it and run it again.
    [ "$(command -v $tool)" ] && CDEXIST="True" || CDEXIST="False"
    if [ "${CDEXIST}" = "False" ]; then
        [ "$(command -v brew)" ] && BREWEXIST="True" || BREWEXIST="False"
        if [ "${BREWEXIST}" = "True" ]; then
            echo "Installing $tool"
            brew install --cask $tool
        else
            echo "Neither 'brew' or '$tool' are installed on your machine."
            echo "Please install $tool on your system manually."
            return
        fi
    fi
}

# Install Skopeo
installToolWithBrew skopeo

for container in $listOfContainers; do
    if [ -z $destRegistryReplacement ]; then
        newContainer=$container
    else
        newContainer="$(echo $container | sed 's@.*/@'$destRegistryReplacement'/@')"
    fi

    echo "========================"
    echo -e $(printf "Source: ${RED} docker.io/$container${ENDCOLOR}")
    echo -e $(printf "Dest: ${BLUE} $destRegistry/$newContainer${ENDCOLOR}")

    skopeo copy \
    --override-os linux \
    docker://docker.io/$container \
    docker://$destRegistry/$newContainer
done
