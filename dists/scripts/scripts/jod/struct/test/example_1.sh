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

################################################################################
# Artifact: JOD Dist Template
# Version:  1.0.3
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
source "$SCRIPT_DIR/../builder.sh"

AUDIO_VOLUME=$(buildComponent "Volume" "BooleanState" "listener" "proto://configs")
AUDIO_MUTE=$(buildComponent "Mute" "BooleanState" "listener" "proto://configs")
AS=("$AUDIO_VOLUME" "$AUDIO_MUTE")
AUDIO=$(buildComponent "Audio" "Container" "${AS[@]}" )
#AUDIO=$(buildComponent "Audio" "Container" "$("$AUDIO_VOLUME" "$AUDIO_MUTE")" )

CPU_PERCENTAGE=$(buildComponent "Percentage" "RangeState" "listener" "proto://configs")
CPU_CORES=$(buildComponent "Cores" "RangeState" "listener" "proto://configs" 0 64 1)
CS=("$CPU_PERCENTAGE" "$CPU_CORES")
CPU=$(buildComponent "CPU" "Container" "${CS[@]}" )
#CPU=$(buildComponent "CPU" "Container" "$("$CPU_PERCENTAGE" "$CPU_CORES")" )

echo "#### Container test - START"
MODEL="PC Object Example"
BRAND="Various"
DESCR="Example that compose a small version of the JOSP PC Object model"
DESCR_LONG="test_descr_long"
ROOT=$(buildComponent "Root" "Container" "$MODEL" "$BRAND" "$DESCR" "$DESCR_LONG")
RS=("$AUDIO" "$CPU")
ROOT=$(addSubComponent "$ROOT" "${RS[@]}")
#ROOT=$(addSubComponent "$ROOT" "$("$AUDIO" "$CPU")")
echo "$ROOT"
echo "#### Container test - END"

