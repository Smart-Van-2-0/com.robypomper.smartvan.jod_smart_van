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

#LOG_BUILDER_ENABLED=true                 # set to true to enable builder's log messages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
source "$SCRIPT_DIR/_script.sh"
source "$SCRIPT_DIR/_json.sh"
source "$SCRIPT_DIR/_root.sh"
source "$SCRIPT_DIR/_comp_container.sh"
source "$SCRIPT_DIR/_comp_boolean.sh"
source "$SCRIPT_DIR/_comp_range.sh"


# ################### #
# Components builders #
# ################### #

# Create a JOD Component using given params
buildComponent() {
  COMPONENT_NAME="$1"
  COMPONENT_TYPE="$2"
  shift
  shift
  COMPONENT_ARGS=("$@")

  if [ "$COMPONENT_NAME" == "Root" ]; then
    _buildRoot "${COMPONENT_ARGS[@]}"

  else
    case "$COMPONENT_TYPE" in

    "Container")
      _buildContainer "$COMPONENT_NAME" "${COMPONENT_ARGS[@]}"
      ;;

    "BooleanState")
      _buildBooleanState "$COMPONENT_NAME" "${COMPONENT_ARGS[@]}"
      ;;

    "RangeState")
      _buildRangeState "$COMPONENT_NAME" "${COMPONENT_ARGS[@]}"
      ;;

    "BooleanAction")
      _buildBooleanAction "$COMPONENT_NAME" "${COMPONENT_ARGS[@]}"
      ;;

    "RangeAction")
      _buildRangeAction "$COMPONENT_NAME" "${COMPONENT_ARGS[@]}"
      ;;

    *)
      _logBuilder "WAR: Unknown component type: $COMPONENT_TYPE"
      echo ""
      ;;
    esac
  fi
}

#
# COMP=$(buildComponent "Mute" "BooleanState" "listener|puller" "listener.sh param1 param2")
#
# COMP=$(buildComponent "Volume" "RangeState" "listener|puller" "listener.sh param1 param2")
# COMP=$(buildComponent "Volume" "RangeState" "listener|puller" "listener.sh param1 param2" 0 200 15)
#
# COMP=$(buildComponent "MuteA" "BooleanAction" "listener|puller" "listener.sh param1 param2" "executor.sh paramA paramB")
#
# COMP=$(buildComponent "VolumeA" "RangeAction" "listener|puller" "listener.sh param1 param2" 0 200 15 "executor.sh paramA paramB" )
# COMP=$(buildComponent "VolumeA" "RangeAction" "listener|puller" "listener.sh param1 param2" "executor.sh paramA paramB")
#
# CONT_1=$(buildComponent "Audio System" "Container")
# CONT_1=$(addSubComponent "$CONT_1" "$SUB_COMP1")
# CONT_1=$(addSubComponent "$CONT_1" "$SUB_COMP2")
# CONT_2=$(buildComponent "Audio System" "Container")
# CONT_2=$(addSubComponent "$CONT_2" "$SUB_COMP1" "$SUB_COMP2")
# CONT_3=$(buildComponent "Audio System" "Container" "$SUB_COMP1" "$SUB_COMP2" "$SUB_COMP3")
#
