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
# powershell $JOD_DIST_DIR/scripts/build.ps1 [JOD_DIST_CONFIG_FILE=configs/jod_dist_configs.ps1]
#
# This script assemble a JOD Distribution based on specified JOD_DIST_CONFIG_FILE
# file.
#
# The JOD_DIST_CONFIG_FILE can be an absolute file path or a working dir relative
# path. Can be used also path relative to the distribution's project dir, for
# example the path 'configs/configs_test.sh' can be used also outside
# the $JOD_DIST_DIR folder.
#
# The generated JOD Distribution is build in 'build/$DIST_ARTIFACT/$DIST_VER'
# folder.
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

param ([string] $JOD_DIST_CONFIG_FILE="configs/jod_dist_configs.ps1")

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

$DEST_DIR="$JOD_DIST_DIR/build/$DIST_ARTIFACT/$DIST_VER"
$CACHE_DIR="$JOD_DIST_DIR/build/cache"
$JOD_JAR="$CACHE_DIR/jospJOD-$DIST_JOD_VER.jar"
$JOD_URL="https://repo.maven.apache.org/maven2/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER.jar"
$JOD_LOCAL_MAVEN="$HOME/.m2/repository/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER.jar"
$JOD_DEPS_JAR="$CACHE_DIR/jospJOD-$DIST_JOD_VER-deps.jar"
$JOD_DEPS_URL="https://repo.maven.apache.org/maven2/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER-deps.jar"
$JOD_DEPS_LOCAL_MAVEN="$HOME/.m2/repository/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER-deps.jar"

logInf "Load JOD Distribution configs..."

# DIST_JCP_ENV
if (-not ($DIST_JCP_ENV)) { $DIST_JCP_ENV = 'stage' }
if ($DIST_JCP_ENV -eq 'local') {
    $DIST_JCP_ENV_API="localhost:9001"
    $DIST_JCP_ENV_AUTH="localhost:8998"
} elseif ($DIST_JCP_ENV -eq 'stage') {
    $DIST_JCP_ENV_API="api-stage.johnosproject.org"
    $DIST_JCP_ENV_AUTH="auth-stage.johnosproject.org"
} elseif ($DIST_JCP_ENV -eq 'prod') {
    $DIST_JCP_ENV_API="api.johnosproject.org"
    $DIST_JCP_ENV_AUTH="auth.johnosproject.org"
} else {
    logFat "Invalid 'DIST_JCP_ENV'='$DIST_JCP_ENV' value, accepted values: 'prod', 'stage', 'local'. Exit" $ERR_CONFIGS_INVALID_DIST_JCP_ENV
}

