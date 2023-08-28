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

#$LOG_BUILDER_ENABLED=$true                 # set to true to enable builder's log messages

$SCRIPT_DIR=(Get-Item $PSCommandPath ).DirectoryName
  ."$SCRIPT_DIR/_script.ps1"
  ."$SCRIPT_DIR/_root.ps1"
  ."$SCRIPT_DIR/_comp_container.ps1"
  ."$SCRIPT_DIR/_comp_boolean.ps1"
  ."$SCRIPT_DIR/_comp_range.ps1"


# ################### #
# Components builders #
# ################### #

# Create a JOD Component using given params
function buildComponent() {
  param (
    [Parameter(Mandatory)][string]$NAME,
    [Parameter(Mandatory)][string]$TYPE,
    [string[]]$ARGS = @()
  )

  if ($NAME -eq "Root") {
    _buildRootArr $ARGS

  } else {
    switch ($TYPE) {
      Container {
        _buildContainer "$NAME" $ARGS
      }

      BooleanState {
        _buildBooleanStateArr "$NAME" $ARGS
      }

      RangeState {
        _buildRangeStateArr "$NAME" $ARGS
      }

      BooleanAction {
        _buildBooleanActionArr "$NAME" $ARGS
      }

      RangeAction  {
        _buildRangeActionArr "$NAME" $ARGS
      }

      default {
        _logBuilder "WAR: Unknown component type: $TYPE"
        return ""
      }
    }
  }
}

