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
# no direct usage, included from other scripts
#
# Example configs script called by JOD distribution scripts.
# This configuration can be used to customize the JOD distribution management
# like execution, installation, etc...
#
# Artifact: JOD Dist Template
# Version:  1.0.3
#
# Artifact: {JOD Dist Name}
# Version:  {JOD Dist Version}
###############################################################################

# JOD_YML
# Absolute or $JOD_DIR relative file path for JOD config file, default $JOD_DIR/jod.yml
#export JOD_YML="jod_2.yml"

# JAVA_HOME
# Full path of JAVA's JVM (ex: $JAVA_HOME/bin/java)
#JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home"


# ########################## #      # Delete if Struct' Builder function are not used in the distribution
# JOD Struct Builder configs #
# ########################## #
# Configs from scripts/jod/struct/builder.sh

# LOG_BUILDER_ENABLED
# Enable debug messages on jod/struct/builder.sh script (if used in the
# distribution). Set to true to enable builder's log messages.
#export LOG_BUILDER_ENABLED=true


# ################# #       # Delete if HW Daemon is not used in the distribution
# HW Daemon configs #
# ################# #
# Configs from scripts/hw/start_daemon.sh
# Configs from scripts/hw/stop_daemon.sh

# HW Daemon, refresh time in seconds
# The number of seconds between each HW daemon's internal function execution.
# The HW Daemon, refresh time in seconds. By default it's '300'
#export DAEMON_REFRESH="300"

# Directory where are store all status files.
# The path of the directory where are store the cache files like the command's
# output. It used by "store values" and "structure generator" functions, it
# can be relative to the working dir. By default it's '$JOD_DIR/status'.
#export DAEMON_CACHE_DIR="$JOD_DIR/status"
