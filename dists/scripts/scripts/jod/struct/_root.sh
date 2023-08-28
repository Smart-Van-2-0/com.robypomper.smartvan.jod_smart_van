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

# ############ #
# Root Element #
# ############ #

_buildRoot() {
  if [[ "$#" -eq 3 || "$#" -eq 4 ]]; then
    MODEL=$1
    BRAND=$2
    DESCR=$3
    DESCR_LONG=${4-""}
  else
    _warBuilder "Wrong buildRoot() params, please use one of the following prototypes:"
    _warBuilder "- buildRoot MODEL BRAND DESCR"
    _warBuilder "- buildRoot MODEL BRAND DESCR DESCR_LONG"
    echo "ERR: Can't build '$1' component because wrong params (${#}#: $*)"
    exit
  fi

  _logBuilder "> create Root with following args" >&2
  #_logBuilder "  - $MODEL"
  #_logBuilder "  - $BRAND"
  #_logBuilder "  - $DESCR"
  #_logBuilder "  - $DESCR_LONG"

  read -r -d '' COMP_STR <<EOM
{
  "model": "$MODEL",
  "brand": "$BRAND",
  "descr": "$DESCR",
  "descr_long": "$DESCR_LONG",

  "contains" : {
  }
}
EOM

  _logBuilder "< $COMP_STR"
  echo "$COMP_STR"
}
