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

###############################################################################
# Usage:
# bash $JOD_DIR/state.sh [SHOW_ALL=false] [NO_LOGS=false]
#
# Like other status scripts accept the ```NO_LOGS``` param to prevent logging
# message. If ```NO_LOGS``` is ```true```, then only the jod statuses are
# printed.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"

# PRE Init NO_LOGS
NO_LOGS=${2:-false}

#DEBUG=true
[ "$NO_LOGS" = "true" ] && setupLogsNone || [[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs

setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

execScriptConfigs "$JOD_DIR/scripts/jod/jod-script-configs.sh"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.sh"

###############################################################################
logScriptInit

# Init NO_LOGS (PRE initialized)
logScriptParam "NO_LOGS" "$NO_LOGS"

# Init SHOW_ALL
SHOW_ALL=${1:-false}
logScriptParam "SHOW_ALL" "$SHOW_ALL"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Get distribution statuses..."

JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
[ -n "$JOD_PID" ] && JOD_STATE="Running" || JOD_STATE="NOT Running"
JOD_OBJ_NAME=$(bash "$JOD_DIR/scripts/jod/get-jod-name.sh" true)
JOD_OBJ_ID=$(bash "$JOD_DIR/scripts/jod/get-jod-id.sh" true)

if [ "$SHOW_ALL" == true ]; then
  INIT_SYS=$(echo "$OS_INIT_SYS" | tr '[:upper:]' '[:lower:]')
  logTra "Execute '$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.sh'"
  JOD_INSTALLED=$(bash "$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.sh" true)
fi

echo "Instance State:  $JOD_STATE"
echo "Instance PID:    ${JOD_PID:-N/A}"
[ "$SHOW_ALL" == true ] && echo "Is Installed:    ${JOD_INSTALLED:-N/A}"
echo "Obj's name:      ${JOD_OBJ_NAME:-N/A}"
echo "Obj's id:        ${JOD_OBJ_ID:-N/A}"

logInf "Distribution state get successfully"

###############################################################################
logScriptEnd
