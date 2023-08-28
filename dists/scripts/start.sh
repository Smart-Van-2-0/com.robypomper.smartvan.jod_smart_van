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
# bash $JOD_DIR/start.sh [FOREGROUND] [FORCE]
#
# This script, depending on ```FOREGROUND``` param, can run the JOD Instance
# in background (default) or in foreground (if ```FOREGROUND``` is ```true```).
# When executed in background mode, this script print kill and logs command
# for started instance, then exits. Otherwise, when executed in foreground mode
# the scripts wait until the started instance will stopped or killed.
#
# The ```FORCE``` param, prevent the script fail when current JOD Distribution is
# already running. When ```FORCE``` param is ```true``` and current JOD Distribution
# is running, then this script shutdown current JOD Distribution calling the
# [$JOD_DIR/shutdown.sh](#shutdown-jod) script.
#
# The JOD Instance is a Java application executed using the Java Virtual Machine
# specified by the ```$JAVA_EXEC``` [JOD Scripts Configs](#jod-scripts-configs).
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

# Init FOREGROUND
FOREGROUND=${1:-false}
logScriptParam "FOREGROUND" "$FOREGROUND"

# Init FORCE
FORCE=${2:-false}
logScriptParam "FORCE" "$FORCE"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"

# Internal vars
JAR_RUN="jospJOD.jar"
[ -z "$MAIN_CLASS" ] && [ "$FOREGROUND" == true ] && MAIN_CLASS="com.robypomper.josp.jod.JODShell" || MAIN_CLASS="com.robypomper.josp.jod.JODDaemon"
logTra "MAIN_CLASS=$MAIN_CLASS"
PID_FILE="/tmp/$JOD_INSTALLATION_NAME_DOT.pid"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Check if distribution is already running..."
JOD_PID=$(bash "$JOD_DIR/scripts/jod/get-jod-pid.sh" true)
logTra "JOD_PID=$JOD_PID"
if [ -n "$JOD_PID" ]; then
  if [ "$FORCE" = "false" ]; then
    logWar "Distribution already running, please shutdown distribution or set FORCE param"
    logScriptEnd $ERR_ALREADY_RUNNING
  else
    logWar "Distribution already running, stop it"
    execScriptCommand "$JOD_DIR/stop.sh"
  fi
fi

logInf "Create logs dir..."
mkdir -p "$JOD_DIR/logs"

logInf "Execute pre-startup.sh..."
if [ -f "$JOD_DIR/scripts/pre-startup.sh" ]; then
  execScriptCommand "$JOD_DIR/scripts/pre-startup.sh" || ([ "$?" -gt "0" ] &&
    logWar "Error executing PRE startup script, exit $?" && exit $? ||
    logWar "Error executing PRE startup script, continue $?")
else
  logDeb "PRE startup script not found, skipped (missing '$JOD_DIR/scripts/pre-startup.sh')"
fi

if [ "$FOREGROUND" = "true" ]; then
  logInf "Start JOD distribution in foreground..."
  logInf "Skip post-startup.sh because in FOREGROUND mode"
  logInf "Skip pre-shutdown.sh because in FOREGROUND mode"

  cd $JOD_DIR && $JAVA_EXEC -Dlog4j.configurationFile=log4j2.xml -cp $JAR_RUN $MAIN_CLASS --configs=$JOD_YML $JOD_INSTALLATION_NAME_DOT
  EXIT_CODE=$?
  if [ $EXIT_CODE -gt 0 ]; then
    logFat "JOD Distribution terminated with exit code $EXIT_CODE"
  fi
  logInf "JOD distribution started and terminated successfully"

  logInf "Execute post-shutdown.sh..."
  if [ -f "$JOD_DIR/scripts/post-shutdown.sh" ]; then
    execScriptCommand "$JOD_DIR/scripts/post-shutdown.sh" || ([ "$?" -gt "0" ] &&
      logWar "Error executing POST shutdown script, exit $?" && exit $? ||
      logWar "Error executing POST shutdown script, continue $?")
  else
    logDeb "POST shutdown script not found, skipped (missing '$JOD_DIR/scripts/post-shutdown.sh')"
  fi

else

  logInf "Start JOD distribution in background..."
  cd $JOD_DIR && $JAVA_EXEC -Dlog4j.configurationFile=log4j2.xml -cp $JAR_RUN $MAIN_CLASS --configs=$JOD_YML $JOD_INSTALLATION_NAME_DOT >logs/console.log 2>&1 &
  PID=$!
  if ! ps -p $PID >/dev/null; then
    echo "Error on startup JOD Daemon"
    echo "To print daemon console logs:"
    echo "    $ tail -f $JOD_DIR/logs/console.log"
    logFat "Error on executing JOD Daemon."
  fi
  echo "$PID" >$PID_FILE
  logInf "Daemon executed successfully with $PID process id"
  echo "Execute following commands to kill this process:"
  echo "    $ kill $PID"
  echo "To print daemon console logs:"
  echo "    $ tail -f $JOD_DIR/logs/console.log"

  logInf "Distribution started successfully"

  logInf "Execute post-startup.sh..."
  if [ -f "$JOD_DIR/scripts/post-startup.sh" ]; then
    execScriptCommand $JOD_DIR/scripts/post-startup.sh || ([ "$?" -gt "0" ] &&
      logWar "Error executing POST startup script, exit $?" && exit $? ||
      logWar "Error executing POST startup script, continue $?")
  else
    logDeb "POST startup script not found, skipped (missing $JOD_DIR/scripts/post-startup.sh)"
  fi
fi

###############################################################################
logScriptEnd
