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
# Artifact: JOD Dist Template
# Version:  1.0.3
################################################################################

# Initialize all JOD Scripts configs. Env vars used by JOD Distributions scripts.
# After executing the '$JOD_SCRIPT_CONFIG' file that contains customized (by Maker)
# values, this method initialize (if not customized by Maker) following configs:
# - JOD_DIR:                    JOD object's main folder, not editable
# - JOD_YML:                    JOD object's main config file, used by JOD execution as java params and by jod/get-jod-{proeprty}.sh scripts
# - JOD_DIST_NAME:              the JOD Distribution's name, not editable
# - JOD_DIST_VER:               the JOD Distribution's version, not editable
# - JOD_INSTALLATION_HASH:      unique JOD instance code (equals to JOD_DIR's hash code), not editable
# - JOD_INSTALLATION_NAME:      unique JOD instance name (compose by '$JOD_DIST_NAME-$JOD_INSTALLATION_HASH'), not editable
# - JOD_INSTALLATION_NAME_DOT:  like $JOD_INSTALLATION_NAME but without spaces, not editable
# - OS_TYPE:                    detectOS method, not editable
# - OS_INIT_SYS:                detectInitSystem method, not editable
# - JAVA_EXEC:                  Java JVM executable
# - JAVA_DIR:                   Folder of the JAVA_EXEC JVM, not editable
# - JAVA_VER:                   Version of the JAVA_EXEC JVM, not editable
#
# $1 configs.sh for JOD script's full path

function setupJODScriptConfigs() {

  param (
    [Parameter(Mandatory)][string]$jodConfigsScript
  )

  # Check if already executed
  if ($__JOD_SCRIPT_CONFIGS -ne $null) { return }

  # Load custom configs
  $global:JOD_SCRIPT_CONFIG=$jodConfigsScript
  if ( Test-Path -Path $jodConfigsScript ) {
    execScriptConfigs $jodConfigsScript
  } else {
    logFat "File 'configs.ps1' for JOD script's not found ($jodConfigsScript), exit" $ERR_LOAD_SCRIPT_CONFIG
  }

  # Get JOD_DIR
  $global:JOD_DIR=$(findFileInParents "$global:CALLER_PATH" "start.sh")
  if ( $global:JOD_DIR -eq $null) {
    $global:JOD_DIR=$(findFileInParents "$global:SCRIPT_PATH" "start.sh")
    if ( $global:JOD_DIR -eq $null ) {
      logFat "Can't detect JOD_DIR (please run this script within the JOD installation folder), exit" $ERR_DETECT_SCRIPT_CONFIG
    }
  }

  # Load distribution's configs
  $global:JOD_DISTRIBUTION_SCRIPT_CONFIG="$global:JOD_DIR/configs/dist_configs.ps1"
  if ( Test-Path -Path $global:JOD_DISTRIBUTION_SCRIPT_CONFIG ) {
    execScriptConfigs $global:JOD_DISTRIBUTION_SCRIPT_CONFIG
  } else {
    "File 'dist_configs.ps1' for JOD script's not found ($JOD_DISTRIBUTION_SCRIPT_CONFIG), skip"
  }

  # Get JOD_YML, set from $JOD_SCRIPT_CONFIG
  if ( $JOD_YML -eq $null ) { $global:JOD_YML="$JOD_DIR/configs/jod.yml" }

  # Get JOD_DIST_NAME, set from $JOD_DISTRIBUTION_SCRIPT_CONFIG
  if ( $JOD_DIST_NAME -eq $null ) { $global:JOD_DIST_NAME="JOD Custom Distribution" }

  # Get JOD_DIST_VER, set from $JOD_DISTRIBUTION_SCRIPT_CONFIG
  if ( $JOD_DIST_VER -eq $null ) { $global:JOD_DIST_VER="Unknown" }

  # Get OS_TYPE
  $global:OS_TYPE="$(detectOS)"
  if ( $global:OS_TYPE.StartsWith("Unknown") ) {
    logFat "Can't detect OS_TYPE ($OS_TYPE), exit" $ERR_DETECT_SCRIPT_CONFIG
  }

  # Get JOD_INSTALLATION_HASH
  $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
  $utf8 = New-Object -TypeName System.Text.UTF8Encoding
  $global:JOD_INSTALLATION_HASH = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($JOD_DIR)))
  $global:JOD_INSTALLATION_HASH = $JOD_INSTALLATION_HASH.ToLower() -replace '-', ''

  # Get JOD_INSTALLATION_NAME
  $global:JOD_INSTALLATION_NAME="$JOD_DIST_NAME-$JOD_INSTALLATION_HASH"

  # Get JOD_INSTALLATION_NAME_DOT
  $global:JOD_INSTALLATION_NAME_DOT=$JOD_INSTALLATION_NAME.ToLower().replace(" ",".").replace("-","_")

  # Get OS_INIT_SYS
  $global:OS_INIT_SYS="$(detectInitSystem)"
  if ( $global:OS_INIT_SYS.StartsWith("Unknown") ) {
    logFat "Can't detect OS_INIT_SYS ($OS_INIT_SYS), exit" $ERR_DETECT_SCRIPT_CONFIG
  }

  # Get JAVA_EXEC
  if ( ($JAVA_HOME -ne "")  -and (Test-Path -Path "$JAVA_HOME/bin/java" ) ) {
    $javaPlace="JAVA_HOME"
    $global:JAVA_EXEC="$JAVA_HOME/bin/java"
  #} elseif (type -p java &>/dev/null) {
  } elseif ( (get-command java).Path ) {
    $javaPlace="PATH"
    $global:JAVA_EXEC="java"
  } else {
    logFat "Can't detect JAVA_EXEC (please check java installation and JAVA_HOME or PATH environment vars), exit" $ERR_DETECT_SCRIPT_CONFIG
  }

  # Get JAVA_DIR
  if ( $javaPlace -eq "PATH" ) {
    if ( $OS_TYPE -eq "MacOS" ) {
      $global:JAVA_DIR=$env:JAVA_HOME
    } else {
      $global:JAVA_DIR=$(Resolve-Path -Path ((Get-Command -Name java).Path))
    }
  } else {
    $global:JAVA_DIR=$(Split-Path -Parent (Get-Command -Name "$JAVA_EXEC").Path)
  }

  # Get JAVA_VER
  $global:JAVA_VER=$(.$global:JAVA_EXEC -version 2>&1)
  $global:JAVA_VER=[regex]::Match($global:JAVA_VER,'"(.*)"').captures.groups[1].value

  # Set JOD script's configs.sh executed
  $global:__JOD_SCRIPT_CONFIGS=1
}
