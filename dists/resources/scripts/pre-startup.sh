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

# Get local python command
PY_COMMAND="python"
! [ -x "$(command -v "$PY_COMMAND")" ] && PY_COMMAND="python3"
! [ -x "$(command -v "$PY_COMMAND")" ] && PY_COMMAND="python2"
! [ -x "$(command -v "$PY_COMMAND")" ] && logFat "Python not found, can't run FW Victron" 1


# Kill FW Victron command, if running
FW_VICTRON_PID=$(ps aux | grep 'com.robypomper.smartvan.fw.victron/run.py' | grep -v "grep" | awk '{ print $2 }')
[[ ! -z FW_VICTRON_PID ]] && kill $FW_VICTRON_PID
## FW Victron as background process
OPT=""
if true; then
  OPT="--simulate"
fi
nohup bash -c \
  "source $JOD_DIR/deps/com.robypomper.smartvan.fw.victron/venv/bin/activate \
  && $PY_COMMAND $JOD_DIR/deps/com.robypomper.smartvan.fw.victron/run.py $OPT --debug" >/dev/null 2>&1 &
  #&& $PY_COMMAND $JOD_DIR/deps/com.robypomper.smartvan.fw.victron/run.py $OPT --debug" 0<&- &> "$JOD_DIR/logs/fw_victron.log" &

## Example check Supported OS - START
## Check supported OS
## De-comment only supported OS
##supportedOS=("Unix" "MacOS" "BSD" "Solaris" "Win32")    # All OSs
##supportedOS=("Unix" "MacOS" "BSD" "Solaris" )           # Only Unix base OS
##supportedOS=("Unix" "BSD" "Solaris")                    # Only Linux
##supportedOS=("MacOS")                                   # Only MacOS
##supportedOS=("Win32")                                   # Only Windows
#failOnUnsupportedOS "${supportedOS[@]}"
## Example check Supported OS - END



## Example generate JOD Object Structure - START
## Generate a John Object Structure for current {Represented Object}
#source "$JOD_DIR/scripts/hw/generateObjectStructure.sh"
## or
#source "$JOD_DIR/scripts/hw/cached/generate.sh" > "$JOD_STRUCT"
## Example generate JOD Object Structure - END



## Example start the HW Daemon - START
## Start HW Daemon as background process
##export DEBUG=true
#nohup bash "$JOD_DIR/scripts/hw/start_daemon.sh" 0<&- &> "$JOD_DIR/logs/daemon.log" &
## Example start the HW Daemon - END



## Example various: set sensors' scripts executables - START
## Set sensors scripts executables
#find $JOD_DIR/scripts/hw/ -type f -exec chmod +x {} \;
## Example various: set sensors' scripts executables - END

## Example various: Check server/gateway reachability - START
## Check gateway reachability
#GW_NAME="Philips Hue Gateway at '$HUE_GW_ADDR' address"
#GW_CONN="on the same local network of current machine"
#GW_PARAMS="HUE_GW_NAME and HUE_GW_ADDR"
#if ping -c2 "$HUE_GW_ADDR" >/dev/null; then
#  logWar "ERROR: $GW_NAME NOT reachable"
#  logFat "Please check that the gateway was connected successfully ($GW_CONN), or update distribution configs with correct $GW_PARAMS values" $ERR_MISSING_REQUIREMENTS
#else
#  logInf "$GW_NAME reachable"
#fi
## Example various: Check server/gateway reachability - END

## Example various: check Java installed - START
## Check java
#if command -v java &>/dev/null; then
#  echo "Java installed"
#else
#  echo "Missing Java, please install it"
#  logFat "Java not installed, exit" $ERR_MISSING_REQUIREMENTS
#fi
## Example various: check Java installed - END

## Example various: Make firmware's scripts executable - START
## Set sensors scripts executables
#find $JOD_DIR/scripts/hw/ -type f -exec chmod +x {} \;
## Example various: Make firmware's scripts executable - END