# DIST_JCP_ID
if ( -not ($DIST_JCP_ID) ) { logFat "JCP Auth id not set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_MISSING_DIST_JCP_ID }

# DIST_JCP_SECRET
if ( -not ($DIST_JCP_SECRET) ) { logFat "JCP Auth secret not set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_MISSING_DIST_JCP_SECRET }

#DIST_JOD_NAME

# DIST_JOD_ID
if ($DIST_JCP_ENV -eq "prod" -and $DIST_JOD_ID) { logFat "Can't build a prod (DIST_JCP_ENV config) distribution when the DIST_JOD_ID config is set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_ILLEGAL_JOD_ID }
if ($DIST_JOD_ID) { $DIST_JOD_ID_HW=$DIST_JOD_ID.SubString(0,5)}

# DIST_JOD_WORK_PULLERS
if ( $DIST_JOD_VER -eq "2.2.0" ) { $SHELL_PULLER="PullerUnixShell" } else { $SHELL_PULLER="PullerShell"}
if ( -not ($DIST_JOD_WORK_PULLERS) ) { $DIST_JOD_WORK_PULLERS="shell://com.robypomper.josp.jod.executor.$SHELL_PULLER http://com.robypomper.josp.jod.executor.impls.http.PullerHTTP" }

## DIST_JOD_WORK_LISTENERS
if ( -not ($DIST_JOD_WORK_LISTENERS) ) { $DIST_JOD_WORK_LISTENERS="file://com.robypomper.josp.jod.executor.ListenerFiles" }

## DIST_JOD_WORK_EXECUTORS
if ( $DIST_JOD_VER -eq "2.2.0" ) { $SHELL_EXECUTOR="ExecutorUnixShell" } else { $SHELL_EXECUTOR="ExecutorShell"}
if ( -not ($DIST_JOD_WORK_EXECUTORS) ) { $DIST_JOD_WORK_EXECUTORS="shell://com.robypomper.josp.jod.executor.$SHELL_EXECUTOR file://com.robypomper.josp.jod.executor.ExecutorFiles http://com.robypomper.josp.jod.executor.impls.http.ExecutorHTTP" }

# DIST_JOD_CONFIG_TMPL
if ( -not ($DIST_JOD_CONFIG_TMPL) ) { $DIST_JOD_CONFIG_TMPL="dists/configs/jod_TMPL.yml" }

# DIST_JOD_CONFIG_LOGS_TMPL
if ( -not ($DIST_JOD_CONFIG_LOGS_TMPL) ) { $DIST_JOD_CONFIG_LOGS_TMPL="dists/configs/log4j2_TMPL.xml" }

# DIST_JOD_STRUCT: jod's structure file, path from $JOD_DIST_DIR      ; default: dists/configs/struct.jod
if ( -not ($DIST_JOD_STRUCT) ) { $DIST_JOD_STRUCT="dists/configs/struct.jod" }

# $DIST_JOD_OWNER: josp user's id            ; default: "00000-00000-00000" as Anonymous user
if ( -not ($DIST_JOD_OWNER) ) { $DIST_JOD_OWNER="00000-00000-00000" }

# $DIST_JOD_COMM_DIRECT_ENABLED: "true|false"              ; default: "true"
if ( -not ($DIST_JOD_COMM_DIRECT_ENABLED) ) { $DIST_JOD_COMM_DIRECT_ENABLED=$true }

# $DIST_JOD_COMM_CLOUD_ENABLED: "true|false"              ; default: "true"
if ( -not ($DIST_JOD_COMM_CLOUD_ENABLED) ) { $DIST_JOD_COMM_CLOUD_ENABLED=$true }

logInf "JOD Distribution configs loaded successfully"

###############################################################################
logScriptRun

logInf "Build JOD Distribution..."

logDeb "Clean an reacreate JOD Distribution build dirs"
Remove-Item -Recurse -Force $DEST_DIR -ea 0
New-Item $DEST_DIR -ItemType Directory -ea 0 | Out-Null
New-Item $DEST_DIR/configs -ItemType Directory -ea 0 | Out-Null
New-Item $DEST_DIR/libs -ItemType Directory -ea 0 | Out-Null
New-Item $DEST_DIR/scripts -ItemType Directory -ea 0 | Out-Null

logDeb "Prepare JOD library"
if ( -not (Test-Path $JOD_JAR) ) {
    logDeb "Download JOD library from $JOD_URL"
    New-Item $CACHE_DIR -ItemType Directory -ea 0 | Out-Null
    try {
        Invoke-WebRequest -Uri "$JOD_URL" -OutFile "$JOD_JAR"
    } catch {
        logWar "Can't download JOD library from '$JOD_URL' url, try on local maven repository"
        if ( (Test-Path $JOD_LOCAL_MAVEN) ) {
            Copy-Item "$JOD_LOCAL_MAVEN" -Destination "$JOD_JAR"
        } else {
            logWar "Can't found JOD library in local maven repository at '$JOD_LOCAL_MAVEN'"
            logFat "Can't get JOD library, exit." $ERR_GET_JOD_LIB
        }
    }
}
Copy-Item "$JOD_JAR" -Destination "$DEST_DIR/libs"
Copy-Item "$JOD_JAR" -Destination "$DEST_DIR/jospJOD.jar"

logDeb "Prepare JOD dependencies"
if ( -not (Test-Path $JOD_DEPS_JAR) ) {
    logDeb "Download JOD dependencies from $JOD_DEPS_URL"
    New-Item $CACHE_DIR -ItemType Directory -ea 0 | Out-Null
    try {
        Invoke-WebRequest -Uri "$JOD_DEPS_URL" -OutFile "$JOD_DEPS_JAR"
    } catch {
        logWar "Can't download JOD dependencies from '$JOD_DEPS_URL' url, try on local maven repository"
        if ( (Test-Path $JOD_DEPS_LOCAL_MAVEN) ) {
            Copy-Item "$JOD_DEPS_LOCAL_MAVEN" -Destination "$JOD_DEPS_JAR"
        } else {
            logWar "Can't found JOD dependencies in local maven repository at '$JOD_DEPS_LOCAL_MAVEN'"
            logFat "Can't get JOD dependencies, exit." $ERR_GET_JOD_DEPS_LIB
        }
    }
}
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory("$JOD_DEPS_JAR", "$DEST_DIR/libs/")

logDeb "Generate JOD main configs 'jod.yml' file"
(Get-Content "$JOD_DIST_DIR/$DIST_JOD_CONFIG_TMPL") | Foreach-Object {
    $_ -replace '%DIST_JCP_ENV_API%', "$DIST_JCP_ENV_API" `
    -replace '%DIST_JCP_ENV_AUTH%', "$DIST_JCP_ENV_AUTH" `
    -replace '%DIST_JCP_ID%', "$DIST_JCP_ID" `
    -replace '%DIST_JCP_SECRET%', "$DIST_JCP_SECRET" `
    -replace '%DIST_JOD_NAME%', "$DIST_JOD_NAME" `
    -replace '%DIST_JOD_ID%', "$DIST_JOD_ID" `
    -replace '%DIST_JOD_ID_HW%', "$DIST_JOD_ID_HW" `
    -replace '%DIST_JOD_WORK_PULLERS%', "$DIST_JOD_WORK_PULLERS" `
    -replace '%DIST_JOD_WORK_LISTENERS%', "$DIST_JOD_WORK_LISTENERS" `
    -replace '%DIST_JOD_WORK_EXECUTORS%', "$DIST_JOD_WORK_EXECUTORS" `
    -replace '%DIST_JOD_OWNER%', "$DIST_JOD_OWNER" `
    -replace '%DIST_JOD_COMM_DIRECT_ENABLED%', "$DIST_JOD_COMM_DIRECT_ENABLED" `
    -replace '%DIST_JOD_COMM_CLOUD_ENABLED%', "$DIST_JOD_COMM_CLOUD_ENABLED" `
    } | Set-Content "$DEST_DIR/configs/jod.yml"

logDeb "Generate JOD logs configs 'log4j2.xml' file"
(Get-Content "$JOD_DIST_DIR/$DIST_JOD_CONFIG_LOGS_TMPL") | Foreach-Object {
    $_ -replace '%DIST_JOD_VER%', "$DIST_JOD_VER" `
    } | Set-Content "$DEST_DIR/log4j2.xml"

logDeb "Copy JOD Distribution configs"
if ( -not (Test-Path $JOD_DIST_DIR/$DIST_JOD_STRUCT) ) {
    logFat "Can't include 'struct.jod' to JOD Distribution because can't find file '$JOD_DIST_DIR/$DIST_JOD_STRUCT'" $ERR_GET_DIST_JOD_STRUCT
}
Copy-Item "$JOD_DIST_DIR/$DIST_JOD_STRUCT" -Destination "$DEST_DIR/configs/struct.jod"
if ( -not (Test-Path $JOD_DIST_DIR/dists/configs/jod_configs.sh) ) {
    logFat "Can't include 'jod_configs.sh' to JOD Distribution because can't find file '$JOD_DIST_DIR/dists/configs/jod_configs.sh" $ERR_GET_JOD_CONFIGS
}
Copy-Item "$JOD_DIST_DIR/dists/configs/jod_configs.sh" -Destination "$DEST_DIR/configs/configs.sh"
if ( -not (Test-Path $JOD_DIST_DIR/dists/configs/jod_configs.ps1) ) {
    logFat "Can't include 'jod_configs.ps1' to JOD Distribution because can't find file '$JOD_DIST_DIR/dists/configs/jod_configs.ps1" $ERR_GET_JOD_CONFIGS
}
Copy-Item "$JOD_DIST_DIR/dists/configs/jod_configs.ps1" -Destination "$DEST_DIR/configs/configs.ps1"

logDeb "Generate JOD Distribution dist_configs.sh and dist_configs.ps1"
$DIST_CONFIGS_SH="#!/bin/bash
export JOD_DIST_NAME=`"$DIST_ARTIFACT`"
export JOD_DIST_VER=`"$DIST_VER`"
"
Set-Content -Path "$DEST_DIR/configs/dist_configs.sh" -Value $DIST_CONFIGS_SH
#(Get-Content "$DEST_DIR/configs/dist_configs.sh" | Out-String) -replace "`r`n", "`n" | Out-File "$DEST_DIR/configs/dist_configs.sh"
$DIST_CONFIGS_PS="#!/usr/bin/env powershell
$"+"global:JOD_DIST_NAME='$DIST_ARTIFACT'
$"+"global:JOD_DIST_VER='$DIST_VER'"
Set-Content -Path "$DEST_DIR/configs/dist_configs.ps1" -Value $DIST_CONFIGS_PS

logDeb "Copy JOD Distribution scripts"
if ( -not (Test-Path "$JOD_DIST_DIR/dists/scripts") ) {
    logFat "Can't include 'scripts' dir to JOD Distribution because can't copy dir '$JOD_DIST_DIR/dists/scripts'" $ERR_GET_JOD_SCRIPTS
}
Copy-Item "$JOD_DIST_DIR/dists/scripts/*" -Destination "$DEST_DIR" -Recurse -ea 0

logDeb "Copy JOD Distribution resources"
if ( -not (Test-Path "$JOD_DIST_DIR/dists/resources") ) {
    logFat "Can't include 'resources' dir to JOD Distribution because can't copy dir '$JOD_DIST_DIR/dists/resources'" $ERR_GET_JOD_RESOURCES
}
Copy-Item "$JOD_DIST_DIR/dists/resources/*" -Destination "$DEST_DIR" -Recurse -ea 0

logDeb "Generate JOD Distribution VERSIONS.md"
$VERSION="# JOD '$DIST_NAME' Distribution

JOD Distribution Version:           $DIST_VER
JOD Distribution TEMPLATE Version:  $JOD_TMPL_VERSION
JOD included Version:               $DIST_JOD_VER"
Set-Content -Path "$DEST_DIR/VERSIONS.md" -Value $VERSION

logInf "JOD Distribution built successfully"

###############################################################################
logScriptEnd
