#!/bin/bash

################################################################################
# The John Operating System Project is the collection of software and configurations
# to generate IoT EcoSystem, like the John Operating System Platform one.
# Copyright (C) 2022 Roberto Pompermaier
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

# ################### #
# RangeState Elements #
# ################### #

_buildRangeState() {
  if [ "$#" -eq 3 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
    COMP_MIN=0
    COMP_MAX=100
    COMP_STEP=5
  elif [ "$#" -eq 6 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
    COMP_MIN=$4
    COMP_MAX=$5
    COMP_STEP=$6
  else
    _warBuilder "Wrong buildRangeState() params, please use one of the following prototypes:"
    _warBuilder "- buildRangeState COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR"
    _warBuilder "- buildRangeState COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR COMP_MIN COMP_MAX COMP_STEP"
    echo "ERR: Can't build '$1' component because wrong params (${#}#: $*)"
    exit
  fi

  _logBuilder "> create RangeState '$COMP_NAME' component with following args" >&2
  #_logBuilder "  - $COMP_STATE_TYPE"
  #_logBuilder "  - $COMP_STATE_EXECUTOR"
  #_logBuilder "  - $COMP_MIN"
  #_logBuilder "  - $COMP_MAX"
  #_logBuilder "  - $COMP_STEP"

  read -r -d '' COMP_STR <<EOM
"$COMP_NAME" : {
  "type": "RangeState",
  "$COMP_STATE_TYPE" : "$COMP_STATE_EXECUTOR",
  "min": "$COMP_MIN",
  "max": "$COMP_MAX",
  "step": "$COMP_STEP"
}
EOM

  echo "$COMP_STR"
  _logBuilder "< $COMP_STR"
}


# #################### #
# RangeAction Elements #
# #################### #

_buildRangeAction() {
  if [ "$#" -eq 4 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
    COMP_MIN=0
    COMP_MAX=100
    COMP_STEP=5
    COMP_EXECUTOR=$4
  elif [ "$#" -eq 7 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
    COMP_EXECUTOR=$4
    COMP_MIN=$5
    COMP_MAX=$6
    COMP_STEP=$7
  else
    _warBuilder "Wrong buildRangeAction() params, please use one of the following prototypes:"
    _warBuilder "- buildRangeAction COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR COMP_EXECUTOR"
    _warBuilder "- buildRangeAction COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR COMP_MIN COMP_MAX COMP_STEP COMP_EXECUTOR"
    echo "ERR: Can't build '$1' component because wrong params (${#}#: $*)"
    exit
  fi

  _logBuilder "> create RangeAction '$COMP_NAME' component with following args" >&2
  #_logBuilder "  - $COMP_STATE_TYPE"
  #_logBuilder "  - $COMP_STATE_EXECUTOR"
  #_logBuilder "  - $COMP_MIN"
  #_logBuilder "  - $COMP_MAX"
  #_logBuilder "  - $COMP_STEP"
  #_logBuilder "  - $COMP_EXECUTOR"

  read -r -d '' COMP_STR <<EOM
"$COMP_NAME" : {
  "type": "RangeAction",
  "$COMP_STATE_TYPE" : "$COMP_STATE_EXECUTOR",
  "executor" : "$COMP_EXECUTOR",
  "min": "$COMP_MIN",
  "max": "$COMP_MAX",
  "step": "$COMP_STEP"
}
EOM

  echo "$COMP_STR"
  _logBuilder "< $COMP_STR"
}
