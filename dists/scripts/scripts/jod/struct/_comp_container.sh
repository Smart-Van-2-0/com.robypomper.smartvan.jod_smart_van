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

# ###################### #
# SubComponents managers #
# ###################### #

addSubComponent() {
  if [ "$#" -lt 2 ]; then
    _warBuilder "Wrong addSubComponent() params, please use one of the following prototypes:"
    _warBuilder "- addSubComponent CONT SUB_COMP_1 ... SUB_COMP_N"
    echo "ERR: Can't build '$1' container because wrong params (${#}#: $*)"
    exit
  fi


  CONT=$1
  shift
  COMPONENT_ARGS=("$@")

  for sub_comp in "${COMPONENT_ARGS[@]}"
  do
    CONT=$(_addSubComponent_Single "$CONT" "$sub_comp")
  done

  formatTag "$CONT"
}

_addSubComponent_Single() {
  if [ "$#" -ne 2 ]; then
    _warBuilder "Wrong addSubComponent_Single() params, please use one of the following prototypes:"
    _warBuilder "Wrong addSubComponent_Single() CONT params, it must include the 'contains' property:"
    _warBuilder "- addSubComponent_Single CONT SUB_COMP"
    echo "ERR: Can't build '$1' container because wrong params (${#}#: $*)"
    exit
  fi

  CONT=$1
  SUB_COMP=$2

  if [[ $CONT != *"contains"* ]]; then
    _warBuilder "Wrong addSubComponent_Single() 'CONT' param, it must include the 'contains' property."
    _warBuilder "Method addSubComponent_Single CONT can be a component of Container or Root types"
    _warBuilder "instead provided params ($CONT)"
    echo "ERR: Can't build '$1' container because wrong 'CONT' param ($CONT)"
    exit
  fi

  # Convert container from JSON
  isRoot=$([[ $CONT == \{* ]])

  containsTagOld="$(extractTag "$CONT" "contains")"
  containsTagNew="$(addTag "$containsTagOld" "$SUB_COMP")"
  echo "${CONT/"$containsTagOld"/$containsTagNew}"
}


# ################## #
# Container Elements #
# ################## #

_buildContainer() {
  if [ "$#" -eq 0 ]; then
    _warBuilder "Wrong buildContainer() params, please use one of the following prototypes:"
    _warBuilder "- buildContainer COMP_NAME"
    _warBuilder "- buildContainer COMP_NAME SUB_COMP_1 ... SUB_COMP_N"
    echo "ERR: Can't build 'Unknown' container because wrong params (${#}#: $*)"
    exit
  fi

  COMP_NAME=$1
  shift
  SUB_COMPONENTS=("$@")

  _logBuilder "> create Container '$COMP_NAME' component with following args" >&2
  #for arg in "${SUB_COMPONENTS[@]}"; do _logBuilder "  # $arg"; done

  read -r -d '' COMP_STR <<EOM
"$COMP_NAME" : {
  "type": "JODContainer",
  "contains" : {
  }
}
EOM

  for arg in "${SUB_COMPONENTS[@]}"; do COMP_STR=$(addSubComponent "$COMP_STR" "$arg"); done

  echo "$COMP_STR"
  _logBuilder "< $COMP_STR"
}
