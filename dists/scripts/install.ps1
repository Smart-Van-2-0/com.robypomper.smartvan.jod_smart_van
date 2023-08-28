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
# powershell $JOD_DIR/install.ps1 [FORCE]
#
# The ```FORCE``` param, prevent the script fail when current JOD Distribution is
# already installed. When ```FORCE``` param is ```true``` and current JOD Distribution
# is installed, then this script uninstall current JOD Distribution calling the
# [$JOD_DIR/uninstall.sh](#uninstall-jod-daemon) script.
#
# This script, detect the current machine's Init System via the ```$OS_INIT_SYS```
# [JOD Scripts Configs](#jod-scripts-configs) and then install the current
# JOD Distribution as daemon. The underling Init System must run the daemon on
# system boot, and must restart it when it fails.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([switch] $FORCE=$false)

$JOD_DIR=(get-item $PSScriptRoot ).FullName
.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"

#$DEBUG=$true
if (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

."$JOD_DIR/scripts/jod/jod-script-configs.ps1"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.ps1"

###############################################################################
logScriptInit

# Init FORCE
logScriptParam "FORCE" "$FORCE"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.ps1"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Check if distribution is already installed..."
$INIT_SYS=($OS_INIT_SYS.ToLower())
logTra "Execute '$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1'"
$STATUS_INSTALL=$(powershell "$JOD_DIR/scripts/init/$INIT_SYS/state-install-jod.ps1" -NO_LOGS)
if ($STATUS_INSTALL.startsWith("ERROR_")) {
  logFat "Can't get Distribution's service state, error $STATUS_INSTALL" 7364
} elseif ( "$STATUS_INSTALL" -eq "Installed" ) {
  if ( !$FORCE ) {
    logWar "Distribution already installed, please uninstall distribution or set FORCE param"
    logScriptEnd $ERR_ALREADY_INSTALLED
  } else {
    logWar "Distribution already intalled, uninstall it"
    execScriptCommand "$JOD_DIR/uninstall.sh"
  }
}

logInf "Execute pre-install.ps1..."
if ( Test-Path "$JOD_DIR/scripts/pre-install.ps1" ) {
    execScriptCommand "$JOD_DIR/scripts/pre-install.ps1"
    if (!$?) {
        logWar "Error executing PRE install script, continue $LastExitCode"
    } elseif ($LastExitCode -gt 0) {
        logWar "Error executing PRE install script, exit $LastExitCode"
        $host.SetShouldExit($LastExitCode)
        exit $LastExitCode
    }
} else {
    logDeb "PRE install script not found, skipped (missing $JOD_DIR/scripts/pre-install.ps1)"
}

logInf "Installing distribution..."
$INIT_SYS=($OS_INIT_SYS.ToLower())
logTra "INIT_SY=$INIT_SYS"
execScriptCommand "$JOD_DIR/scripts/init/$INIT_SYS/install-jod.ps1"

logInf "Distribution installed successfully"

logInf "Execute post-install.ps1..."
if ( Test-Path "$JOD_DIR/scripts/post-install.ps1" ) {
  execScriptCommand "$JOD_DIR/scripts/post-install.ps1"
  if (!$?) {
      logWar "Error executing POST install script, continue $LastExitCode"
  } elseif ($LastExitCode -gt 0) {
      logWar "Error executing POST install script, exit $LastExitCode"
      $host.SetShouldExit($LastExitCode)
      exit $LastExitCode
  }
} else {
  logDeb "POST install script not found, skipped (missing $JOD_DIR/scripts/post-install.ps1)"
}

###############################################################################
logScriptEnd
