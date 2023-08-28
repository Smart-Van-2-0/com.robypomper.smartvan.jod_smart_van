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
# powershell $JOD_DIR/uninstall.ps1
#
# This script, detect the current machine's Init System via the ```$OS_INIT_SYS```
# [JOD Scripts Configs](#jod-scripts-configs) and then uninstall the current
# JOD Distribution as daemon. The underling Init System stops running daemon,
# if any.
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

$JOD_DIR=(get-item $PSScriptRoot ).FullName
.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"

#$DEBUG=$true
if (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

."$JOD_DIR/scripts/jod/jod-script-configs.ps1"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.ps1"

###############################################################################
logScriptInit

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.ps1"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Check if distribution is already uninstalled..."
$INIT_SYS=($OS_INIT_SYS.ToLower())
logTra "Execute '$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1'"
$STATUS_INSTALL=$(powershell "$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1" -NO_LOGS)
if ($STATUS_INSTALL.startsWith("ERROR_")) {
  logFat "Can't get Distribution's service state, error $STATUS_INSTALL" 7364
} elseif ( $STATUS_INSTALL -eq "Not Installed" ) {
    logWar "Distribution already uninstalled, nothing to do"
    logScriptEnd
}

logInf "Execute pre-uninstall.ps1..."
if ( Test-Path "$JOD_DIR/scripts/pre-uninstall.ps1" ) {
    execScriptCommand "$JOD_DIR/scripts/pre-uninstall.ps1"
    if (!$?) {
        logWar "Error executing PRE uninstall script, continue $LastExitCode"
    } elseif ($LastExitCode -gt 0) {
        logWar "Error executing PRE uninstall script, exit $LastExitCode"
        $host.SetShouldExit($LastExitCode)
        exit $LastExitCode
    }
} else {
    logDeb "PRE uninstall script not found, skipped (missing $JOD_DIR/scripts/pre-uninstall.ps1)"
}

logInf "Uninstalling distribution..."
$INIT_SYS=($OS_INIT_SYS.ToLower())
logTra "INIT_SY=$INIT_SYS"
execScriptCommand "$JOD_DIR/scripts/init/$INIT_SYS/uninstall-jod.ps1"

logInf "Distribution uninstalled successfully"

logInf "Execute post-uninstall.ps1..."
if ( Test-Path "$JOD_DIR/scripts/post-uninstall.ps1" ) {
    execScriptCommand "$JOD_DIR/scripts/post-uninstall.ps1"
    if (!$?) {
        logWar "Error executing POST uninstall script, continue $LastExitCode"
    } elseif ($LastExitCode -gt 0) {
        logWar "Error executing POST uninstall script, exit $LastExitCode"
        $host.SetShouldExit($LastExitCode)
        exit $LastExitCode
    }
} else {
    logDeb "POST uninstall script not found, skipped (missing $JOD_DIR/scripts/post-uninstall.ps1)"
}

###############################################################################
logScriptEnd
