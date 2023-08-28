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

###############################################################################
# Usage:
# bash $JOD_DIR/scripts/init/systemd/state-install-jod.sh [NO_LOGS]
#
# Check if current distribution is installed as daemon on current machine.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/../../.."
source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"

# PRE Init NO_LOGS
NO_LOGS=${1:-false}

#DEBUG=true
[ "$NO_LOGS" = "true" ] && setupLogsNone || [[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs
setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

execScriptConfigs "$JOD_DIR/scripts/jod/jod-script-configs.sh"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.sh"

###############################################################################
logScriptInit

# Init NO_LOGS (PRE initialized)
logScriptParam "NO_LOGS" "$NO_LOGS"

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"

###############################################################################
logScriptRun

logInf "Check distribution status-install..."
STATUS_INSTALL=$(systemctl is-active "jod-$JOD_INSTALLATION_NAME_DOT.service")
logTra "STATUS_INSTALL=$STATUS_INSTALL"
[ "$STATUS_INSTALL" = "active" ] || [ "$STATUS_INSTALL" = "activating" ] &&
  echo "Installed" ||
  echo "Not Installed"

###############################################################################
logScriptEnd
