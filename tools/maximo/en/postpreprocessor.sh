#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

LIBERTY_DIR=/opt/IBM/SMP/maximo/deployment/was-liberty-default
APPS_DIR=$LIBERTY_DIR/deployment/maximo-all/maximo-all-server/apps
REDIRECT_WAR=root-context-redirect.war
MAXIMO_ALL_SCRIPT=$LIBERTY_DIR/maximo-all.sh

# Extend maximo-all.sh build script by appending section which copies over WAR file to the destination directory
# NOTE: This operation cannot be performed at the time when the postpreprocessor.sh hook itelf executes because
#       APPS_DIR gets cleaned during the EAR build process.
echo "[CUSTOM] Registering post-build hook in $MAXIMO_ALL_SCRIPT"
{
    echo; echo # Extra line breaks
    echo "echo '[CUSTOM] Installing $REDIRECT_WAR web application...'"
    echo "mv $SCRIPT_DIR/$REDIRECT_WAR $APPS_DIR/"
} >> $MAXIMO_ALL_SCRIPT
