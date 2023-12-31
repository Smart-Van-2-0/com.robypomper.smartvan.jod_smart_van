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

# ################ #
# JOD Distribution #
# ################ #

# JOD Distribution name
# A string representing current JOD Distribution.
# Commonly starts with "JOD something else", must be human readable
DIST_NAME="JOD Smart Van"

# JOD Distribution code
# A string representing current JOD Distribution.
# This string must be without spaces because it's used for artifact and dir names.
DIST_ARTIFACT="JOD_Smart_Van"

# JOD Distribution version
# A custom string representing current JOD Distribution version
DIST_VER="1.0.0"

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
DIST_JCP_ENV="prod"

# Distribution dependencies list
# Downloads/copy distribution dependencies from urls or local dirs.
# Dependencies from url are cached into the `build/cache` dir. So, to refresh
# them, you'll need to remove the cache copy manually.<br/>
# On the other side, the local dir dependencies are reset every time this script
# is executed. That is useful for firmware development.
# Dependencies are intended as url if, and only if, his string contains the
# `://' substring.
# Here some examples:
# ```
# "README.md"                                 // single file from dist project's dir
# "extra/media_assets"                        // a directory containing extra files and assets
# "../com.robypomper.smartvan.fw.victron/"    // a directory from another project
# "https://github.com/.../tags/1.0.0.tar.gz"  // a single compressed file downloaded from an url
# ```
# Whe it downloads a compressed file from an url dependency, it will be extracted
# into the destination directory.
# By default, the destination dir is set as `$DIST_DIR/deps`. But it can
# customized by dependency just adding the `@dep/dest/dir` string at the end of
# the dependency string, e.g.: `https://myurl.com/assets/docs.tar.gz@docs/`.
# Destination dir must be a path relative to the `$DIST_DIR/`.
JOD_DIST_DEPS=(
  "https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.victron/archive/refs/tags/1.0.2.tar.gz@deps/com.robypomper.smartvan.fw.victron"
  "https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.upspack_v3/archive/refs/tags/1.0.0.tar.gz@deps/com.robypomper.smartvan.fw.upspack_v3"
  "https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sim7600/archive/refs/tags/1.0.0.tar.gz@deps/com.robypomper.smartvan.fw.sim7600"
  "https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.sensehat/archive/refs/tags/1.0.0.tar.gz@deps/com.robypomper.smartvan.fw.sensehat"
  "https://github.com/Smart-Van-2-0/com.robypomper.smartvan.fw.ioexp/archive/refs/tags/1.0.0.tar.gz@deps/com.robypomper.smartvan.fw.ioexp"
)

# ########## #
# JOD Object #
# ########## #

# JOD Agent version to include in the generated distribution
# JOD agent's and his dependencies will be first downloaded from central maven
# repository, if not available, then will be copied from local maven repository.
DIST_JOD_VER="2.2.4-DEV"

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
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/log4j2_TMPL[_224].xml'
# file.
# The 'log4j2_TMPL.xml' is a Log4j2 config file used to print logs on console,
# on files, on network listeners...
# The file path must be relative to the $JOD_DIST_DIR.
#DIST_JOD_CONFIG_LOGS_TMPL="dists/configs/log4j2_TMPL[_224].xml"

# JOD Object's structure files
# A file path for a valid 'struct.jod' file to include in the built
# JOD Distribution.
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/struct.jod'
# file.
# The file path must be relative to the $JOD_DIST_DIR.
#DIST_JOD_STRUCT="dists/configs/struct.jod"

# JOD Object's shell configs files
# A file path for a valid 'jod_configs' file to include in the built
# JOD Distribution. The path must not include the file extension, because
# the build script will add the '.sh' and `.ps1` extensions and copy both files.
# By default, (value = "") use preconfigured '$JOD_DIST_DIR/dists/configs/jod_configs'
# file.
# The file path must be relative to the $JOD_DIST_DIR./
#DIST_JOD_SHELL_CONFIGS="dists/configs/jod_configs"

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
