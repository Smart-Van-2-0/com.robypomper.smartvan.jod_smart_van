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
# $JOD_DIR/scripts/pre-startup.sh
#
# This script is executed before JOD instance startup (via start.sh
# script). It prepare current environment to run the JOD instance. For example
# it check that the current os is supported (All OSs), generates object's
# structure, starts HW Daemon as background process, checks gateways/servers
# reachability, checks installed commands, make HW scripts executables...
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

logInf "PRE Startup script"

# Check supported OS
supportedOS=("Unix" "MacOS" "BSD" "Solaris" )           # Only Unix base OS
failOnUnsupportedOS "${supportedOS[@]}"

# Check java
if command -v java &>/dev/null; then
  echo "Java installed"
else
  echo "Missing Java, please install it"
  logFat "Java not installed, exit" $ERR_MISSING_REQUIREMENTS
fi

# Check python
PY_COMMAND="python"
! [ -x "$(command -v "$PY_COMMAND")" ] && PY_COMMAND="python3"
! [ -x "$(command -v "$PY_COMMAND")" ] && PY_COMMAND="python2"
! [ -x "$(command -v "$PY_COMMAND")" ] && logFat "Python not found, can't run firmwares" 1

# Firmware launcher function
launch_fw () {
  FW_DIR=$1
  OPT=$2
  SIMULATE=$3
  VENV=$4
  INLINE_LOGS=$5

  FW_PID=$(ps aux | grep "$FW_DIR/run.py" | grep -v "grep" | awk '{ print $2 }')
  [[ ! -z "$FW_PID" ]] && kill -s 15 $FW_PID
  [[ "$SIMULATE" = true ]] && OPT+=" --simulate"

  # echo "$PY_COMMAND $JOD_DIR/deps/$FW_DIR/run.py $OPT --debug"
  if [[ "$VENV" = true ]]; then
    if [[ "$INLINE_LOGS" = true ]]; then
      source "$JOD_DIR/deps/$FW_DIR/venv/bin/activate" \
      && $PY_COMMAND "$JOD_DIR/deps/$FW_DIR/run.py" $OPT --debug &
    else
      source "$JOD_DIR/deps/$FW_DIR/venv/bin/activate" \
          && $PY_COMMAND "$JOD_DIR/deps/$FW_DIR/run.py" $OPT --debug >/dev/null 2>&1 &
    fi
  else
    if [[ "$INLINE_LOGS" = true ]]; then
      $PY_COMMAND "$JOD_DIR/deps/$FW_DIR/run.py" $OPT --debug &
    else
      $PY_COMMAND "$JOD_DIR/deps/$FW_DIR/run.py" $OPT --debug >/dev/null 2>&1 &
    fi
  fi

  sleep 0.1
  FW_PID=$(ps aux | grep "$FW_DIR/run.py" | grep -v "grep" | awk '{ print $2 }')
  [[ ! -z "$FW_PID" ]] && echo "Firmware $FW_DIR started successfully (with pid $FW_PID)" || echo "Error on start $FW_DIR firmware"
}

# Get configs from jod_dist_configs.sh
simulate="${SIMULATE:-false}"
venv="${VENV:-false}"
inline_logs="${INLINE_LOGS:-false}"

# Launch firmwares
launch_fw "com.robypomper.smartvan.fw.victron" "" $simulate $venv $inline_logs
