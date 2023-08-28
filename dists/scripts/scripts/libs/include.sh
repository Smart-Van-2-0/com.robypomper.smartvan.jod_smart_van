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

JOD_DIR=$1

source "$JOD_DIR/scripts/libs/errors.sh"
source "$JOD_DIR/scripts/libs/bash.sh"
source "$JOD_DIR/scripts/libs/logs.sh"
source "$JOD_DIR/scripts/libs/filesAndDirs.sh"
source "$JOD_DIR/scripts/libs/hostAndOS.sh"
