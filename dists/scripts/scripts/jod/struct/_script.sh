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

# ############### #
# Scripts configs #
# ############### #

#LOG_BUILDER_ENABLED=true                 # set to true to enable builder's log messages

# ####### #
# Loggers #
# ####### #

_logBuilder() {
  [ "$LOG_BUILDER_ENABLED" == true ] && echo "LOG: $1" >&2
}

_warBuilder() {
  echo "WAR: $1" >&2
}


# ########## #
# Formatters #
# ########## #

prettyPrint() {
  echo "$1" | jq . || _warBuilder "Error parsing JSON string ($1)"
}

tryPrettyFormat() {
  if command -v jq &>/dev/null; then
    echo "$(echo "$1" | jq .)" || _warBuilder "Error parsing JSON string ($1)"
  else
    echo "$1"
  fi
}

prettyFormat() {
  echo "$(echo "$1" | jq .)" || _warBuilder "Error parsing JSON string ($1)"
}
