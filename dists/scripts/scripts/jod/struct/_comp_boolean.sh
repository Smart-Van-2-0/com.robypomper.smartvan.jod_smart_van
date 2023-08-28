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

# ##################### #
# BooleanState Elements #
# ##################### #

_buildBooleanState() {
  if [ "$#" -eq 3 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
  else
    _warBuilder "Wrong buildBooleanState() params, please use one of the following prototypes:"
    _warBuilder "- buildBooleanState COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR"
    echo "ERR: Can't build '$1' component because wrong params (${#}#: $*)"
    exit
  fi

  _logBuilder "> create BooleanState '$COMP_NAME' component with following args" >&2
  #_logBuilder "  - $COMP_STATE_TYPE"
  #_logBuilder "  - $COMP_STATE_EXECUTOR"

  read -r -d '' COMP_STR <<EOM
"$COMP_NAME" : {
  "type": "BooleanState",
  "$COMP_STATE_TYPE" : "$COMP_STATE_EXECUTOR"
}
EOM

  echo "$COMP_STR"
  _logBuilder "< $COMP_STR"
}


# ###################### #
# BooleanAction Elements #
# ###################### #

_buildBooleanAction() {
  if [ "$#" -eq 4 ]; then
    COMP_NAME=$1
    COMP_STATE_TYPE=$2
    COMP_STATE_EXECUTOR=$3
    COMP_ACTION=$4
  else
    _warBuilder "Wrong buildBooleanAction() params, please use one of the following prototypes:"
    _warBuilder "- buildBooleanAction COMP_NAME COMP_STATE_TYPE COMP_STATE_EXECUTOR COMP_ACTION"
    echo "ERR: Can't build '$1' component because wrong params (${#}#: $*)"
    exit
  fi

  _logBuilder "> create BooleanAction '$COMP_NAME' component with following args" >&2
  #_logBuilder "  - $COMP_STATE_TYPE"
  #_logBuilder "  - $COMP_STATE_EXECUTOR"
  #_logBuilder "  - $COMP_ACTION"

  read -r -d '' COMP_STR <<EOM
"$COMP_NAME" : {
  "type": "BooleanAction",
  "$COMP_STATE_TYPE" : "$COMP_STATE_EXECUTOR",
  "executor" : "$COMP_ACTION"
}
EOM

  echo "$COMP_STR"
  _logBuilder "< $COMP_STR"
}
