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
###############################################################################

####################### Smart Van - Distribution build configs
# Enable the firmware simulation option for all firmwares that supports it
export SIMULATE=true        # default false
# If true, execute all python firmware in their own virtual environment
export VENV=true            # default false
# If true, then it print all logging messages from firmwares
#export INLINE_LOGS=true    # default false
#######################

# JOD_YML
# Absolute or $JOD_DIR relative file path for JOD config file,
# default $JOD_DIR/configs/jod.yml
#export JOD_YML="jod_2.yml"

# JAVA_HOME
# Full path of JAVA's JVM (ex: $JAVA_HOME/bin/java)
#JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home"
