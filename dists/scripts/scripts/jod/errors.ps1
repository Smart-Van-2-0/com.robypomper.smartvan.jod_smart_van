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

# Generic
$_ERRBASE_GENERIC=0
$global:ERR_LOAD_SCRIPT_CONFIG=$(($_ERRBASE_GENERIC + 1))   # "JOD script config file not found ($JOD_SCRIPT_CONFIG), exit"
$global:ERR_DETECT_SCRIPT_CONFIG=$(($_ERRBASE_GENERIC + 2)) # "Can't detect XY ($XY), exit"
$global:ERR_NOT_IMPLEMENTED=$(($_ERRBASE_GENERIC + 3))      # "Distribution installation not implemented"

# start.sh
$_ERRBASE_START=10
$global:ERR_ALREADY_RUNNING=$(($_ERRBASE_START + 1)) # "Distribution already running, please shutdown distribution or set FORCE param"

# stop.sh
$_ERRBASE_SHUTDOWN=20
$global:ERR_CANT_SHUTDOWN=$(($_ERRBASE_SHUTDOWN + 1)) # "Can't shutdown JOD with PID=$JOD_PID"

# install.sh
$_ERRBASE_INSTALL=30
$global:ERR_ALREADY_INSTALLED=$(($_ERRBASE_INSTALL + 1)) # "Distribution already installed, please uninstall distribution or set FORCE param"

# uninstall.sh
$_ERRBASE_UNINSTALL=40

# pre-post scripts
$_ERRBASE_PREPOST=100
$global:ERR_MISSING_REQUIREMENTS=$(($_ERRBASE_PREPOST + 1)) # "Operation failed because missing some requirement"
