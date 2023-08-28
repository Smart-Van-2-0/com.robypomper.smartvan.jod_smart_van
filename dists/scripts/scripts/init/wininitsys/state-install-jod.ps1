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
# powershell $JOD_DIR/scripts/init/wininitsys/state-install-jod.ps1 [NO_LOGS]
#
# Check if current distribution is installed as daemon on current machine.
#
# This is a placeholder file that return always fatal error because not implemented.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([switch] $NO_LOGS=$false)

$JOD_DIR=(get-item $PSScriptRoot ).Parent.Parent.Parent.FullName
.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"

#$DEBUG=$true
if (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

."$JOD_DIR/scripts/jod/jod-script-configs.ps1"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.ps1"

###############################################################################
logScriptInit

# Init NO_LOGS (PRE initialized)
logScriptParam "NO_LOGS" "$NO_LOGS"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.ps1"

###############################################################################
logScriptRun

$ScriptPath="$JOD_DIR/scripts/init\wininitsys"
$OriginalScriptName="JodService.ps1"
$ScriptFullPath="$ScriptPath/$OriginalScriptName"
$ScriptParams="-Verbose"

$sudoExit=sudo "$ScriptFullPath" -NO_LOGS -Status -ServiceId $JOD_INSTALLATION_NAME_DOT  #$ScriptParams
if ($sudoExit -eq 0) {
    if ($Env:SUDO_OUT -eq "Running" -or $Env:SUDO_OUT -eq "Stopped") { Write-Host "Installed" }
    else { Write-Host "Not Installed" }
    return
}

logFat "Error on executing '$OriginalScriptName' script ($sudoExit)" 123

###############################################################################
logScriptEnd
                