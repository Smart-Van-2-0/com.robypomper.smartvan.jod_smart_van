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
# Customization:
# $JOD_DIR/scripts/post-shutdown.sh
#
# This script is executed after JOD instance shutdown (via stop.sh script).
#
# It can be customized adding more checks or operations depending on
# JOD Distribution needs.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
#
# Artifact: {JOD Dist Name}
# Version:  {JOD Dist Version}
###############################################################################

## Default init - START
JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/.."
source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"

#DEBUG=true
[[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs
setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

execScriptConfigs "$JOD_DIR/scripts/jod/jod-script-configs.sh"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.sh"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"
## Default init - END

logInf "POST Shutdown script"

# Firmware killer function
stop_fw () {
  FW_DIR=$1

  FW_PID=$(ps aux | grep "$FW_DIR/run.py" | grep -v "grep" | awk '{ print $2 }')
  # ps aux | grep $FW_PID | grep -v "grep"
  # echo "kill -s 15 $FW_PID"
  [[ -z "$FW_PID" ]] && echo "Firmware $FW_DIR not running" && return
  [[ ! -z "$FW_PID" ]] && kill $FW_PID

  sleep 0.1
  FW_PID=$(ps aux | grep "$FW_DIR/run.py" | grep -v "grep" | awk '{ print $2 }')
  [[ ! -z "$FW_PID" ]] && echo "Firmware $FW_DIR stopped successfully (with pid $FW_PID)" || echo "Error on kill $FW_DIR firmware (with pid $FW_PID)"
}

# Kill firmwares
stop_fw "com.robypomper.smartvan.fw.victron"
stop_fw "com.robypomper.smartvan.fw.upspack_v3"
