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

# ################### #
# RangeState Elements #
# ################### #

function _buildRangeStateArr() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)]
    [ValidateCount(2,5)]
    [string[]]$ARGS
  )
  $state_type=$ARGS[0]
  $state_worker=$ARGS[1]
  $range_min=if ($ARGS[2]) { $ARGS[2] } else { 0 }
  $range_max=if ($ARGS[3]) { $ARGS[3] } else { 100 }
  $range_step=if ($ARGS[4]) { $ARGS[4] } else { 5 }
  return _buildRangeState $NAME $state_type $state_worker $range_min $range_max $range_step
}

function _buildRangeState() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)][string[]]$STATE_TYPE,
    [Parameter(Mandatory)][string[]]$STATE_WORKER,
    [int]$RANGE_MIN = 0,
    [int]$RANGE_MAX = 100,
    [int]$RANGE_STEP = 5
  )

  _logBuilder "> create RangeState '$NAME' component"
  #_logBuilder "> create RangeState '$NAME' component with following args"
  #_logBuilder "  - $STATE_TYPE"
  #_logBuilder "  - $STATE_WORKER"
  #_logBuilder "  - $RANGE_MIN"
  #_logBuilder "  - $RANGE_MAX"
  #_logBuilder "  - $RANGE_STEP"

  $COMP_STR="""$NAME"" : {
  ""type"": ""RangeState"",
  ""$STATE_TYPE"" : ""$STATE_WORKER"",
  ""min"": ""$RANGE_MIN"",
  ""max"": ""$RANGE_MAX"",
  ""step"": ""$RANGE_STEP""
}"

  _logBuilder "< $COMP_STR"
  return "$COMP_STR"
}


# #################### #
# RangeAction Elements #
# #################### #

function _buildRangeActionArr() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)]
    [ValidateCount(3,6)]
    [string[]]$ARGS
  )
  $state_type=$ARGS[0]
  $state_worker=$ARGS[1]
  $action_worker=$ARGS[2]
  $range_min=if ($ARGS[3]) { $ARGS[3] } else { 0 }
  $range_max=if ($ARGS[4]) { $ARGS[4] } else { 0 }
  $range_step=if ($ARGS[5]) { $ARGS[5] } else { 0 }
  return _buildRangeAction $NAME $state_type $state_worker $action_worker $range_min $range_max $range_step
}

function _buildRangeAction() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)][string[]]$STATE_TYPE,
    [Parameter(Mandatory)][string[]]$STATE_WORKER,
    [Parameter(Mandatory)][string[]]$ACTION_WORKER,
    [int]$RANGE_MIN = 0,
    [int]$RANGE_MAX = 100,
    [int]$RANGE_STEP = 5
  )

  _logBuilder "> create RangeAction '$NAME' component"
  #_logBuilder "> create RangeAction '$NAME' component with following args"
  #_logBuilder "  - $STATE_TYPE"
  #_logBuilder "  - $STATE_WORKER"
  #_logBuilder "  - $ACTION_WORKER"
  #_logBuilder "  - $RANGE_MIN"
  #_logBuilder "  - $RANGE_MAX"
  #_logBuilder "  - $RANGE_STEP"

  $COMP_STR="""$NAME"" : {
  ""type"": ""RangeAction"",
  ""$STATE_TYPE"" : ""$STATE_WORKER"",
  ""executor"" : ""$ACTION_WORKER"",
  ""min"": ""$RANGE_MIN"",
  ""max"": ""$RANGE_MAX"",
  ""step"": ""$RANGE_STEP""
}"

  _logBuilder "< $COMP_STR"
  return "$COMP_STR"
}
