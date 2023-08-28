#!/usr/bin/env powershell

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
# Artifact: Robypomper PowerShell Utils
# Version:  1.0.3
################################################################################

# Initialize log env var to print only important logs.
# If a log's env var was already setup, this method don't override it.
function INSTALL-Logs() {
  # Msg logs
  $global:LOG_FAT=$(if ($global:LOG_FAT -eq $null) {$true} else {$global:LOG_FAT})
  $global:LOG_ERR=$(if ($global:LOG_ERR -eq $null) {$true} else {$global:LOG_ERR})
  $global:LOG_WAR=$(if ($global:LOG_WAR -eq $null) {$true} else {$global:LOG_WAR})
  $global:LOG_INF=$(if ($global:LOG_INF -eq $null) {$true} else {$global:LOG_INF})
  $global:LOG_DEB=$(if ($global:LOG_DEB -eq $null) {$false} else {$global:LOG_DEB})
  $global:LOG_TRA=$(if ($global:LOG_TRA -eq $null) {$false} else {$global:LOG_TRA})

  # Scripts logs
  $global:LOG_SCRIPT=$(if ($global:LOG_SCRIPT -eq $null) {$false} else {$global:LOG_SCRIPT})
  $global:LOG_SCRIPT_PARAMS=$(if ($global:LOG_SCRIPT_PARAMS -eq $null) {$false} else {$global:LOG_SCRIPT_PARAMS})

  # Other logs
  $global:LOG_PHASE=$(if ($global:LOG_PHASE -eq $null) {$false} else {$global:LOG_PHASE})
}

# Initialize log env var to print all logs (except Trace logs).
# If a log's env var was already setup, this method don't override it.
function INSTALL-LogsDebug() {
  # Msg logs
  $global:LOG_FAT=$(if ($global:LOG_FAT -eq $null) {$true} else {$global:LOG_FAT})
  $global:LOG_ERR=$(if ($global:LOG_ERR -eq $null) {$true} else {$global:LOG_ERR})
  $global:LOG_WAR=$(if ($global:LOG_WAR -eq $null) {$true} else {$global:LOG_WAR})
  $global:LOG_INF=$(if ($global:LOG_INF -eq $null) {$true} else {$global:LOG_INF})
  $global:LOG_DEB=$(if ($global:LOG_DEB -eq $null) {$true} else {$global:LOG_DEB})
  $global:LOG_TRA=$(if ($global:LOG_TRA -eq $null) {$false} else {$global:LOG_TRA})

  # Scripts logs
  $global:LOG_SCRIPT=$(if ($global:LOG_SCRIPT -eq $null) {$true} else {$global:LOG_SCRIPT})
  $global:LOG_SCRIPT_PARAMS=$(if ($global:LOG_SCRIPT_PARAMS -eq $null) {$true} else {$global:LOG_SCRIPT_PARAMS})

  # Other logs
  $global:LOG_PHASE=$(if ($global:LOG_PHASE -eq $null) {$true} else {$global:LOG_PHASE})
}

# Initialize log env var to hide all logs.
# If a log's env var was already setup, this method don't override it.
function INSTALL-LogsNone() {
  # Msg logs
  $global:LOG_FAT=$(if ($global:LOG_FAT -eq $null) {$false} else {$global:LOG_FAT})
  $global:LOG_ERR=$(if ($global:LOG_ERR -eq $null) {$false} else {$global:LOG_ERR})
  $global:LOG_WAR=$(if ($global:LOG_WAR -eq $null) {$false} else {$global:LOG_WAR})
  $global:LOG_INF=$(if ($global:LOG_INF -eq $null) {$false} else {$global:LOG_INF})
  $global:LOG_DEB=$(if ($global:LOG_DEB -eq $null) {$false} else {$global:LOG_DEB})
  $global:LOG_TRA=$(if ($global:LOG_TRA -eq $null) {$false} else {$global:LOG_TRA})

  # Scripts logs
  $global:LOG_SCRIPT=$(if ($global:LOG_SCRIPT -eq $null) {$false} else {$global:LOG_SCRIPT})
  $global:LOG_SCRIPT_PARAMS=$(if ($global:LOG_SCRIPT_PARAMS -eq $null) {$false} else {$global:LOG_SCRIPT_PARAMS})

  # Other logs
  $global:LOG_PHASE=$(if ($global:LOG_PHASE -eq $null) {$false} else {$global:LOG_PHASE})
}

# Internal method to print logs.
#
# $1 log's env var corresponding to log level.
# $2 log message to print.
function log() {

  param (
    [Parameter(Mandatory)][bool]$toPrint,
    [Parameter(Mandatory)][string]$msg
  )

  if ($toPrint) {
    write-host $msg
  }
}

# Print fatal log message and exit from the script execution with given error code.
#
# $1 fatal message
# $2 exit code
function logFat() {

  param (
    [Parameter(Mandatory)][string]$msg,
    [int]$exitCode=0
  )

  log $global:LOG_FAT "FAT: $msg"
  logScriptEnd $exitCode
}

# Print error log message.
#
# $1 error message
function logErr() {

  param (
    [Parameter(Mandatory)][string]$msg
  )

  log $global:LOG_ERR "ERR: $msg"
}

# Print warning log message.
#
# $1 warning message
function logWar() {

  param (
    [Parameter(Mandatory)][string]$msg
  )

  log $global:LOG_WAR "WAR: $msg"
}

# Print info log message.
#
# $1 info message
function logInf() {

  param (
    [Parameter(Mandatory)][string]$msg
  )

  log $global:LOG_INF "INF: $msg"
}

# Print debug log message.
#
# $1 debug message
function logDeb() {

  param (
    [Parameter(Mandatory)][string]$msg
  )

  log $global:LOG_DEB "DEB: [$SCRIPT_NAME]: $msg"
}

# Print trace log message.
#
# $1 trace message
function logTra() {

  param (
    [Parameter(Mandatory)][string]$msg
  )

  log $global:LOG_TRA "TRA: [$SCRIPT_NAME]: $msg"
}

# Print script init log message.
# To call on script initialization.
function logScriptInit() {
  log $global:LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### Init script ####"
}

# Print script run log message.
# To call before script's main method.
function logScriptRun() {
  log $global:LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### Run script ####"
}

# Print script end log message and exit to the script.
# To call at the end of script's main method.
#
# $1 exit code (opt), if not set it exit the script with 0 code.
function logScriptEnd() {
  param (
    [int]$exitCode = 0
  )

  log $global:LOG_SCRIPT "SCR: [$SCRIPT_NAME]: #### End script ####"
  #[ -n "$1" ] && exit $1 || exit 0
  $host.SetShouldExit($exitcode)
  exit $exitcode
}

# Print script's param log message.
#
# $1 param name
# $2 param value
function logScriptParam() {

  param (
    [Parameter(Mandatory)][string]$key,
    [Parameter(Mandatory)][string]$value
  )

  log $global:LOG_SCRIPT_PARAMS "SCR: [$SCRIPT_NAME]: $key=$value"
}
