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
# Artifact: Robypomper Bash Utils
# Version:  1.0.3
################################################################################

ERR_EXEC_SCRIPT_CMD=1
ERR_EXEC_CONFIG_CMD=2
ERR_EXEC_LIB_CMD=3

# Initialize common script env vars about current execution.
# CALLER var are related to the script that calls current script (that one that
# called this function).
#
# $1 always must be $0
# $2 always must be {$BASH_SOURCE[0]}
setupCallerAndScript() {
  export CALLER=$1 #$0
  export CALLER_PATH="$(cd "$(dirname "$CALLER")" >/dev/null 2>&1 && pwd -P)"
  export CALLER_NAME="$(basename "$CALLER")"
  export CALLER_CMD="$(ps -o comm= $PPID)"
  export SCRIPT=$2 #${BASH_SOURCE[0]}
  export SCRIPT_PATH="$(cd "$(dirname "$SCRIPT")" >/dev/null 2>&1 && pwd -P)"
  export SCRIPT_NAME="$(basename "$SCRIPT")"
  [ "$CALLER" == "$SCRIPT" ] && export CALLER_SCRIPT="true"

  logTra "Caller $CALLER"
  logTra "Script $SCRIPT"
}

# Logger function that print script and his caller logs.
logCallerAndScript() {
  [ "$LOG_SCRIPT" = "true" ] && echo "[SCRIPT - $SCRIPT_NAME] Exec script $SCRIPT_NAME at $SCRIPT_PATH"
  [ "$LOG_SCRIPT" = "true" ] && [ "$CALLER" = "$SCRIPT" ] && echo "[SCRIPT - $SCRIPT_NAME] Caller script"
}

# Execute given script as separate bash process, if errors occurs it exit with
# ERR_EXEC_SCRIPT_CMD error code.
#
# $1 script's path
# $2..$n executed's script params
execScriptCommand() {
  SCRIPT="$1"
  shift
  bash "$SCRIPT" "$@"
  [ $? -gt 0 ] && logFat "Error including script '$(basename "$SCRIPT")' at '$(dirname "$SCRIPT")'" $ERR_EXEC_SCRIPT_CMD
  return 0
}

# Execute given script as source, if errors occurs it exit with
# ERR_EXEC_CONFIG_CMD error code.
#
# $1 script's path
# $2..$n config's script params
execScriptConfigs() {
  SCRIPT="$1"
  shift
  source "$SCRIPT" "$@"
  [ $? -gt 0 ] && logFat "Error including script '$(basename $SCRIPT)' at '$(dirname $SCRIPT)'" $ERR_EXEC_CONFIG_CMD
  return 0
}

# Execute given script as source, if errors occurs it exit with
# ERR_EXEC_LIB_CMD error code.
#
# $1 script's path
includeLib() {
  LIB=$1
  source $LIB
  [ $? -gt 0 ] && logFat "Can't include bash libraries, current dir '$(pwd). Exit'" $ERR_EXEC_LIB_CMD
}

# test if an array contains given value
# Call with following line: containsElement "a string" "${array[@]}"
containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && echo 0; done
  echo 1
}
