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

# Initialize log env var to print only important logs.
# If a log's env var was already setup, this method don't override it.
setupLogs() {
  # Msg logs
  [ -z "$LOG_FAT" ] && LOG_FAT="true"
  [ -z "$LOG_ERR" ] && LOG_ERR="true"
  [ -z "$LOG_WAR" ] && LOG_WAR="true"
  [ -z "$LOG_INF" ] && LOG_INF="true"
  [ -z "$LOG_DEB" ] && LOG_DEB="false"
  [ -z "$LOG_TRA" ] && LOG_TRA="false"

  # Scripts logs
  [ -z "$LOG_SCRIPT" ] && LOG_SCRIPT="false"
  [ -z "$LOG_SCRIPT_PARAMS" ] && LOG_SCRIPT_PARAMS="false"

  # Other logs
  [ -z "$LOG_PHASE" ] && LOG_PHASE="false"
}

# Initialize log env var to print all logs (except Trace logs).
# If a log's env var was already setup, this method don't override it.
setupLogsDebug() {
  # Msg logs
  [ -z "$LOG_FAT" ] && LOG_FAT="true"
  [ -z "$LOG_ERR" ] && LOG_ERR="true"
  [ -z "$LOG_WAR" ] && LOG_WAR="true"
  [ -z "$LOG_INF" ] && LOG_INF="true"
  [ -z "$LOG_DEB" ] && LOG_DEB="true"
  [ -z "$LOG_TRA" ] && LOG_TRA="false"

  # Scripts logs
  [ -z "$LOG_SCRIPT" ] && LOG_SCRIPT="true"
  [ -z "$LOG_SCRIPT_PARAMS" ] && LOG_SCRIPT_PARAMS="true"

  # Other logs
  [ -z "$LOG_PHASE" ] && LOG_PHASE="true"
}

# Initialize log env var to hide all logs.
# If a log's env var was already setup, this method don't override it.
setupLogsNone() {
  # Msg logs
  [ -z "$LOG_FAT" ] && LOG_FAT="false"
  [ -z "$LOG_ERR" ] && LOG_ERR="false"
  [ -z "$LOG_WAR" ] && LOG_WAR="false"
  [ -z "$LOG_INF" ] && LOG_INF="false"
  [ -z "$LOG_DEB" ] && LOG_DEB="false"
  [ -z "$LOG_TRA" ] && LOG_TRA="false"

  # Scripts logs
  [ -z "$LOG_SCRIPT" ] && LOG_SCRIPT="false"
  [ -z "$LOG_SCRIPT_PARAMS" ] && LOG_SCRIPT_PARAMS="false"

  # Other logs
  [ -z "$LOG_PHASE" ] && LOG_PHASE="false"
}

# Internal method to print logs.
#
# $1 log's env var corresponding to log level.
# $2 log message to print.
log() {
  if [ $# -eq 2 ]; then
    [ "$1" = "true" ] && echo $2
  else
    echo "ERROR Log method missing params"
  fi
}

# Print fatal log message and exit from the script execution with given error code.
#
# $1 fatal message
# $2 exit code
logFat() {
  log $LOG_FAT "FAT: $1"
  logScriptEnd $2
}

# Print error log message.
#
# $1 error message
logErr() {
  log $LOG_ERR "ERR: $1"
}

# Print warning log message.
#
# $1 warning message
logWar() {
  log $LOG_WAR "WAR: $1"
}

# Print info log message.
#
# $1 info message
logInf() {
  log $LOG_INF "INF: $1"
}

# Print debug log message.
#
# $1 debug message
logDeb() {
  log $LOG_DEB "DEB: [$SCRIPT_NAME]: $1"
}

# Print trace log message.
#
# $1 trace message
logTra() {
  log $LOG_TRA "TRA: [$SCRIPT_NAME]: $1"
}

# Print script init log message.
# To call on script initialization.
logScriptInit() {
  log $LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### Init script ####"
}

# Print script run log message.
# To call before script's main method.
logScriptRun() {
  log $LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### Run script ####"
}

# Print script end log message and exit to the script.
# To call at the end of script's main method.
#
# $1 exit code (opt), if not set it exit the script with 0 code.
logScriptEnd() {
  log $LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### End script ####"
  [ -n "$1" ] && exit $1 || exit 0
}

# Print script's param log message.
#
# $1 param name
# $2 param value
logScriptParam() {
  log $LOG_SCRIPT_PARAMS "SCR: [$SCRIPT_NAME]: $1=$2"
}
