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

# ############ #
# Root Element #
# ############ #

function _buildRootArr() {
  param (
    [Parameter(Mandatory)]
    [ValidateCount(3,4)]
    [string[]]$ARGS
  )
  $model=$ARGS[0]
  $brand=$ARGS[1]
  $descr=$ARGS[2]
  $descr_long=if ($ARGS[3]) { $ARGS[3] } else { "" }
  return _buildRoot $model $brand $descr $descr_long
}

function _buildRoot() {
  param (
  [Parameter(Mandatory)][string]$MODEL,
  [Parameter(Mandatory)][string]$BRAND,
  [Parameter(Mandatory)][string]$DESCR,
  [string]$DESCR_LONG=""
  )

  _logBuilder "> create Root with following args"
  #_logBuilder "  - $MODEL"
  #_logBuilder "  - $BRAND"
  #_logBuilder "  - $DESCR"
  #_logBuilder "  - $DESCR_LONG"

  $COMP_STR = "{
  ""model"": ""$MODEL"",
  ""brand"": ""$BRAND"",
  ""descr"": ""$DESCR"",
  ""descr_long"": ""$DESCR_LONG"",

  ""contains"" : {
  }
}"

  _logBuilder "< $COMP_STR"
  return "$COMP_STR"
}
