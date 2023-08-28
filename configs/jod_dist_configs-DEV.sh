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
# Example configs script called by JOD builders scripts.
# This configuration can be used to customize the JOD distribution management
# like execution, installation, etc...
#
# To enable this config script, rename it to configs.sh and place in the JOD's
# dist main dir. If not present, then default configs are used.
#
# Artifact: JOD Dist Template
# Version:  1.0.3
#
# Artifact: {JOD Dist Name}
# Version:  {JOD Dist Version}
###############################################################################

# TMPL Customize - START
CURRENT_SCRIPT="$(pwd)/${BASH_SOURCE[0]}"
# Customize this file and then delete this line
#echo "WAR: Please customize TMPL before call it" && echo "     Update the '${CURRENT_SCRIPT}' file and delete current line" && exit

# ################ #
# JOD Distribution #
# ################ #

# JOD Distribution name
# A string representing current JOD Distribution.
# Commonly starts with "JOD something else", must be human readable
DIST_NAME="JOD Dist Name"

# JOD Distribution code
# A string representing current JOD Distribution.
# This string must be without spaces because it's used for artifact and dir names.
DIST_ARTIFACT="JOD-Tmpl"

# JOD Distribution version
# A custom string representing current JOD Distribution version
DIST_VER="0.1"

# ################### #
# John Cloud Platform #
# ################### #

# JCP Environment Object's credentials id
# A string containing the JCP client id for selected JCP Auth (depends on DIST_JCP_ENV)
# It's mandatory, if not set you can't build JOD Distribution.
DIST_JCP_ID="a"

# JCP Environment Object's credentials secret
# A string containing the JCP client secret for selected JCP Auth (depends on DIST_JCP_ENV)
# It's mandatory, if not set you can't build JOD Distribution.
DIST_JCP_SECRET="b"

# JCP Environment
# A string from (local|stage|prod) set. This property allow to build
# JOD Distributions with predefined JCP configs for local, stage or
# production JCP environments.
# Depending on DIST_JCP_ENV value, different JCP urls are set in the 'jod.yml' file.
# - local: set urls for a local JCP environment executed via the 'com.robypomper.josp' project
# - stage: set urls for Public JCP - Stage environment (to use for pre-release tests)
# - prod: set urls for Public JCP - Production environment  (to use for release build)
DIST_JCP_ENV="local"

# ########## #
# JOD Object #
# ########## #

# JOD Agent version to include in the generated distribution
# JOD agent's and his dependencies will be first downloaded from central maven
# repository, if not available, then will be copied from local maven repository.
DIST_JOD_VER="2.2.3"

# JOD Object's name
# A string used as JOD object's name. All instances of current JOD Distribution
# will have the same name. By default, (value = "") it allow the JOD Agent to
# generate a new name for each JOD instance executed.
#DIST_JOD_NAME="Entrance light 1"

# JOD Object's id     (WAR: do not use when releasing a JOD Distribution)
# A string containing a predefined JOD Object's id in 'XXXXX-XXXXX-XXXXX' format.
# All instances of current JOD Distribution will have the same id. By default
# (value = "") it allow the JOD Agent to generate a new id for each JOD instance
# executed.
#DIST_JOD_ID="XXXXX-XXXXX-XXXXX"

# JOD Object's owner
# A string containing a predefined JOSP User's id in 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX' format.
# All instances of current JOD Distribution will have the same owner. By default
# (value = "00000-00000-00000") means no user is registered as owner, so other
# JOSP Users can register them self as object owners.
#DIST_JOD_OWNER="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# JOD Object's main config template
# A file path for an alternative '$JOD_DIST_DIR/dists/configs/jod_TMPL.yml'
# file.
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/jod_TMPL.yml'
# file.
# The 'jod_TMPL.yml' is the base file where %VAR% are replaced with
# JOD Distribution's scripts configs values. For VARs complete list,
# see the '$JOD_DIST_DIR/scripts/build.sh' script.
# The file path must be relative to the $JOD_DIST_DIR.
#DIST_JOD_CONFIG_TMPL="dists/configs/jod_TMPL.yml"

# JOD Object's logs config template
# A file path for an alternative '$JOD_DIST_DIR/dists/configs/log4j2_TMPL.xml'
# file.
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/log4j2_TMPL.xml'
# file.
# The 'log4j2_TMPL.xml' is a Log4j2 config file used to print logs on console,
# on files, on network listeners...
# The file path must be relative to the $JOD_DIST_DIR.
#DIST_JOD_CONFIG_LOGS_TMPL="dists/configs/log4j2_TMPL.xml"

# JOD Object's structure files
# A file path for a valid 'struct.jod' file to include in the built
# JOD Distribution.
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/struct.jod'
# file.
# The file path must be relative to the $JOD_DIST_DIR.
#DIST_JOD_STRUCT="dists/configs/struct.jod"

# Enable/Disable JOD Local Communication, default true
#DIST_JOD_COMM_DIRECT_ENABLED="True"

# Enable/Disable JOD Local Communication, default true
#DIST_JOD_COMM_CLOUD_ENABLED="True"

# ############ #
# JOD Firmware #
# ############ #

# JOD Object's pullers protocols
# A list of loadable JOD Pullers used in the struct.jod file.
# An empty list load default pullers protocols:
# - "shell" as PullerShell (PullerUnixShell for DIST_JOD_VER=2.2.0)
# - "http" as PullerHttp
# The list must use following format: {PROTO_SHORTCUT}://{PULLER_CLASS}[ ...]
# Example:
# shell://com.robypomper.josp.jod.executor.PullerShell http://com.robypomper.josp.jod.executor.impls.http.PullerHTTP
#DIST_JOD_WORK_PULLERS="{PROTO_SHORTCUT}://{PULLER_CLASS}[ ...]"

# JOD Object's listeners protocols
# A list of loadable JOD Listeners used in the struct.jod file.
# An empty list load default listeners protocols:
# - "file" as ListenerFiles
# The list must use following format: {PROTO_SHORTCUT}://{LISTENER_CLASS}[ ...]
# Example:
# file://com.robypomper.josp.jod.executor.ListenerFiles
#DIST_JOD_WORK_LISTENERS="{PROTO_SHORTCUT}://{LISTENER_CLASS}[ ...]"

# JOD Object's executors protocols
# A list of loadable JOD Executors used in the struct.jod file.
# An empty list load default executors protocols:
# - "shell" as ExecutorShell (ExecutorUnixShell for DIST_JOD_VER=2.2.0)
# - "file" as ExecutorFile
# - "http" as ExecutorHTTP
# The list must use following format: {PROTO_SHORTCUT}://{EXECUTOR_CLASS}[ ...]
# Example:
# shell://com.robypomper.josp.jod.executor.ExecutorShell file://com.robypomper.josp.jod.executor.ExecutorFiles http://com.robypomper.josp.jod.executor.impls.http.ExecutorHTTP
#DIST_JOD_WORK_EXECUTORS="{PROTO_SHORTCUT}://{EXECUTOR_CLASS}[ ...]"

# TMPL Customize - END
