#!/bin/bash

################################################################################
# The John Operating System Project is the collection of software and configurations
# to generate IoT EcoSystem, like the John Operating System Platform one.
# Copyright (C) 2021 Roberto Pompermaier
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
################################################################################

################################################################################
# Artifact: JOD Dist Template
# Version:  1.0.3
################################################################################

# Initialize all JOD Scripts configs. Env vars used by JOD Distributions scripts.
# After executing the '$JOD_SCRIPT_CONFIG' file that contains customized (by Maker)
# values, this method initialize (if not customized by Maker) following configs:
# - JOD_DIR:                    JOD object's main folder, not editable
# - JOD_YML:                    JOD object's main config file, used by JOD execution as java params and by jod/get-jod-{proeprty}.sh scripts
# - JOD_DIST_NAME:              the JOD Distribution's name, not editable
# - JOD_DIST_VER:               the JOD Distribution's version, not editable
# - JOD_INSTALLATION_HASH:      unique JOD instance code (equals to JOD_DIR's hash code), not editable
# - JOD_INSTALLATION_NAME:      unique JOD instance name (compose by '$JOD_DIST_NAME-$JOD_INSTALLATION_HASH'), not editable
# - JOD_INSTALLATION_NAME_DOT:  like $JOD_INSTALLATION_NAME but without spaces, not editable
# - OS_TYPE:                    detectOS method, not editable
# - OS_INIT_SYS:                detectInitSystem method, not editable
# - JAVA_EXEC:                  Java JVM executable
# - JAVA_DIR:                   Folder of the JAVA_EXEC JVM, not editable
# - JAVA_VER:                   Version of the JAVA_EXEC JVM, not editable
#
# $1 configs.sh for JOD script's full path
setupJODScriptConfigs() {
  # Check if already executed
  [ -n "$__JOD_SCRIPT_CONFIGS" ] && return

  # Load custom configs
  JOD_SCRIPT_CONFIG=$1
  [ -f $JOD_SCRIPT_CONFIG ] && execScriptConfigs $JOD_SCRIPT_CONFIG || logFat "File 'configs.sh' for JOD script's not found ($JOD_SCRIPT_CONFIG), exit" $ERR_LOAD_SCRIPT_CONFIG

  # Get JOD_DIR
  export JOD_DIR=$(findFileInParents "$CALLER_PATH" "start.sh")
  if [ -z "$JOD_DIR" ]; then
    export JOD_DIR=$(findFileInParents "$SCRIPT_PATH" "start.sh")
    if [ -z "$JOD_DIR" ]; then
      logFat "Can't detect JOD_DIR (please run this script within the JOD installation folder), exit" $ERR_DETECT_SCRIPT_CONFIG
    fi
  fi

  # Load distribution's configs
  JOD_DISTRIBUTION_SCRIPT_CONFIG="$JOD_DIR/configs/dist_configs.sh"
  [ -f $JOD_DISTRIBUTION_SCRIPT_CONFIG ] && execScriptConfigs $JOD_DISTRIBUTION_SCRIPT_CONFIG || logWar "File 'dist_configs.sh' for JOD script's not found ($JOD_DISTRIBUTION_SCRIPT_CONFIG), skip"

  # Get JOD_YML, set from $JOD_SCRIPT_CONFIG
  [ -z "$JOD_YML" ] && export JOD_YML="$JOD_DIR/configs/jod.yml"

  # Get JOD_DIST_NAME, set from $JOD_DISTRIBUTION_SCRIPT_CONFIG
  [ -z "$JOD_DIST_NAME" ] && export JOD_DIST_NAME="JOD Custom Distribution"

  # Get JOD_DIST_VER, set from $JOD_DISTRIBUTION_SCRIPT_CONFIG
  [ -z "$JOD_DIST_VER" ] && export JOD_DIST_VER="Unknown"

  # Get OS_TYPE
  export OS_TYPE="$(detectOS)"
  [[ "$OS_TYPE" == Unknown* ]] && logFat "Can't detect OS_TYPE ($OS_TYPE), exit" $ERR_DETECT_SCRIPT_CONFIG

  # Get JOD_INSTALLATION_HASH
  if [ "$OS_TYPE" = "MacOS" ]; then
    JOD_INSTALLATION_HASH=$(echo -n "$JOD_DIR" | md5)
  elif [ "$OS_TYPE" = "Unix" ]; then
    JOD_INSTALLATION_HASH=$(echo -n "$JOD_DIR" | shasum | awk '{print $1}')
  else
    JOD_INSTALLATION_HASH=$(echo -n "$JOD_DIR" | shasum | awk '{print $1}')
  fi

  # Get JOD_INSTALLATION_NAME
  export JOD_INSTALLATION_NAME="$JOD_DIST_NAME-$JOD_INSTALLATION_HASH"

  # Get JOD_INSTALLATION_NAME_DOT
  export JOD_INSTALLATION_NAME_DOT=$(echo "$JOD_INSTALLATION_NAME" | tr '[:upper:]' '[:lower:]' | sed -e 's/\(.*\)/\1/' -e 's| |\.|g')

  # Get OS_INIT_SYS
  export OS_INIT_SYS="$(detectInitSystem)"
  [[ "$OS_INIT_SYS" == Unknown* ]] && logFat "Can't detect OS_INIT_SYS ($OS_INIT_SYS), exit" $ERR_DETECT_SCRIPT_CONFIG

  # Get JAVA_EXEC
  if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    javaPlace="JAVA_HOME"
    export JAVA_EXEC="$JAVA_HOME/bin/java"
  elif type -p java &>/dev/null; then
    javaPlace="PATH"
    export JAVA_EXEC="java"
  else
    logFat "Can't detect JAVA_EXEC (please check java installation and JAVA_HOME or PATH environment vars), exit" $ERR_DETECT_SCRIPT_CONFIG
  fi

  # Get JAVA_DIR
  if [ "$javaPlace" = "PATH" ]; then
    if [ "$OS_TYPE" = "MacOS" ]; then
      export JAVA_DIR=$("$(dirname "$(readlink "$(which java)")")"/java_home)
    else
      export JAVA_DIR=$(dirname "$(readlink "$(which java)")")
    fi
  else
    export JAVA_DIR=$(dirname "$JAVA_EXEC")
  fi

  # Get JAVA_VER
  export JAVA_VER=$("$JAVA_EXEC" -version 2>&1 | awk -F '"' '/version/ {print $2}')

  # Set JOD script's configs.sh executed
  export __JOD_SCRIPT_CONFIGS=1
}
