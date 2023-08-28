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
# Artifact: Robypomper PowerShell Utils
# Version:  1.0.3
################################################################################

# Detect current OS.
# This method use the OSTYPE env var.
function detectOS() {
  $OS=$PSVersionTable.OS
  if ($null -eq $OS) { $OS=$env:OS }
  return $(switch -Wildcard ($OS) {
    "Linux*"  { return "Unix" }
    "Darwin*"  { return "MacOS" }
    #"XXX*"  { return "BSD" }
    #"XXX*"  { return "Solaris" }
    "Microsoft*"  { return "Win32" }
    "Windows*"  { return "Win32" }
    Default  { return "Unknown: '${PSVersionTable.OS}'" }
  })
}

# Detect current Init System.
# This method check the management command of each Init System know until
# it found the installed one.
function detectInitSystem() {
  try {
    Get-Service | Out-Null
    return "WinInitSys"
  } catch {}

  try {
    initctrl | Out-Null
    return "Init"
  } catch {
  }

  try {
    systemd | Out-Null
    return "SystemD"
  } catch {
  }

  try {
    launchctl | Out-Null
    return "LaunchD"
  } catch {
  }

  return "Unknown"
}

# Check current OS and fail script if not on correct OS.
# Correct OS is anything except Windows.
function failOnWrongOS() {
  $OS_VAR = detectOS
  if ($OS_VAR -ne "Win32")
  {
    logWar "Please execute bash version of current script"
    $BASH_CMD = $PSCommandPath -replace '.ps1', '.sh'
    logWar "   $ bash $BASH_CMD"
    logFat "Executed PowerShell script on '$OS_VAR' system. Exit" $ERR_OS_WRONG
  }
}

# Check if current OS is contained in supportedOS list (given param).
function failOnUnsupportedOS() {
  $CURR_OS = detectOS
  if (!$args[0].Contains($CURR_OS)) {
    logWar "Operating system '$CURR_OS' not supported by current distribution"
    logFat "Please execute this JOD distribution on one of the following OS '$( $args )'" 1 $ERR_OS_UNSUPPORTED
  }
}
