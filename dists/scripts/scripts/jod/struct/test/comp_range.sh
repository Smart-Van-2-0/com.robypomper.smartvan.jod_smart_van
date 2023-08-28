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


# ################### #
# RangeState Elements #
# ################### #

echo "#### RangeState test - START"
NAME="comp name"
STATE_TYPE_LISTENER="listener"
STATE_TYPE_PULLER="puller"
STATE_WORKER="proto://configs"
RANGE_MIN=-10
RANGE_MAX=50
RANGE_STEP=5
STATE_RANGE=$(buildComponent "$NAME" "RangeState" "$STATE_TYPE_LISTENER" "$STATE_WORKER" $RANGE_MIN $RANGE_MAX $RANGE_STEP)
echo "$STATE_RANGE"
echo "#### RangeState test - END"


# #################### #
# RangeAction Elements #
# #################### #

echo "#### RangeAction test - START"
NAME="comp name"
STATE_TYPE_LISTENER="listener"
STATE_TYPE_PULLER="puller"
STATE_WORKER="proto://configs"
ACTION_WORKER="proto://configs"
RANGE_MIN=-10
RANGE_MAX=50
RANGE_STEP=5
ACTION_RANGE=$(buildComponent "$NAME" "RangeAction" "$STATE_TYPE_LISTENER" "$STATE_WORKER" "$ACTION_WORKER" $RANGE_MIN $RANGE_MIN $RANGE_STEP)
echo "$ACTION_RANGE"
echo "#### RangeAction test - END"
