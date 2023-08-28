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
# bash $JOD_DIST_DIR/scripts/publish.sh
#             [JOD_DIST_CONFIG_FILE=configs/configs.sh]
#
# This script assemble and publish JOD Distribution to the
# [JOD Distribution list @ JOSP Docs](https://www.johnosproject.org/docs/References/JOD_Dists/Home)
# web page. This tasks generate the distributable files for current JOD Distribution
# and setup all info to publish it to the JOSP Docs.
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

SRC_DIR="$JOD_DIST_DIR/build/$DIST_ARTIFACT/$DIST_VER"
DEST_DIR="$JOD_DIST_DIR/build/publications"
DEST_FILE_TGZ="$JOD_DIST_DIR/build/publications/$DIST_ARTIFACT-$DIST_VER.tgz"
DEST_FILE_ZIP="$JOD_DIST_DIR/build/publications/$DIST_ARTIFACT-$DIST_VER.zip"

###############################################################################
logScriptRun

logInf "Run build.sh script -> $JOD_DIST_CONFIG_FILE"
execScriptCommand "$JOD_DIST_DIR/scripts/build.sh" $JOD_DIST_CONFIG_FILE

logInf "Compress JOD Distribution to publication dir"
rm -r "$DEST_DIR" >/dev/null 2>&1
mkdir -p "$DEST_DIR"
cd "$SRC_DIR" >/dev/null 2>&1
tar -czf "$DEST_FILE_TGZ" .
cd - >/dev/null 2>&1

cd "$SRC_DIR" >/dev/null 2>&1
if command -v zip &>/dev/null; then
  zip -qr "$DEST_FILE_ZIP" .
else
  logWar "'zip' command not installed, skip 'zip' compression"
fi
cd - >/dev/null 2>&1

logWar "Upload disabled because not yet implemented"
echo "####################"
echo "# MANUAL OPERATION #"
echo "####################"
echo "1. Build your JOD Distribution"
echo "   bash scripts/build.sh $JOD_DIST_CONFIG_FILE"
echo "2. Copy results files ({DIST_ARTIFACT}-{DIST_VER}.zip and {DIST_ARTIFACT}-{DIST_VER}.tgz) to public repository"
echo "3. Update public repository with new version links and references"

logInf "JOD Distribution published successfully"

###############################################################################
logScriptEnd
