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


# ##################### #
# BooleanState Elements #
# ##################### #

echo "#### BooleanState test - START"
NAME="comp name"
STATE_TYPE_LISTENER="listener"
STATE_TYPE_PULLER="puller"
STATE_WORKER="proto://configs"
STATE_BOOL=$(buildComponent "$NAME" "BooleanState" "$STATE_TYPE_LISTENER" "$STATE_WORKER")
echo "$STATE_BOOL"
echo "#### BooleanState test - END"


# ###################### #
# BooleanAction Elements #
# ###################### #

echo "#### BooleanAction test - START"
NAME="comp name"
STATE_TYPE_LISTENER="listener"
STATE_TYPE_PULLER="puller"
STATE_WORKER="proto://configs"
ACTION_WORKER="proto://configs"
ACTION_BOOL=$(buildComponent "$NAME" "BooleanAction" "$STATE_TYPE_LISTENER" "$STATE_WORKER" "$ACTION_WORKER")
echo "$ACTION_BOOL"
echo "#### BooleanAction test - END"