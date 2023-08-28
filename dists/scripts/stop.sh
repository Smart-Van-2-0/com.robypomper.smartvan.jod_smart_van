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
# bash $JOD_DIR/stop.sh
#
# If current JOD Distribution was installed as daemon, then this script always
# fail. This script check for current JOD Distribution's PID, kill it and then
# checks that's not running. But if the JOD Distribution was installed as a
# Daemon, the underling Operating System, restart the JOD Instance immediately.
# So this script detect that the current JOD Instance is still running and exit
# with an error. In this case, this script act as a restart script.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"

#DEBUG=true
[[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs
setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

execScriptConfigs "$JOD_DIR/scripts/jod/jod-script-configs.sh"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.sh"

###############################################################################
logScriptInit

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Check if distribution is already stopped..."
JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
logTra "JOD_PID=$JOD_PID"
if [ -z "$JOD_PID" ]; then
  logWar "Distribution already stopped, nothing to do"
  logScriptEnd
fi

logInf "Execute pre-shutdown.sh..."
if [ -f "$JOD_DIR/scripts/pre-shutdown.sh" ]; then
  execScriptCommand $JOD_DIR/scripts/pre-shutdown.sh || ([ "$?" -gt "0" ] &&
    logWar "Error executing PRE shutdown script, exit $?" && exit $? ||
    logWar "Error executing PRE shutdown script, continue $?")
else
  logDeb "PRE shutdown script not found, skipped (missing $JOD_DIR/scripts/pre-shutdown.sh)"
fi

logInf "Kill distribution..."
logDeb "Kill JOD with PID=$JOD_PID"
kill $JOD_PID

logInf "Wait 2 seconds and re-check..."
sleep 2

logInf "Check if distribution was stopped gracefully..."
JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
logTra "JOD_PID=$JOD_PID"
if [ -z "$JOD_PID" ]; then
  logInf "JOD shutdown successfully"

  logInf "Execute post-shutdown.sh..."
  if [ -f "$JOD_DIR/scripts/post-shutdown.sh" ]; then
    execScriptCommand $JOD_DIR/scripts/post-shutdown.sh || ([ "$?" -gt "0" ] &&
      logWar "Error executing POST shutdown script, exit $?" && exit $? ||
      logWar "Error executing POST shutdown script, continue $?")
  else
    logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
  fi

  logScriptEnd
fi

logInf "Wait 3 seconds and re-check..."
sleep 3

logInf "Check if distribution was stopped gracefully..."
JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
logTra "JOD_PID=$JOD_PID"
if [ -z "$JOD_PID" ]; then
  logInf "JOD shutdown successfully"

  logInf "Execute post-shutdown.sh..."
  if [ -f "$JOD_DIR/scripts/post-shutdown.sh" ]; then
    execScriptCommand $JOD_DIR/scripts/post-shutdown.sh || ([ "$?" -gt "0" ] &&
      logWar "Error executing POST shutdown script, exit $?" && exit $? ||
      logWar "Error executing POST shutdown script, continue $?")
  else
    logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
  fi

  logScriptEnd
fi

logInf "Force kill distribution"
logDeb "Kill JOD with PID=$JOD_PID"
kill -9 $JOD_PID

logInf "Wait 2 seconds and re-check..."
sleep 2

logInf "Check if distribution was stopped forced..."
JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
logTra "JOD_PID=$JOD_PID"
if [ -z "$JOD_PID" ]; then
  logInf "JOD shutdown successfully"

  logInf "Execute post-shutdown.sh..."
  if [ -f "$JOD_DIR/scripts/post-shutdown.sh" ]; then
    execScriptCommand $JOD_DIR/scripts/post-shutdown.sh || ([ "$?" -gt "0" ] &&
      logWar "Error executing POST shutdown script, exit $?" && exit $? ||
      logWar "Error executing POST shutdown script, continue $?")
  else
    logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
  fi

  logScriptEnd
fi

logFat "Can't shutdown JOD with PID=$JOD_PID" $ERR_CANT_SHUTDOWN

###############################################################################
logScriptEnd
