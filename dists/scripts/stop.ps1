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
# powershell $JOD_DIR/stop.ps1
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

param ([switch] $FOREGROUND=$false, [switch] $FORCE=$false)

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

logInf "Check if distribution is already stopped..."
$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
logTra "JOD_PID=$JOD_PID"
if ( $null -eq $JOD_PID) {
    logWar "Distribution already stopped, nothing to do"
    logScriptEnd
} elseif ($JOD_PID -eq "UnknownWinServiceId") {
    logWar "Distribution installed as a service but not running, nothing to do"
    logScriptEnd
}

logInf "Execute pre-shutdown.sh..."
if ( Test-Path "$JOD_DIR/scripts/pre-shutdown.ps1" ) {
    execScriptCommand "$JOD_DIR/scripts/pre-shutdown.ps1"
    if (!$?) {
        logWar "Error executing PRE shutdown script, continue $LastExitCode"
    } elseif ($LastExitCode -gt 0) {
        logWar "Error executing PRE shutdown script, exit $LastExitCode"
        $host.SetShouldExit($LastExitCode)
        exit $LastExitCode
    }
} else {
    logDeb "PRE shutdown script not found, skipped (missing $JOD_DIR/scripts/pre-shutdown.sh)"
}

logInf "Kill distribution..."
logDeb "Kill JOD with PID=$JOD_PID"
Stop-Process -Id $JOD_PID
#taskkill /pid $JOD_PID

logInf "Wait 2 seconds and re-check..."
#sleep 2

logInf "Check if distribution was stopped gracefully..."
$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
logTra "JOD_PID=$JOD_PID"
if ( $null -eq $JOD_PID) {
    logInf "JOD shutdown successfully"
    
    logInf "Execute post-shutdown.sh..."
    if ( Test-Path "$JOD_DIR/scripts/post-shutdown.ps1" ) {
        execScriptCommand "$JOD_DIR/scripts/post-shutdown.ps1"
        if (!$?) {
            logWar "Error executing POST shutdown script, continue $LastExitCode"
        } elseif ($LastExitCode -gt 0) {
            logWar "Error executing POST shutdown script, exit $LastExitCode"
            $host.SetShouldExit($LastExitCode)
            exit $LastExitCode
        }
    } else {
        logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
    }
    logScriptEnd
}

logInf "Wait 3 seconds and re-check..."
#sleep 3

logInf "Check if distribution was stopped gracefully..."
$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
logTra "JOD_PID=$JOD_PID"
if ( $null -eq $JOD_PID) {
    logInf "JOD shutdown successfully"
    
    logInf "Execute post-shutdown.sh..."
    if ( Test-Path "$JOD_DIR/scripts/post-shutdown.ps1" ) {
        execScriptCommand "$JOD_DIR/scripts/post-shutdown.ps1"
        if (!$?) {
            logWar "Error executing POST shutdown script, continue $LastExitCode"
        } elseif ($LastExitCode -gt 0) {
            logWar "Error executing POST shutdown script, exit $LastExitCode"
            $host.SetShouldExit($LastExitCode)
            exit $LastExitCode
        }
    } else {
        logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
    }
    logScriptEnd
}

logInf "Force kill distribution"
logDeb "Kill JOD with PID=$JOD_PID"
Stop-Process -Id $JOD_PID -Force

logInf "Wait 2 seconds and re-check..."
sleep 2

logInf "Check if distribution was stopped forced..."
$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
logTra "JOD_PID=$JOD_PID"
if ( $null -eq $JOD_PID) {
    logInf "JOD shutdown successfully"

    logInf "Execute post-shutdown.sh..."
    if ( Test-Path "$JOD_DIR/scripts/post-shutdown.ps1" ) {
        execScriptCommand "$JOD_DIR/scripts/post-shutdown.ps1"
        if (!$?) {
            logWar "Error executing POST shutdown script, continue $LastExitCode"
        } elseif ($LastExitCode -gt 0) {
            logWar "Error executing POST shutdown script, exit $LastExitCode"
            $host.SetShouldExit($LastExitCode)
            exit $LastExitCode
        }
    } else {
        logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
    }
    logScriptEnd
}

logFat "Can't shutdown JOD with PID=$JOD_PID" $ERR_CANT_SHUTDOWN

###############################################################################
logScriptEnd
