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
# powershell $JOD_DIR/scripts/get-jod-pid.ps1 [NO_LOGS]
#
# Print current distribution process's ID.
#
# NO_LOGS           if true all logs are disabled, only PID is printed
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([switch] $NO_LOGS=$false)

$JOD_DIR=(get-item $PSScriptRoot ).Parent.Parent.FullName
.$JOD_DIR/scripts/libs/include.ps1 "$JOD_DIR"

#$DEBUG=$true
if ( $NO_LOGS ) { INSTALL-LogsNone } elseif (($null -ne $DEBUG) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

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

logInf "Querying for distribution PID..."

$sudoExit=sudo "$ScriptFullPath" -NO_LOGS -Status -ServiceId $JOD_INSTALLATION_NAME_DOT  #$ScriptParams
if ($sudoExit -ne 0) {
    logFat "Error on executing '$OriginalScriptName' -Status script ($sudoExit)" 123
}
$JOD_SERVICE_STATUS=$Env:SUDO_OUT
#$JOD_SERVICE_STATUS=$(powershell "$JOD_DIR/scripts/init\wininitsys\JodServiceRunAsAdmin.ps1 -ServiceId $JOD_INSTALLATION_NAME_DOT -Status -NO_LOGS")
if ($JOD_SERVICE_STATUS -eq "Running") {
    logInf "Querying 'JodService.ps1' script for distribution PID..."
    $sudoExit=sudo "$ScriptFullPath" -NO_LOGS -GetPID -ServiceId $JOD_INSTALLATION_NAME_DOT  #$ScriptParams
    if ($sudoExit -ne 0) {
        logFat "Error on executing '$OriginalScriptName' -GetPID script ($sudoExit)" 123
    }
    $JOD_SERVICE_PID=$Env:SUDO_OUT
    #$JOD_SERVICE_PID=$(powershell "$JOD_DIR/scripts/init\wininitsys\JodServiceRunAsAdmin.ps1 -ServiceId $JOD_INSTALLATION_NAME_DOT -GetPID -NO_LOGS")
    if ($null -ne $JOD_SERVICE_PID) {
        Write-Host $JOD_SERVICE_PID
    } else {
        Write-Host "UnknownWinServiceId"
    }


} else {
    #logTra 'ps aux | grep -v \"grep\" | grep \"$JOD_INSTALLATION_NAME_DOT\" | awk '{print $2}''

    try {
        logInf "Querying 'jps' script for distribution PID..."
        $pinfo=[string]$(jps -m | Select-String -Pattern "$JOD_INSTALLATION_NAME_DOT")
        if ($null -ne $pinfo) {
            $JOD_PID=$pinfo.SubString(0,$pinfo.IndexOf(" "))
            Write-Host $JOD_PID
        }

    } catch {
        $spid = $null
        # To looking for powershell process parent of java process
        $processes = @(Get-WmiObject Win32_Process -filter "Name = 'java.exe'" | Where-Object {
            $_.CommandLine -match ".*jospJOD\.jar.*$JOD_INSTALLATION_NAME_DOT.*"
        })
        foreach ($process in $processes) { # There should be just one, but be prepared for surprises.
            $spid = $process.ProcessId
            $scmdline = $process.CommandLine
            Write-Verbose "$serviceName Process ID = $spid"
        }
	if ($null -ne $spid) {
            Write-Host $spid
        }
        
        
        
    }
}

logInf "Distribution PID queried successfully"

###############################################################################
logScriptEnd
