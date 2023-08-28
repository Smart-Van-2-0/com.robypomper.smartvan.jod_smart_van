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
# powershell $JOD_DIST_DIR/scripts/install.ps1
#             [JOD_DIST_CONFIG_FILE=configs/configs.ps1]
#             [INST_DIR=$JOD_DIST_DIR/envs/{XXXX}/]
#
# This script assemble a JOD Distribution based on specified JOD_DIST_CONFIG_FILE
# file and copy it to INST_DIST dir. Then you can call scripts from INST_DIST to
# manage installed JOD instance.
#
# The JOD_DIST_CONFIG_FILE can be an absolute file path or a working dir relative
# path. Can be used also path relative to the distribution's project dir, for
# example the path 'configs/configs_test.sh' can be used also outside
# the $JOD_DIST_DIR folder.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param (
    [string] $JOD_DIST_CONFIG_FILE="configs/jod_dist_configs.ps1",
    [string] $INST_DIR=""
)

$JOD_DIST_DIR=(get-item $PSScriptRoot ).parent.FullName
.$JOD_DIST_DIR/scripts/libs/include.ps1 "$JOD_DIST_DIR"
.$JOD_DIST_DIR/scripts/jod_tmpl/include.ps1 "$JOD_DIST_DIR"

#$DEBUG=$true
if ( $NO_LOGS ) { INSTALL-LogsNone } elseif (($DEBUG -ne $null) -and ($DEBUG)) { INSTALL-LogsDebug } else { INSTALL-Logs }

setupCallerAndScript $PSCommandPath $MyInvocation.PSCommandPath

###############################################################################
logScriptInit

# Init JOD_DIST_CONFIG_FILE
if (!(Test-Path $JOD_DIST_CONFIG_FILE)) { $JOD_DIST_CONFIG_FILE="$JOD_DIST_DIR/$JOD_DIST_CONFIG_FILE" }
if (!(Test-Path $JOD_DIST_CONFIG_FILE)) { logFat "File '$JOD_DIST_CONFIG_FILE' not found" $ERR_CONFIGS_NOT_FOUND }
logScriptParam "JOD_DIST_CONFIG_FILE" "$JOD_DIST_CONFIG_FILE"

# Load jod distribution configs, exit if fails
execScriptConfigs $JOD_DIST_CONFIG_FILE

# Init INST_DIR
if ($INST_DIR -eq "") { $INST_DIR="$JOD_DIST_DIR/envs/$DIST_ARTIFACT-$DIST_VER/$((Get-Random -Maximum 10))$((Get-Random -Maximum 10))$((Get-Random -Maximum 10))$((Get-Random -Maximum 10))" }
logScriptParam "INST_DIR" "$INST_DIR"

$DEST_DIR="$JOD_DIST_DIR/build/$DIST_ARTIFACT/$DIST_VER"

###############################################################################
logScriptRun

logInf "Run build.sh script -> $JOD_DIST_CONFIG_FILE"
execScriptCommand "$JOD_DIST_DIR/scripts/build.ps1" $JOD_DIST_CONFIG_FILE

logInf "Copy JOD Distribution to installation dir"
Remove-Item -Recurse -Force $INST_DIR -ea 0
New-Item $INST_DIR -ItemType Directory -ea 0 | Out-Null
Copy-Item "$DEST_DIR/*" -Destination "$INST_DIR" -Recurse       # ON ERROR -> $ERR_GET_JOD_ASSEMBLED

logInf "JOD Distribution installed successfully from $DEST_DIR to $INST_DIR"

###############################################################################
logScriptEnd
