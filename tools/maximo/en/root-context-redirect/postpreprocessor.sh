#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SEARCH_DIR="/opt/IBM/SMP/maximo/deployment/was-liberty-default"
REDIRECT_WAR=root-context-redirect.war

find "$SEARCH_DIR" -type f \( -name 'maximo-all.sh' -o -name 'maximo-ui.sh' \) | while read -r SH_FILE; do
  SH_DIR=$(dirname "$SH_FILE")
  SH_NAME=$(basename -s .sh -- "$SH_FILE")
  CONFIG_DIR="$SH_DIR/config-servers/$SH_NAME/$SH_NAME-server"
  DEPLOYMENT_DIR="$SH_DIR/deployment/$SH_NAME/$SH_NAME-server"

  echo "[CUSTOM] Processing '$SH_NAME' server bundle..."

  # Update corresponding server.xml file
  # Comment out the following section if you prefer to register it manually 
  # in the server bundle's additional server config.
  # Ref. https://www.ibm.com/docs/en/mas-cd/maximo-manage/continuous-delivery?topic=customizing-configuring-application-server
  SERVER_FILE="$CONFIG_DIR/server.xml"
  SED_COMMAND="/<\/application>/a\<webApplication name=\"root-context-redirect\" location=\"root-context-redirect.war\" context-root=\"/\" />"
  echo "[CUSTOM] Registering root-context-redirect in '$SERVER_FILE'"
  sed -i "$SED_COMMAND" "$SERVER_FILE"

  # Handle inconsequent UI server bundle builds which are performed using buildmaximoui-war.sh script
  SH_TARGETS=("$SH_FILE")
  [ "$SH_NAME" == "maximo-ui" ] && SH_TARGETS+=("$SH_DIR/buildmaximoui-war.sh")
  # Inject the logic of copying redirect WAR file
  # NOTE: This operation cannot be performed at the time when the postpreprocessor.sh hook itself executes because
  #       deployment directory gets cleaned during the EAR build process.
  echo "[CUSTOM] Registering post-build hook in: ${SH_TARGETS[*]}"
  {
    echo; echo # Extra line breaks
    echo "echo '[CUSTOM] Installing $REDIRECT_WAR web application...'"
    echo "cp \"$SCRIPT_DIR/$REDIRECT_WAR\" \"$DEPLOYMENT_DIR/apps/\""
  } | tee -a "${SH_TARGETS[@]}" > /dev/null
done