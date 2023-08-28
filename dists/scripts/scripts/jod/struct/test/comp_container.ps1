#!/usr/bin/env powershell

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

$SCRIPT_DIR=(Get-Item $PSCommandPath ).DirectoryName
  ."$SCRIPT_DIR/../builder.ps1"


# ###################### #
# SubComponents managers #
# ###################### #

# N/A


# ################## #
# Container Elements #
# ################## #

$STATE_BOOL_A=$(buildComponent "comp name A" "BooleanState" "listener", "proto://configs")
$STATE_BOOL_B=$(buildComponent "comp name B" "BooleanState" "listener", "proto://configs")

Write-Host "#### Container test - START"
$NAME="container name"
$SUB_COMP=@($STATE_BOOL_A,$STATE_BOOL_B)
$CONTAINER=$(buildComponent "$NAME" "Container" $SUB_COMP)
Write-Host "$CONTAINER"
Write-Host "#### Container test - END"

Write-Host "#### Container test empty - START"
$NAME="container name"
$CONTAINER=$(buildComponent "$NAME" "Container")
Write-Host "$CONTAINER"
Write-Host "#### Container test empty - END"
