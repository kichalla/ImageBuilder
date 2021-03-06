#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# This script generates Dockerfiles for KuduLiteBuild Image for Azure App Service on Linux.
# --------------------------------------------------------------------------------------------

set -e

# Current Working Dir
declare -r DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Directory for Generated Docker Files
declare -r STACK_NAME="KuduLite"
declare -r SYSTEM_ARTIFACTS_DIR="$1"
declare -r BASE_IMAGE_REPO_NAME="$2/build"                         # mcr.microsoft.com/oryx
declare -r BASE_IMAGE_VERSION_STREAM_FEED="$3"                     # Base Image Version; Oryx Version : 20190819.2
declare -r APPSVC_DOTNETCORE_REPO="$4/${STACK_NAME}Build.git"      # https://github.com/Azure-App-Service/KuduLiteBuild.git
declare -r CONFIG_DIR="$5"                                         # ${Current_Repo}/Config
declare -r METADATA_FILE="$SYSTEM_ARTIFACTS_DIR/metadata"
declare -r APP_SVC_REPO_DIR="$SYSTEM_ARTIFACTS_DIR/$STACK_NAME/GitRepo"
declare -r APP_SVC_REPO_BRANCH="dev"

function generateDockerFiles()
{
   
    # Example line:
    # 1.0 -> uses Oryx Base Image mcr.microsoft.com/oryx/build:$BASE_IMAGE_VERSION_STREAM_FEED

    # Base Image
    BASE_IMAGE_NAME="${BASE_IMAGE_REPO_NAME}:$BASE_IMAGE_VERSION_STREAM_FEED"
    CURR_VERSION_DIRECTORY="${APP_SVC_REPO_DIR}/"
    TARGET_DOCKERFILE="${CURR_VERSION_DIRECTORY}/kudu/Dockerfile"

    echo "Generating App Service Dockerfile and dependencies for image '$BASE_IMAGE_NAME' in directory '$CURR_VERSION_DIRECTORY'..."

    # Remove Existing Version directory, eg: GitRepo/1.0 to replace with realized files
    rm -rf "$CURR_VERSION_DIRECTORY"
    mkdir -p "$CURR_VERSION_DIRECTORY"
    cp -R ${DIR}/template/* "$CURR_VERSION_DIRECTORY"

    # Replace placeholders, changing sed delimeter since '/' is used in path
    sed -i "s|BASE_IMAGE_NAME_PLACEHOLDER|$BASE_IMAGE_NAME|g" "$TARGET_DOCKERFILE"

    # Register the generated docker files wwith metadata dir
    echo "${APP_SVC_REPO_DIR}, " > $METADATA_FILE

    echo "Done."
}

function pullAppSvcRepo()
{
    echo "Cloning App Service KuduLiteBuild Repository in $APP_SVC_REPO_DIR"
    git clone $APPSVC_DOTNETCORE_REPO $APP_SVC_REPO_DIR
    echo "Cloning App Service KuduLiteBuild Repository in $APP_SVC_REPO_DIR"
    cd $APP_SVC_REPO_DIR
    echo "Checking out branch $APP_SVC_REPO_BRANCH"
    git checkout $APP_SVC_REPO_BRANCH
    chmod -R 777 $APP_SVC_REPO_DIR
}

pullAppSvcRepo
generateDockerFiles
