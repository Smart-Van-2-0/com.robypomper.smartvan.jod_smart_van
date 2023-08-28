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

# ##################### #
# BooleanState Elements #
# ##################### #

function _buildBooleanStateArr() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)]
    [ValidateCount(2,2)]
    [string[]]$ARGS
  )
  $state_type=$ARGS[0]
  $state_worker=$ARGS[1]
  return _buildBooleanState $NAME $state_type $state_worker
}

function _buildBooleanState() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)][string[]]$STATE_TYPE,
    [Parameter(Mandatory)][string[]]$STATE_WORKER
  )

  _logBuilder "> create BooleanState '$NAME' component"
  #_logBuilder "> create BooleanState '$NAME' component with following args"
  #_logBuilder "  - $STATE_TYPE"
  #_logBuilder "  - $STATE_WORKER"

  $COMP_STR = """$NAME"" : {
  ""type"": ""BooleanState"",
  ""$STATE_TYPE"" : ""$STATE_WORKER""
}"

  _logBuilder "< $COMP_STR"
  return "$COMP_STR"
}


# ###################### #
# BooleanAction Elements #
# ###################### #

function _buildBooleanActionArr() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)]
    [ValidateCount(3,3)]
    [string[]]$ARGS
  )
  $state_type=$ARGS[0]
  $state_worker=$ARGS[1]
  $action_worker=$ARGS[2]
  return _buildBooleanAction $NAME $state_type $state_worker $action_worker
}

function _buildBooleanAction() {
  param (
    [Parameter(Mandatory)][string[]]$NAME,
    [Parameter(Mandatory)][string[]]$STATE_TYPE,
    [Parameter(Mandatory)][string[]]$STATE_WORKER,
    [Parameter(Mandatory)][string[]]$ACTION_WORKER
  )

  _logBuilder "> create BooleanAction '$COMP_NAME' component with following args"
  #_logBuilder "  - $COMP_STATE_TYPE"
  #_logBuilder "  - $COMP_STATE_EXECUTOR"
  #_logBuilder "  - $COMP_ACTION"

  $COMP_STR="""$NAME"" : {
  ""type"": ""BooleanAction"",
  ""$STATE_TYPE"" : ""$STATE_WORKER"",
  ""executor"" : ""$ACTION_WORKER""
}"

  _logBuilder "< $COMP_STR"
  return "$COMP_STR"
}
