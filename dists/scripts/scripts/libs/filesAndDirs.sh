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
# Artifact: Robypomper Bash Utils
# Version:  1.0.3
################################################################################

# Return normalized path, without unnecessary '.' and '..'.
#
# $1 the path to normailze
normalizeDirPath() {
  # Remove all /./ sequences.
  local path=${1//\/.\//\/}

  # Remove dir/.. sequences.
  while [[ $path =~ ([^/][^/]*/\.\./) ]]; do
    path=${path/${BASH_REMATCH[0]}/}
  done

  echo $path
}

# Search for specified $FILE in specified $DIR and his parents
# This method search recursively also on $DIR parent dirs
#
# $1 directory where to start search
# $2 filename to looking for
findFileInParents() {
  DIR=$1
  FILE=$2

  # Check if root dir
  if [ "$DIR" = "/" ]; then
    return
  fi

  # Check if $DIR contains $FILE
  if [ -f "$DIR/$FILE" ]; then
    echo "$DIR"
    return
  else
    # Recursive call
    parentDir="$(dirname "$DIR")"
    findFileInParents "$parentDir" "$FILE"
    return
  fi
}
