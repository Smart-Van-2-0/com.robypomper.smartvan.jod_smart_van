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

$ERR_EXEC_SCRIPT_CMD=1
$ERR_EXEC_CONFIG_CMD=2
$ERR_EXEC_LIB_CMD=3

# Initialize common script env vars about current execution.
# CALLER var are related to the script that calls current script (that one that
# called this function).
#
# $1 always must be $PSCommandPath
# $2 always must be $MyInvocation.PSCommandPath
function setupCallerAndScript() {

  param (
    [Parameter(Mandatory)][string]$caller,
    [string]$script="......"
  )
  if ($script -eq "") { $script=$caller }

  $global:CALLER=$caller #$PSCommandPath
  $global:CALLER_PATH=$((get-item $caller ).Directory.FullName)
  $global:CALLER_NAME=$((get-item $caller ).Name)
  #  $global:CALLER_CMD="$(ps -o comm= $PPID)"
  $global:SCRIPT=$script #$MyInvocation.PSCommandPath
  $global:SCRIPT_PATH=$((get-item $script ).Directory.FullName)
  $global:SCRIPT_NAME=$((get-item $script ).Name)
  $global:CALLER_SCRIPT=if ($caller -eq $script) { $true } else { $false }

  logTra "Caller $global:CALLER"
  logTra "Script $global:SCRIPT"
}

# Logger function that print script and his caller logs.
function logCallerAndScript() {
  if ( $LOG_SCRIPT -eq $true ) { write-host "[SCRIPT - $global:SCRIPT_NAME] Exec script $global:SCRIPT_NAME at $global:SCRIPT_PATH" }
  if ( ($LOG_SCRIPT -eq $true) -and ($global:CALLER_SCRIPT) ) { write-host "[SCRIPT - $global:SCRIPT_NAME] Caller script" }
}

# Execute given script as separate bash process, if errors occurs it exit with
# ERR_EXEC_SCRIPT_CMD error code.
#
# $1 script's path
# $2..$n executed's script params
function execScriptCommand() {

  param (
    [Parameter(Mandatory)][string]$script,
    [string]$params=$null
  )

  try {
    powershell "$script" $params
  } catch {
    pwsh "$script" $params
  }
  if (! $? ) {
    logFat "Error including script '$((get-item $script ).Name)' at '$((get-item $script ).Directory.FullName)'" $ERR_EXEC_SCRIPT_CMD
  }
}

# Execute given script as source, if errors occurs it exit with
# ERR_EXEC_CONFIG_CMD error code.
#
# $1 script's path
# $2..$n config's script params
function execScriptConfigs() {

  param (
    [Parameter(Mandatory)][string]$script,
    [string]$params=$null
  )

  ."$script" $params
  $exitCode = $LastExitCode
  if (! $? ) {
    logFat "Error including script '$((get-item $script ).Name)' at '$((get-item $script ).Directory.FullName)'" $ERR_EXEC_SCRIPT_CMD
  }
}

# Execute given script as source, if errors occurs it exit with
# ERR_EXEC_LIB_CMD error code.
#
# $1 script's path
function includeLib() {
  #LIB=$1
  #source $LIB
  #[ $? -gt 0 ] && logFat "Can't include bash libraries, current dir '$(pwd). Exit'" $ERR_EXEC_LIB_CMD
}
