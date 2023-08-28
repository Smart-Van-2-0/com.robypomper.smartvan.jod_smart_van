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
# Artifact: Robypomper Bash Utils
# Version:  1.0.3
################################################################################

# Detect current OS.
# This method use the OSTYPE env var.
detectOS() {
  [ -n "$OSTYPE" ] && OS_VAL=$OSTYPE || OS_VAL=$OS
  case "$OS_VAL" in
  linux*) echo "Unix" ;;
  darwin*) echo "MacOS" ;;
  bsd*) echo "BSD" ;;
  freebsd*) echo "BSD" ;;
  solaris*) echo "Solaris" ;;
  msys*) echo "Win32" ;;
  cygwin*) echo "Win32" ;;
  win*) echo "Win32" ;;
  Win*) echo "Win32" ;;
  *) echo "Unknown: $OS_VAL" ;;
  esac
}

# Detect current OS.
# This method use the 'uname' cmd.
# This is an alternative to detectOS() method.
detectOS2() {
  OS_VAL="$(uname)"
  case $OS_VAL in
  'Linux') echo "Unix" ;;
  'Darwin') echo "MacOS" ;;
  'FreeBSD') echo "BSD" ;;
  'WindowsNT') echo "Win32" ;;
  'MINGW') echo "Win32" ;;
  'SunOS') echo "SunOS" ;;
  'AIX') echo "AIX" ;;
  *) echo "Unknow: $OS_VAL" ;;
  esac
}

# Detect current Init System.
# This method check the management command of each Init System know until
# it found the installed one.
detectInitSystem() {
  cmdInit='initctrl'
  cmdSystemd='systemd'
  cmdLaunchd='launchctl'
  cmdSysv='???'
  cmdUpstart='???'
  cmdWinInitSys='sc'

  if command -v $cmdInit &>/dev/null; then
    echo "Init"
  elif command -v $cmdSystemd &>/dev/null; then
    echo "SystemD"
  elif command -v $cmdLaunchd &>/dev/null; then
    echo "LaunchD"
  elif command -v $cmdSysv &>/dev/null; then
    echo "SysV"
  elif command -v $cmdUpstart &>/dev/null; then
    echo "UpStart"
  elif command -v $cmdWinInitSys &>/dev/null; then
    echo "WinInitSys"
  else
    echo "Unknown"
  fi
}

# Check current OS and fail script if not on correct OS.
# Correct OS is anything except Windows.
failOnWrongOS() {
  OS_VAR="$(detectOS)"
  if [ "$OS_VAR" == "Win32" ]; then
    logWar "Please execute PowerShell version of current script"
    PS_CMD=$(echo "$0" | sed "s/\.sh/\.ps1/")
    logWar "   $ powershell $PS_CMD"
    logFat "Executed bash script on '$OS_VAR' system. Exit" $ERR_OS_WRONG
  fi
}

# Check if current OS is contained in supportedOS list (given param).
failOnUnsupportedOS() {
  SOS=($@)
  CURR_OS=$(detectOS)
  if [ "$(containsElement "$CURR_OS" "${SOS[@]}")" == "1" ]; then
    logWar "Operating system '$CURR_OS' not supported by current distribution"
    logFat "Please execute this JOD distribution on one of the following OS '${SOS[*]}'" $ERR_OS_UNSUPPORTED
  fi
}
