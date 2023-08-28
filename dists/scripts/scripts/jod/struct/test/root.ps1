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


# ############ #
# Root Element #
# ############ #

Write-Host "#### Root test (partial) - START"
$MODEL="test_model"
$BRAND="test_brand"
$DESCR="test_descr"
$ROOT=$(buildComponent "Root" "Container" "$MODEL", "$BRAND", "$DESCR")
Write-Host "$ROOT"
Write-Host "#### Root test (partial) - END"

Write-Host "#### Root test (full) - START"
$MODEL="test_model"
$BRAND="test_brand"
$DESCR="test_descr"
$DESCR_LONG="test_descr_long"
$ROOT=$(buildComponent "Root" "Container" "$MODEL", "$BRAND", "$DESCR", "$DESCR_LONG")
Write-Host "$ROOT"
Write-Host "#### Root test (full) - END"

Write-Host "#### Root test (missing -> ERROR) - START"
$MODEL="test_model"
$BRAND="test_brand"
$ROOT=$(buildComponent "Root" "Container" "$MODEL", "$BRAND")
Write-Host "$ROOT"
Write-Host "#### Root test - (missing -> ERROR) END"
