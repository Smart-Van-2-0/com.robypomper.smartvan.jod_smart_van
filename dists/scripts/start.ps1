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
# powershell $JOD_DIR/start.ps1 [FOREGROUND=false] [FORCE=false]
#
# This script, depending on ```FOREGROUND``` param, can run the JOD Instance
# in background (default) or in foreground (if ```FOREGROUND``` is ```true```).
# When executed in background mode, this script print kill and logs command
# for started instance, then exits. Otherwise, when executed in foreground mode
# the scripts wait until the started instance will stopped or killed.
#
# The ```FORCE``` param, prevent the script fail when current JOD Distribution is
# already running. When ```FORCE``` param is ```true``` and current JOD Distribution
# is running, then this script shutdown current JOD Distribution calling the
# [$JOD_DIR/shutdown.sh](#shutdown-jod) script.
#
# The JOD Instance is a Java application executed using the Java Virtual Machine
# specified by the ```$JAVA_EXEC``` [JOD Scripts Configs](#jod-scripts-configs).
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

# Init FOREGROUND
logScriptParam "FOREGROUND" "$FOREGROUND"

# Init FORCE
logScriptParam "FORCE" "$FORCE"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.ps1"

# Internal vars
$JAR_RUN="jospJOD.jar"
if ($null -eq $MAIN_CLASS) {
  if ($FOREGROUND) { $MAIN_CLASS="com.robypomper.josp.jod.JODShell" }
  else { $MAIN_CLASS="com.robypomper.josp.jod.JODDaemon" }
}
logTra "MAIN_CLASS=$MAIN_CLASS"
if ($OS_TYPE -eq "Win32") {$TMP_DIR=$env:TEMP} else {$TMP_DIR=$env:TMPDIR}
$PID_FILE="${TMP_DIR}$JOD_INSTALLATION_NAME_DOT.pid"
logTra "PID_FILE:$PID_FILE"

# Check current OS
failOnWrongOS

###############################################################################
logScriptRun

logInf "Check if distribution is already running..."
$JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
logTra "JOD_PID=$JOD_PID"
if ( $null -ne $JOD_PID) {
    if ($JOD_PID -eq "UnknownWinServiceId") {
        #logWar "Distribution installed as a service but not running, please re-install distribution"
        #logScriptEnd $ERR_ALREADY_RUNNING
        logWar "Distribution installed as a service but not running, start instance"
    } elseif ( !$FORCE) {
        logWar "Distribution already running, please shutdown distribution or set FORCE param"
        logScriptEnd $ERR_ALREADY_RUNNING
    } else {
        logWar "Distribution already running, stop it"
        execScriptCommand "$JOD_DIR/stop.ps1"}
}

logInf "Create logs dir..."
New-Item "$JOD_DIR/logs" -ItemType Directory -ea 0 | Out-Null

logInf "Execute pre-startup.ps1..."
if ( Test-Path "$JOD_DIR/scripts/pre-startup.ps1" ) {
    execScriptCommand "$JOD_DIR/scripts/pre-startup.ps1"
    if (!$?) {
        logWar "Error executing PRE startup script, continue $LastExitCode"
    } elseif ($LastExitCode -gt 0) {
        logWar "Error executing PRE startup script, exit $LastExitCode"
        $host.SetShouldExit($LastExitCode)
        exit $LastExitCode
    }
} else {
    logDeb "PRE startup script not found, skipped (missing $JOD_DIR/scripts/pre-startup.sh)"
}

if ($FOREGROUND) {
    logInf "Start JOD distribution in foreground..."
    logInf "Skip post-startup.sh because in FOREGROUND mode"
    logInf "Skip pre-shutdown.sh because in FOREGROUND mode"

    $CURRENT_DIR = $( Get-Location )
    Set-Location -Path $JOD_DIR
    .$JAVA_EXEC "-Dlog4j.configurationFile=log4j2.xml" -cp "$JAR_RUN" "$MAIN_CLASS" --configs="$JOD_YML" "$JOD_INSTALLATION_NAME_DOT"
    $EXIT_STATE = $?
    $EXIT_CODE = $LastExitCode
    if (!$EXIT_STATE -or $EXIT_CODE -gt 0) {
        logFat "JOD Distribution terminated with exit code $EXIT_CODE"
    } else {
        logInf "JOD distribution started and terminated successfully"
    }
    Set-Location -Path $CURRENT_DIR

    logInf "Execute post-shutdown.ps1..."
    if (Test-Path "$JOD_DIR/scripts/post-shutdown.ps1")
    {
        execScriptCommand "$JOD_DIR/scripts/post-shutdown.ps1"
        if (!$?)
        {
            logWar "Error executing POST shutdown script, continue $LastExitCode"
        }
        elseif ($LastExitCode -gt 0)
        {
            logWar "Error executing POST shutdown script, exit $LastExitCode"
            $host.SetShouldExit($LastExitCode)
            exit $LastExitCode
        }
    }
    else
    {
        logDeb "POST shutdown script not found, skipped (missing $JOD_DIR/scripts/post-shutdown.sh)"
    }

} else {

    logInf "Start JOD distribution in background..."

    #$CURRENT_DIR=$(Get-Location)
    #Set-Location -Path $JOD_DIR
    Start-Process $JAVA_EXEC `
        -WorkingDirectory "$JOD_DIR" `
        -WindowStyle Hidden `
        -ArgumentList "-Dlog4j.configurationFile=log4j2.xml", `
                      "-cp", "$JAR_RUN", "$MAIN_CLASS", `
                      "--configs=$JOD_YML", "$JOD_INSTALLATION_NAME_DOT"
    #Set-Location -Path $CURRENT_DIR

    $JOD_PID=$(powershell "$JOD_DIR/scripts/jod/get-jod-pid.ps1" -NO_LOGS)
    if ($null -eq $JOD_PID) {
      Write-Host "Error on startup JOD Daemon"
      Write-Host "To print daemon console logs:"
      Write-Host "    $ Get-Content -Path '$JOD_DIR/logs/jospJOD.log' -Tail 300 -Wait"
      logFat "Error on executing JOD Daemon."
    }
    Set-Content -Path $PID_FILE -Value "$JOD_PID"
    logInf "Daemon executed successfully with $JOD_PID process id"
    Write-Host "Execute following commands to kill this process:"
    Write-Host "    $ Stop-Process -Id $JOD_PID"
    Write-Host "To print daemon console logs:"
    Write-Host "    $ Get-Content -Path '$JOD_DIR/logs/jospJOD.log' -Tail 100 -Wait"

   logInf "Distribution started successfully"

    if ( Test-Path "$JOD_DIR/scripts/post-startup.ps1" ) {
      execScriptCommand "$JOD_DIR/scripts/post-startup.ps1"
      if (!$?) {
          logWar "Error executing POST startup script, continue $LastExitCode"
      } elseif ($LastExitCode -gt 0) {
          logWar "Error executing POST startup script, exit $LastExitCode"
          $host.SetShouldExit($LastExitCode)
          exit $LastExitCode
      }
    } else {
        logDeb "POST startup script not found, skipped (missing $JOD_DIR/scripts/post-startup.sh)"
    }

}

###############################################################################
logScriptEnd
