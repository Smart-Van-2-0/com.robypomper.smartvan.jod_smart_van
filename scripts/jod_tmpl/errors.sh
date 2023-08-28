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

###############################################################################
# Artifact: Robypomper Bash Utils
# Version:  1.0.3
###############################################################################

# Generic
_ERRBASE_GENERIC=0
export ERR_CONFIGS_NOT_FOUND=$((_ERRBASE_GENERIC + 1))           # "Script can't find distribution's configs"

# build.sh
_ERRBASE_BUILD=10
_ERRBASE_BUILD_CONFIGS=$((_ERRBASE_BUILD + (10 * 0)))
export ERR_CONFIGS_INVALID_DIST_JCP_ENV=$((_ERRBASE_BUILD_CONFIGS + 1))         # ""
export ERR_CONFIGS_MISSING_DIST_JCP_ID=$((_ERRBASE_BUILD_CONFIGS + 2))          # ""
export ERR_CONFIGS_MISSING_DIST_JCP_SECRET=$((_ERRBASE_BUILD_CONFIGS + 3))      # ""
export ERR_CONFIGS_ILLEGAL_DIST_JOD_ID=$((_ERRBASE_BUILD_CONFIGS + 4))          # ""
_ERRBASE_BUILD_PROCESS=$((_ERRBASE_BUILD + (10 * 1)))
export ERR_GET_JOD_LIB=$((_ERRBASE_BUILD_PROCESS + 1))           # ""
export ERR_GET_JOD_DEPS_LIB=$((_ERRBASE_BUILD_PROCESS + 2))      # ""
export ERR_GET_JOD_STRUCT=$((_ERRBASE_BUILD_PROCESS + 3))        # ""
export ERR_GET_JOD_CONFIGS=$((_ERRBASE_BUILD_PROCESS + 4))       # ""
export ERR_GET_JOD_SCRIPTS=$((_ERRBASE_BUILD_PROCESS + 5))       # ""
export ERR_GET_JOD_RESOURCES=$((_ERRBASE_BUILD_PROCESS + 6))     # ""

# install.sh
_ERRBASE_INSTALL=10
ERR_GET_JOD_ASSEMBLED=$((_ERRBASE_INSTALL + 1))       # ""