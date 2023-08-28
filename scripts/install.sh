#!/bin/bash

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
# bash $JOD_DIST_DIR/scripts/install.sh
#             [JOD_DIST_CONFIG_FILE=configs/configs.sh]
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

JOD_DIST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/.."
source "$JOD_DIST_DIR/scripts/libs/include.sh" "$JOD_DIST_DIR"
source "$JOD_DIST_DIR/scripts/jod_tmpl/include.sh" "$JOD_DIST_DIR"

#DEBUG=true
[[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs

setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

###############################################################################
logScriptInit

# Init JOD_DIST_CONFIG_FILE
JOD_DIST_CONFIG_FILE=${1:-configs/jod_dist_configs.sh}
[[ ! -f "$JOD_DIST_CONFIG_FILE" ]] && JOD_DIST_CONFIG_FILE="$JOD_DIST_DIR/$JOD_DIST_CONFIG_FILE"
[[ ! -f "$JOD_DIST_CONFIG_FILE" ]] && logFat "Can't find JOD Distribution config's file (missing file: $JOD_DIST_CONFIG_FILE)" $ERR_CONFIGS_NOT_FOUND
logScriptParam "JOD_DIST_CONFIG_FILE" "$JOD_DIST_CONFIG_FILE"

# Load jod distribution configs, exit if fails
execScriptConfigs $JOD_DIST_CONFIG_FILE

# Init INST_DIR
INST_DIR=${2:-$JOD_DIST_DIR/envs/$DIST_ARTIFACT-$DIST_VER/$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))}
logScriptParam "INST_DIR" "$INST_DIR"

DEST_DIR="$JOD_DIST_DIR/build/$DIST_ARTIFACT/$DIST_VER"

###############################################################################
logScriptRun

logInf "Run build.sh script -> $JOD_DIST_CONFIG_FILE"
execScriptCommand "$JOD_DIST_DIR/scripts/build.sh" $JOD_DIST_CONFIG_FILE

logInf "Copy JOD Distribution to installation dir"
rm -r "$INST_DIR" >/dev/null 2>&1
mkdir -p "$INST_DIR"
cp -r "$DEST_DIR/"* "$INST_DIR"
[ "$?" -ne 0 ] && logFat "Can't copy JOD Distribution from '$DEST_DIR/*' dir, exit." $ERR_GET_JOD_ASSEMBLED

logInf "JOD Distribution installed successfully to $INST_DIR"

###############################################################################
logScriptEnd
