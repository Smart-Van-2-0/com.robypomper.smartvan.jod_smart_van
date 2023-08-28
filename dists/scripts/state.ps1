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

###############################################################################
# Usage:
# powershell $JOD_DIR/state.ps1 [SHOW_ALL=false] [NO_LOGS=false]
#
# Like other status scripts accept the ```NO_LOGS``` param to prevent logging
# message. If ```NO_LOGS``` is ```true```, then only the jod statuses are
# printed.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([switch] $SHOW_ALL=$false, [switch] $NO_LOGS=$false)

$JOD_DIR=(get-item $PSScriptRoot ).FullName
.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"

# PRE Init NO_LOGS

#$DEBUG=$true
if ( $NO_LOGS ) { INSTALL-LogsNone } elseif (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

."$JOD_DIR/scripts/jod/jod-script-configs.ps1"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.ps1"

###############################################################################
logScriptInit

# Init NO_LOGS (PRE initialized)
logScriptParam "NO_LOGS" "$NO_LOGS"

# Init SHOW_ALL
logScriptParam "SHOW_ALL" "$SHOW_ALL"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.ps1"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "JOD_DIR:$JOD_DIR"
logInf "Get JOD instance statuses..."

$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
if ( $null -eq $JOD_PID) { $JOD_PID=""}
$JOD_STATE=($JOD_PID -ne "")
$JOD_OBJ_NAME=$(powershell "$JOD_DIR/scripts/jod/get-jod-name.ps1" -NO_LOGS)
if ( $null -eq $JOD_OBJ_NAME) { $JOD_OBJ_NAME=""}
$JOD_OBJ_ID=$(powershell "$JOD_DIR/scripts/jod/get-jod-id.ps1" -NO_LOGS)
if ( $null -eq $JOD_OBJ_ID) { $JOD_OBJ_ID=""}

if ( $SHOW_ALL ) {
    $INIT_SYS=$OS_INIT_SYS.ToLower()
    logTra "Execute '$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1'"
    $JOD_INSTALLED=$(powershell "$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1" -NO_LOGS)
    if ( $null -eq $JOD_INSTALLED) { $JOD_INSTALLED=""}
}

Write-Host "Instance State:  $(If ($JOD_STATE) {'Running'} Else {'NOT Running'})"
Write-Host "Instance PID:    $(If ($JOD_PID -ne '') {$JOD_PID} Else {'N/A'})"
if ( $SHOW_ALL ) { Write-Host "Is Installed:   " $(If ($JOD_INSTALLED -ne '') {$JOD_INSTALLED} Else {'N/A'})"" }
Write-Host "Obj's name:      $(If ($JOD_OBJ_NAME -ne '') {$JOD_OBJ_NAME} Else {'N/A'})"
Write-Host "Obj's id:        $(If ($JOD_OBJ_ID -ne '') {$JOD_OBJ_ID} Else {'N/A'})"

logInf "JOD instance state get successfully"

###############################################################################
logScriptEnd




#Write-Output "Listing Computer Services"
#Get-Service