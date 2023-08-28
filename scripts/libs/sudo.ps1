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
# Artifact: Robypomper PowerShell Utils
# Version:  1.0.3
###############################################################################

$SUDO_ERR_SCRIPT_NOT_FOUND=1
$SUDO_ERR_USER_DENIED=2 #$EXIT_CODE_ERROR_AccessDenied
$SUDO_ERR_START_UNKNOWN=3
$SUDO_ERR_INTERNAL_SCRIPT=4
$SUDO_ERR_EXEC_SCRIPT=5

# Execute a script as Administrator
#
# $1 script's path
# $2 if true, display only executed script's output
# $3 extra params to pass to the script execution
function sudo() {
    param (
        [Parameter(Mandatory=$true)][string]$Script,
        [switch] $NO_LOGS=$false,
        [Parameter(ValueFromRemainingArguments,Mandatory=$false)][string[]]$Remaining
    )

    for ($i = 0; $i -lt $Remaining.Count; $i++) {
        $a=$Remaining[$i];
        if ($a.startsWith("-")) { $args += " $($Remaining[$i])" }
        else { $args += " ```'$($Remaining[$i])```'" }
    }

    # Check script file
    $ScriptItem=(get-item "$Script" -ea 0)
    if (!$ScriptItem) {
        $Error=[string]$Error
        if ($Error.StartsWith("Cannot find path")) {
            logWar "Can't runAsAdmin specified script because file can't be found ($Script)"
            return $SUDO_ERR_SCRIPT_NOT_FOUND
        }
    }

    # Set script and log files's vars
    $ScriptFile=$ScriptItem.FullName
    $ScriptName=$ScriptItem.Name
    $ScriptDir=$ScriptItem.Directory.FullName
    $LogDir=$ScriptDir
    $LogName="$($ScriptName)_log_tmp"
    $LogFile="$LogDir/$LogName"
    $LogPrefix= "sudo.ps1"                      # Add-Content "$LogFile" -Value "[$PID] $LogPrefix ..."
    $LogPrefixInternal= "sudo.ps1[internal]"    # $argStr += " Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal ...'); "
    $application="powershell.exe"
    $argStr = "-executionpolicy bypass ";
    $argStr += "-command ";
    $argStr += "try { ";
    $argStr += "    if (!`$$NO_LOGS) { "
    $argStr += "        Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal Start script from $PID (caller) to ' + `$PID + ' (called) at $(Get-Date -Format "MM/dd/yyyy_HH:mm")'); "
    $argStr += "        Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal Start script $($ScriptFile)'); "
    $argStr += "    }; "
    #$argStr += "    Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal powershell $ScriptFile $args'); "
    $argStr += "    `$pwshOut=powershell $ScriptFile $args; "
    $argStr += "    `$exitMsg=`$('' + `$? + '/' + `$LastExitCode + ' (exits/exitCode)'); "
    $argStr += "    `$exitCode=`$LastExitCode;"
    $argStr += "    if (!`$$NO_LOGS) { "
    $argStr += "        foreach (`$l in `$pwshOut) { "
    $argStr += "            Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal > ' + `$l); "
    $argStr += "        } "
    $argStr += "    } "
    $argStr += "    else { "
    $argStr += "        foreach (`$l in `$pwshOut) { "
    $argStr += "            Add-Content '$LogFile' -Value `$l "
    $argStr += "        } "
    $argStr += "    }; "
    $argStr += "    Add-Content '$LogFile' -Value `$exitSuccess; "
    $argStr += "    if (`$exitCode -ne 0) { "
    $argStr += "        if (!`$$NO_LOGS) { Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal Script executed and returned ' + `$exitMsg) }"
    $argStr += "        Add-Content '$LogFile' -Value 'ERROR_EXEC_SCRIPT'"
    $argStr += "    }; "
    $argStr += "} catch { "
    $argStr += "    if (!`$$NO_LOGS) { Add-Content '$LogFile' -Value `$('[' + `$PID + '] $LogPrefixInternal Script throwed an exception (' + `$Error + ')') }"
    $argStr += "    else { Add-Content '$LogFile' -Value `$('Exception:  (' + `$Error + '/' + `$PSItem.InvocationInfo.PositionMessage + ')') };"
    $argStr += "} "
    #$argStr += "Start-Sleep 2; "

    if (!$NO_LOGS) { logInf "Running script '$($ScriptItem.FullName)' as Administrator..." }
    if (!$NO_LOGS) { Add-Content "$LogFile" -Value "[$PID] $LogPrefix Start script from $PID powershell's process" }

    # Exec JodService.ps1 as admin via start-process
    try {
        $p=Start-Process -FilePath $application `
                        -ArgumentList  $argStr `
                        -Verb RunAs `
                        -Wait `
                        -PassThru `
                        -WindowStyle Hidden
        #               -ArgumentList "-executionpolicy bypass -command if (`$$NO_LOGS) { Add-Content '$LogFile' -Value `$('[' + `$PID + '] JODSRAA.ps1(RunAs) RunAsAdmin start script from $PID (caller) to ' + `$PID + ' (called) at $(Get-Date -Format "MM/dd/yyyy_HH:mm")')}; `$pwshOut=powershell $ScriptFile $args; Add-Content '$LogFile' -Value `$('[' + `$PID + '] JODSRAA.ps1(RunAs) OutPut: ' + `$pwshOut); start-sleep 5" `
        #               -ArgumentList  "-executionpolicy bypass -command Write-Host 'Ciao'; Start-Sleep 5;" `
        $pExits=$?
        $pExitCode=$p.ExitCode
        #Write-Host "Args: $($p.StartInfo.Arguments)"

    } catch {
        $ErrorStr=[string]$Error
        if ($ErrorStr.contains("The operation was canceled by the user")) {
            logWar "To run this command you must allow it to run as admin"
            return $SUDO_ERR_USER_DENIED
        }

        logWar "Unknown error on start-process: $Error"
        return $SUDO_ERR_START_UNKNOWN
    }

    # Print execution exits on log file
    $pExitCode=$p.ExitCode
    if ($pExitCode -ne 0) {
        if (!$NO_LOGS) { Add-Content "$LogFile" -Value "[$PID] $LogPrefix ERROR script execution failed with '$pExitCode' exit code" }
        if (!$NO_LOGS) { Add-Content "$LogFile" -Value "[$PID] $LogPrefix       Probably error on (RunAs) code, the sudo.ps1's internal script." }
    } else {
        if (!$NO_LOGS) { Add-Content "$LogFile" -Value "[$PID] $LogPrefix script executed successfully from '$PID' poershell's process $pExits/$pExitCode (exits/exitCode)" }
    }

    # Print log file to console
    if (Test-Path $LogFile ) {
        $log=Get-Content "$LogFile"
        $Env:SUDO_OUT=($log) -join "`n"
        if ($log -eq "") {
            if ( $NO_LOGS ) { Write-Host "EMPTY_LOG_FILE" }
            else { logWar "Empty log file, no content to display" }
        } else {
            foreach ($l in $log) {
                if ( !$NO_LOGS ) { logInf "$($ScriptName): $l" }
                #else { Write-Host $l }
            }
        }
        Remove-Item "$LogFile" -ea 0
    } else {
        if ( $NO_LOGS ) { Write-Host "NO_LOG_FILE" }
        else { logWar "No log file, no content to display" }
    }

    # Print execution exits to console
    if ($null -ne $log -and ($log[$log.Count-1] -eq "ERROR_EXEC_SCRIPT" -or $log[$log.Count-2] -eq "ERROR_EXEC_SCRIPT")) {
        logWar "Error on running script"
        return $SUDO_ERR_EXEC_SCRIPT
    } elseif ($pExitCode -ne 0) {
        logWar "Error on running as admin (exit code=$pExitCode)"
        return $SUDO_ERR_INTERNAL_SCRIPT
    } else {
        If (!$NO_LOGS) { logInf "Script '$ScriptFile' runned as Administrator successfully" }
        return 0
    }

}
