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
# bash $JOD_DIR/scripts/init/systemd/install-jod.sh
#
# Install current distribution as daemon on current machine.
#
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

JOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/../../.."
source "$JOD_DIR/scripts/libs/include.sh" "$JOD_DIR"

#DEBUG=true
[[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs
setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

execScriptConfigs "$JOD_DIR/scripts/jod/jod-script-configs.sh"
execScriptConfigs "$JOD_DIR/scripts/jod/errors.sh"

###############################################################################
logScriptInit

# Load jod_configs.sh, exit if fails
setupJODScriptConfigs "$JOD_DIR/configs/configs.sh"

# Internal vars
SERVICE_FILE="/etc/systemd/system/jod-$JOD_INSTALLATION_NAME_DOT.service"
CURRENT_USER=$(whoami)

###############################################################################
logScriptRun

logInf "Set jod.sh as executable..."
chmod +x $JOD_DIR/start.sh

logInf "Config and copy service file..."
JOD_DIR=$(realpath "$JOD_DIR")
sed -e 's|%JOD_INSTALLATION_NAME%|'"$JOD_INSTALLATION_NAME"'|g' \
  -e 's|%JOD_INSTALLATION_NAME_DOT%|'"$JOD_INSTALLATION_NAME_DOT"'|g' \
  -e 's|%JOD_DIR%|'"$JOD_DIR"'|g' \
  -e 's|%CURRENT_USER%|'"$CURRENT_USER"'|g' \
  -e 's|%JAVA_DIR%|'"$JAVA_DIR"'|g' \
  "$SCRIPT_PATH/jod.service.TMPL" >tmp_file
sudo mv tmp_file $SERVICE_FILE
sudo chown root $SERVICE_FILE
sudo chgrp root $SERVICE_FILE

logInf "Installing distribution..."
sudo systemctl enable "jod-$JOD_INSTALLATION_NAME_DOT.service"
sudo systemctl start "jod-$JOD_INSTALLATION_NAME_DOT.service"

###############################################################################
logScriptEnd
