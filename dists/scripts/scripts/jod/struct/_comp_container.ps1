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

# ###################### #
# SubComponents managers #
# ###################### #

function addSubComponent() {
  param (
    [Parameter(Mandatory)][string]$CONT,
    [Parameter(Mandatory)][string[]]$COMPONENT_ARGS
  )

  foreach ($sub_comp in $COMPONENT_ARGS) {
    $CONT=$( _addSubComponent_Single "$CONT" "$sub_comp" )
  }

  return $CONT
}

function _addSubComponent_Single() {
  param (
    [Parameter(Mandatory)][string]$CONT,
    [Parameter(Mandatory)][string]$SUB_COMP
  )

  if ( -Not($CONT -like "*contains*") ) {
    _warBuilder "Wrong addSubComponent_Single() 'CONT' param, it must include the 'contains' property."
    _warBuilder "Method addSubComponent_Single CONT can be a component of Container or Root types"
    _warBuilder "instead provided params ($CONT)"
    return "ERR: Can't build '$CONT' container because wrong params"
    exit
  }

  # Convert container from JSON
  $isRoot = $CONT.StartsWith("{")
  $contObjWrapper = $(if ($isRoot) { $CONT } else { "{$CONT}" }) | ConvertFrom-Json
  $contName = if ($isRoot) { "root" } else { $contObjWrapper.psobject.properties.name }              # expected only 1 children
  $contObj = if ($isRoot) { $contObjWrapper } else { $contObjWrapper.$contName }
  $contObjContains = $contObj.contains

  # Convert sub-comp from JSON
  $subCompObjWrapper = "{$SUB_COMP}" | ConvertFrom-Json
  $subCompName = $subCompObjWrapper.psobject.properties.name              # expected only 1 children
  $subCompObj = $subCompObjWrapper.$subCompName

  # Add sub-comp to container
  $contObjContains | Add-Member -NotePropertyName $subCompName -NotePropertyValue $subCompObj

  # Convert container to JSON
  $CONT = $contObjWrapper | ConvertTo-Json -Depth 4
  if (-Not ($isRoot) ) {
    $CONT = $CONT.Substring(1)
    $CONT = $CONT.Substring(0,$CONT.Length-1)
  }
  return $CONT
}


# ################## #
# Container Elements #
# ################## #

function _buildContainer() {
  param (
    [Parameter(Mandatory)][string]$NAME,
    [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$SUB_COMPONENTS
  )

  _logBuilder "> create Container '$NAME' component"
  #_logBuilder "> create Container '$COMP_NAME' component with following args"
  #for arg in "${SUB_COMPONENTS[@]}"; do _logBuilder "  # $arg"; done

  $COMP_STR = """$NAME"" : {
  ""type"": ""JODContainer"",
  ""contains"" : {
  }
}"

  foreach ($arg in $SUB_COMPONENTS) {
    $COMP_STR=$( addSubComponent "$COMP_STR" "$arg" )
  }

  _logBuilder "< $COMP_STR"
  return "$COMP_STR".Trim()
}
