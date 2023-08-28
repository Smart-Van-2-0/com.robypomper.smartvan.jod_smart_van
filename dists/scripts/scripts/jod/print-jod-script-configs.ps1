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
# powershell $JOD_DIR/print-jod-script-configs.ps1
#
# Print all env vars configured by $JOD_DIR/scripts/jod/jod-script-configs.ps1
# script.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([switch] $NO_LOGS=$false)

$JOD_DIR=(get-item $PSScriptRoot ).Parent.Parent.FullName
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

###############################################################################
logScriptRun

logInf "Print JOD scripts configs..."
Write-Host " JOD"
Write-Host " - JOD_DIR                    | $JOD_DIR"
Write-Host " - JOD_YML                    | $JOD_YML"
Write-Host " JOD_DIST"
Write-Host " - JOD_DIST_NAME              | $JOD_DIST_NAME"
Write-Host " - JOD_DIST_VER               | $JOD_DIST_VER"
Write-Host " JOD_INSTALLATION"
Write-Host " - JOD_INSTALLATION_HASH      | $JOD_INSTALLATION_HASH"
Write-Host " - JOD_INSTALLATION_NAME      | $JOD_INSTALLATION_NAME"
Write-Host " - JOD_INSTALLATION_NAME_DOT  | $JOD_INSTALLATION_NAME_DOT"
Write-Host " OS"
Write-Host " - OS_TYPE                    | $OS_TYPE"
Write-Host " - OS_INIT_SYS                | $OS_INIT_SYS"
Write-Host " JAVA:"
Write-Host " - JAVA_EXEC                  | $JAVA_EXEC"
Write-Host " - JAVA_DIR                   | $JAVA_DIR"
Write-Host " - JAVA_VER                   | $JAVA_VER"

logInf "JOD scripts configs printed successfully"

###############################################################################
logScriptEnd
