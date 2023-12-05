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
# bash $JOD_DIST_DIR/scripts/build.sh [JOD_DIST_CONFIG_FILE=configs/jod_dist_configs.sh]
#
# This script assemble a JOD Distribution based on specified JOD_DIST_CONFIG_FILE
# file.
#
# The JOD_DIST_CONFIG_FILE can be an absolute file path or a working dir relative
# path. Can be used also path relative to the distribution's project dir, for
# example the path 'configs/configs_test.sh' can be used also outside
# the $JOD_DIST_DIR folder.
#
# The generated JOD Distribution is build in 'build/$DIST_ARTIFACT/$DIST_VER'
# folder.
#
# Artifact: JOD Dist Template
# Version:  1.0.3
###############################################################################

JOD_DIST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/.."
source "$JOD_DIST_DIR/scripts/libs/include.sh" "$JOD_DIST_DIR"
source "$JOD_DIST_DIR/scripts/jod_tmpl/include.sh" "$JOD_DIST_DIR"

#DEBUG=true
[[ ! -z "$DEBUG" && "$DEBUG" == true ]] && setupLogsDebug || setupLogs

setupCallerAndScript "$0" "${BASH_SOURCE[0]}"

###############################################################################
logScriptInit

# Init JOD_DIST_CONFIG_FILE
JOD_DIST_CONFIG_FILE=${1:-configs/jod_dist_configs.sh}
[[ ! -f "$JOD_DIST_CONFIG_FILE" ]] && JOD_DIST_CONFIG_FILE="$JOD_DIST_DIR/$JOD_DIST_CONFIG_FILE"
[[ ! -f "$JOD_DIST_CONFIG_FILE" ]] && logFat "Can't find JOD Distribution config's file (missing file: $JOD_DIST_CONFIG_FILE)" $ERR_CONFIGS_NOT_FOUND
logScriptParam "JOD_DIST_CONFIG_FILE" "$JOD_DIST_CONFIG_FILE"

# Load jod distribution configs, exit if fails
execScriptConfigs $JOD_DIST_CONFIG_FILE

DEST_DIR="$JOD_DIST_DIR/build/$DIST_ARTIFACT/$DIST_VER"
CACHE_DIR="$JOD_DIST_DIR/build/cache"
JOD_JAR="$CACHE_DIR/jospJOD-$DIST_JOD_VER.jar"
JOD_URL="https://repo.maven.apache.org/maven2/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER.jar"
JOD_LOCAL_MAVEN="$HOME/.m2/repository/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER.jar"
JOD_DEPS_JAR="$CACHE_DIR/jospJOD-$DIST_JOD_VER-deps.jar"
JOD_DEPS_URL="https://repo.maven.apache.org/maven2/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER-deps.jar"
JOD_DEPS_LOCAL_MAVEN="$HOME/.m2/repository/com/robypomper/josp/jospJOD/$DIST_JOD_VER/jospJOD-$DIST_JOD_VER-deps.jar"

logInf "Load JOD Distribution configs..."

# DIST_JCP_ENV
[ -z "$DIST_JCP_ENV" ] && DIST_JCP_ENV="stage"
if [ "$DIST_JCP_ENV" == "local" ]; then
  DIST_JCP_ENV_API="localhost:9001"
  DIST_JCP_ENV_AUTH="localhost:8998"
elif [ "$DIST_JCP_ENV" == "stage" ]; then
  DIST_JCP_ENV_API="api-stage.johnosproject.org"
  DIST_JCP_ENV_AUTH="auth-stage.johnosproject.org"
elif [ "$DIST_JCP_ENV" == "prod" ]; then
  DIST_JCP_ENV_API="api.johnosproject.org"
  DIST_JCP_ENV_AUTH="auth.johnosproject.org"
else
  logFat "Invalid 'DIST_JCP_ENV'='$DIST_JCP_ENV' value, accepted values: 'prod', 'stage', 'local'. Exit" $ERR_CONFIGS_INVALID_DIST_JCP_ENV
fi

# DIST_JCP_ID
[ -z $DIST_JCP_ID ] && logFat "JCP Auth id not set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_MISSING_DIST_JCP_ID

# DIST_JCP_SECRET
[ -z $DIST_JCP_SECRET ] && logFat "JCP Auth secret not set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_MISSING_DIST_JCP_SECRET

#DIST_JOD_NAME

# DIST_JOD_ID
[ -n "$DIST_JOD_ID" ] && [ "$DIST_JCP_ENV" == "prod" ] && logFat "Can't build a prod (DIST_JCP_ENV config) distribution when the DIST_JOD_ID config is set. Please check your JOD script's configs file at '$JOD_DIST_CONFIG_FILE', exit." $ERR_CONFIGS_ILLEGAL_DIST_JOD_ID
[ -n "$DIST_JOD_ID" ] && DIST_JOD_ID_HW=${DIST_JOD_ID::5}

# DIST_JOD_WORK_PULLERS
[ "$DIST_JOD_VER" == "2.2.0" ] && SHELL_PULLER="PullerUnixShell" || SHELL_PULLER="PullerShell"
[ -z "$DIST_JOD_WORK_PULLERS" ] && DIST_JOD_WORK_PULLERS="\n shell://com.robypomper.josp.jod.executor.$SHELL_PULLER\n http://com.robypomper.josp.jod.executor.impls.http.PullerHTTP"

# DIST_JOD_WORK_LISTENERS
[ -z "$DIST_JOD_WORK_LISTENERS" ] && DIST_JOD_WORK_LISTENERS="\n file://com.robypomper.josp.jod.executor.ListenerFiles"
[ $DIST_JOD_VER != "2.2.3" ] && [ $DIST_JOD_VER != "2.2.2" ] && [ $DIST_JOD_VER != "2.2.1" ] && [ $DIST_JOD_VER != "2.2.0" ] && [ $DIST_JOD_VER != "2.2.0-alpha" ] && [ $DIST_JOD_VER != "2.0.1" ] && [ $DIST_JOD_VER != "2.0.0" ] \
  && DIST_JOD_WORK_LISTENERS+="\n dbus://com.robypomper.josp.jod.executor.impls.dbus.ListenerDBus"

# DIST_JOD_WORK_EXECUTORS
[ "$DIST_JOD_VER" == "2.2.0" ] && SHELL_EXECUTOR="ExecutorUnixShell" || SHELL_EXECUTOR="ExecutorShell"
[ -z "$DIST_JOD_WORK_EXECUTORS" ] && DIST_JOD_WORK_EXECUTORS="\n shell://com.robypomper.josp.jod.executor.$SHELL_EXECUTOR\n file://com.robypomper.josp.jod.executor.ExecutorFiles\n http://com.robypomper.josp.jod.executor.impls.http.ExecutorHTTP"
[ $DIST_JOD_VER != "2.2.3" ] && [ $DIST_JOD_VER != "2.2.2" ] && [ $DIST_JOD_VER != "2.2.1" ] && [ $DIST_JOD_VER != "2.2.0" ] && [ $DIST_JOD_VER != "2.2.0-alpha" ] && [ $DIST_JOD_VER != "2.0.1" ] && [ $DIST_JOD_VER != "2.0.0" ] \
  && DIST_JOD_WORK_EXECUTORS+="\n dbus://com.robypomper.josp.jod.executor.impls.dbus.ExecutorDBus"

# DIST_JOD_CONFIG_TMPL
[ -z "$DIST_JOD_CONFIG_TMPL" ] && DIST_JOD_CONFIG_TMPL="dists/configs/jod_TMPL.yml"

# DIST_JOD_CONFIG_LOGS_TMPL
if [ $DIST_JOD_VER == "2.2.3" ] \
  || [ $DIST_JOD_VER == "2.2.2" ] \
  || [ $DIST_JOD_VER == "2.2.1" ] \
  || [ $DIST_JOD_VER == "2.2.0" ] \
  || [ $DIST_JOD_VER == "2.2.0-alpha" ] \
  || [ $DIST_JOD_VER == "2.0.1" ] \
  || [ $DIST_JOD_VER == "2.0.0" ]; then
  DEF_DIST_JOD_CONFIG_LOGS_TMPL="dists/configs/log4j2_TMPL.xml"
else
  DEF_DIST_JOD_CONFIG_LOGS_TMPL="dists/configs/log4j2_TMPL_224.xml"
fi
[ -z "$DIST_JOD_CONFIG_LOGS_TMPL" ] && DIST_JOD_CONFIG_LOGS_TMPL=$DEF_DIST_JOD_CONFIG_LOGS_TMPL

# DIST_JOD_STRUCT: jod's structure file, path from $JOD_DIST_DIR      ; default: dists/configs/struct.jod
[ -z "$DIST_JOD_STRUCT" ] && DIST_JOD_STRUCT="dists/configs/struct.jod"

# DIST_JOD_STRUCT: jod's structure file, path from $JOD_DIST_DIR      ; default: dists/configs/jod_configs
[ -z "$DIST_JOD_SHELL_CONFIGS" ] && DIST_JOD_SHELL_CONFIGS="dists/configs/jod_configs"

# $DIST_JOD_OWNER: josp user's id            ; default: "00000-00000-00000" as Anonymous user
[ -z "$DIST_JOD_OWNER" ] && DIST_JOD_OWNER="00000-00000-00000"

# $DIST_JOD_COMM_DIRECT_ENABLED: "true|false"              ; default: "true"
[ -z "$DIST_JOD_COMM_DIRECT_ENABLED" ] && DIST_JOD_COMM_DIRECT_ENABLED="true"

# $DIST_JOD_COMM_CLOUD_ENABLED: "true|false"              ; default: "true"
[ -z "$DIST_JOD_COMM_CLOUD_ENABLED" ] && DIST_JOD_COMM_CLOUD_ENABLED="true"

logInf "JOD Distribution configs loaded successfully"

###############################################################################
logScriptRun

logInf "Build JOD Distribution..."

logDeb "Clean an re-create JOD Distribution build dirs"
rm -rf "$DEST_DIR" >/dev/null 2>&1
mkdir -p "$DEST_DIR"
mkdir -p "$DEST_DIR/configs"
mkdir -p "$DEST_DIR/libs"
mkdir -p "$DEST_DIR/scripts"

logDeb "Prepare JOD library"
if [ ! -f "$JOD_JAR" ]; then
  logDeb "Download JOD library from $JOD_URL"
  mkdir -p "$CACHE_DIR"
  curl --fail -s -m 5 "$JOD_URL" -o "$JOD_JAR"
  if [ "$?" -ne 0 ]; then
    logWar "Can't download JOD library from '$JOD_URL' url, try on local maven repository"
    cp "$JOD_LOCAL_MAVEN" "$JOD_JAR" 2>/dev/null
    if [ "$?" -ne 0 ]; then
      logWar "Can't found JOD library in local maven repository at '$JOD_LOCAL_MAVEN'"
      logFat "Can't get JOD library, exit." $ERR_GET_JOD_LIB
    fi
  fi
fi
cp "$JOD_JAR" "$DEST_DIR/libs/"
cp "$JOD_JAR" "$DEST_DIR/jospJOD.jar"

logDeb "Prepare JOD dependencies"
if [ ! -f "$JOD_DEPS_JAR" ]; then
  logDeb "Download JOD dependencies from $JOD_DEPS_URL"
  mkdir -p "$CACHE_DIR"
  curl --fail -s -m 5 "$JOD_DEPS_URL" -o "$JOD_DEPS_JAR"
  if [ "$?" -ne 0 ]; then
    logWar "Can't download JOD dependencies from '$JOD_DEPS_URL' url, try on local maven repository"
    cp "$JOD_DEPS_LOCAL_MAVEN" "$JOD_DEPS_JAR" 2>/dev/null
    if [ "$?" -ne 0 ]; then
      logWar "Can't found JOD dependencies in local maven repository at '$JOD_DEPS_LOCAL_MAVEN'"
      logFat "Can't get JOD dependencies, exit." $ERR_GET_JOD_DEPS_LIB
    fi
  fi
fi
cd "$DEST_DIR/libs/" && jar xf "$JOD_DEPS_JAR" && cd - >/dev/null 2>&1 || (
  logFat "Can't prepare JOD Dependencies because can't extract from '$JOD_DEPS_JAR' in to '$DEST_DIR/libs/', exit." $ERR_GET_JOD_DEPS_LIB
)

logDeb "Import Distribution dependencies"
if [[ ! -z "$JOD_DIST_DEPS" ]]; then
  TOTAL=${#JOD_DIST_DEPS[@]}
  if [[ $TOTAL -eq 0 ]]; then
    logInf "No dependencies to import, terminate script" && logScriptEnd

  else
    logInf "Import Distribution dependencies (found $TOTAL deps)..."
    DEST_DIR_DEPS="$DEST_DIR/deps"
    if [ ! -d "$CACHE_DIR" ]; then
      logDeb "Create cache dir..."
      mkdir -p "$CACHE_DIR"
    fi
    logDeb "Create or reset destination dir at '$DEST_DIR_DEPS'..."
    if [ -d "$DEST_DIR_DEPS" ]; then
      rm -fr "$DEST_DIR_DEPS"
    fi
    mkdir -p "$DEST_DIR_DEPS"
    # dependencies loop
    COUNT=0
    COUNT_SUCCESS=0
    for dep_prop in "${JOD_DIST_DEPS[@]}"
    do
      ((COUNT+=1))
      # import stats
      pre_import=$(find "$DEST_DIR_DEPS" -type f | wc -l)
      # extract src and dest
      if [[ "$dep_prop" == *"@"* ]]; then
        IFS='@' read -ra dep_prop_split <<< "$dep_prop"
        dep_src=${dep_prop_split[0]}
        dep_dest=${dep_prop_split[1]}
        [ "${dep_dest:0:1}" = "/" ] && logWar "Only relative path allowed for destination dir. Please check the '$dep_dest' path. Skipp the dependency." && continue
        dep_dest="$DEST_DIR/$dep_dest"
        if [ -d "$dep_dest" ]; then
          rm -fr "$dep_dest"
        fi
        mkdir -p "$dep_dest"
      else
        dep_src=$dep_prop
        dep_dest=$DEST_DIR_DEPS
      fi
      # get dependency
      if [[ "$dep_src" == *"://"* ]]; then
        # get url dependency
        logInf "Get dependency. . . . . ($COUNT/$TOTAL) - $dep_src"
        dep_dir="$CACHE_DIR/$(echo "$dep_src" | tr '://.' _)"
        [ -d "$dep_dir" ] && logDeb "Dependency already cached, skip download"
        [ ! -d "$dep_dir" ] && logInf "Download dependency to local cache..." && WGET_OUT="$(wget -P "$dep_dir" "$dep_src" 2>&1)"
        [ ! -d "$dep_dir" ] && logWar "An error occurred during dependency download, skip it." \
          && logWar "#### #### #### #### #### #### #### #### #### #### #### ####" \
          && logWar "WGET Error Log:" \
          && echo "$WGET_OUT" \
          && logWar "#### #### #### #### #### #### #### #### #### #### #### ####" && continue
        # extract downloaded file, if it's a compressed file
        dwn_files=$(find "$dep_dir" -type f | wc -l)
        if [[ $dwn_files -eq 1 ]]; then
          file_name=$(ls "$dep_dir")
          if [[ "$file_name" =~ .*gz ]]; then
            tar -xf "$dep_dir/$file_name" -C "$dep_dest"
          fi
          # check if extracted file is a single dir and move his content one level up
          dwn_dirs=$(find "$dep_dest" -mindepth 1 -maxdepth 1 -type d | wc -l)
          if [[ $dwn_dirs -eq 1 ]]; then
            dir_name=$(ls "$dep_dest")
            logDeb "Move '$dep_dest/$dir_name/*' into '$dep_dest'"
            mv "$dep_dest/$dir_name"/* "$dep_dest" 2>&1
            rm -rf "$dep_dest"/"${dir_name:?}" 2>&1
          fi
        fi
      else
        # get local dependency
        logInf "Copy dependency . . . . ($COUNT/$TOTAL) - $dep_src"
        if [[ ! -d "$dep_src" ]] && [[ ! -f "$dep_src" ]]; then
          logWar "Missing local dir or file for '$dep_src' dependency, skip it."
          continue
        fi
        cp -r "$dep_src" "$dep_dest"        # TODO: add a build's config to define what must be excluded from copy
        dir_dest=$(basename "$dep_src")
        #rm -rf "$dep_dest/$dir_dest/venv" >/dev/null 2>&1
        rm -rf "$dep_dest/$dir_dest/logs" >/dev/null 2>&1
        rm -rf "$dep_dest/$dir_dest/.idea" >/dev/null 2>&1
        rm -rf "$dep_dest/$dir_dest/.git" >/dev/null 2>&1
      fi
      # import stats
      post_import=$(find "$DEST_DIR_DEPS" -type f | wc -l)
      imported_files=$((post_import-pre_import))
      logInf "Imported $imported_files files from dependency"
      ((COUNT_SUCCESS+=1))
    done
    logInf "Distribution dependencies ($COUNT_SUCCESS/$TOTAL) imported successfully"
  fi
fi

logDeb "Generate JOD main configs 'jod.yml' file"
sed -e 's|%DIST_JCP_ENV_API%|'"$DIST_JCP_ENV_API"'|g' \
  -e 's|%DIST_JCP_ENV_AUTH%|'"$DIST_JCP_ENV_AUTH"'|g' \
  -e 's|%DIST_JCP_ID%|'"$DIST_JCP_ID"'|g' \
  -e 's|%DIST_JCP_SECRET%|'"$DIST_JCP_SECRET"'|g' \
  -e 's|%DIST_JOD_NAME%|'"$DIST_JOD_NAME"'|g' \
  -e 's|%DIST_JOD_ID%|'"$DIST_JOD_ID"'|g' \
  -e 's|%DIST_JOD_ID_HW%|'"$DIST_JOD_ID_HW"'|g' \
  -e 's|%DIST_JOD_WORK_PULLERS%|'"$DIST_JOD_WORK_PULLERS"'|g' \
  -e 's|%DIST_JOD_WORK_LISTENERS%|'"$DIST_JOD_WORK_LISTENERS"'|g' \
  -e 's|%DIST_JOD_WORK_EXECUTORS%|'"$DIST_JOD_WORK_EXECUTORS"'|g' \
  -e 's|%DIST_JOD_OWNER%|'"$DIST_JOD_OWNER"'|g' \
  -e 's|%DIST_JOD_COMM_DIRECT_ENABLED%|'"$DIST_JOD_COMM_DIRECT_ENABLED"'|g' \
  -e 's|%DIST_JOD_COMM_CLOUD_ENABLED%|'"$DIST_JOD_COMM_CLOUD_ENABLED"'|g' \
  "$JOD_DIST_DIR/$DIST_JOD_CONFIG_TMPL" >"$DEST_DIR/configs/jod.yml"

logDeb "Generate JOD logs configs 'log4j2.xml' file"
sed -e 's|%DIST_JOD_VER%|'"$DIST_JOD_VER"'|g' \
  "$JOD_DIST_DIR/$DIST_JOD_CONFIG_LOGS_TMPL" >"$DEST_DIR/log4j2.xml"



logDeb "Copy JOD Distribution configs"
cp -r "$JOD_DIST_DIR/$DIST_JOD_STRUCT" "$DEST_DIR/configs/struct.jod"
[ "$?" -ne 0 ] && logFat "Can't include 'struct.jod' to JOD Distribution because can't copy file '$JOD_DIST_DIR/$DIST_JOD_STRUCT'" $ERR_GET_DIST_JOD_STRUCT
cp -r "$JOD_DIST_DIR/$DIST_JOD_SHELL_CONFIGS.sh" "$DEST_DIR/configs/configs.sh"
[ "$?" -ne 0 ] && logFat "Can't include 'jod_configs.sh' to JOD Distribution because can't copy file '$JOD_DIST_DIR/$DIST_JOD_SHELL_CONFIGS.sh'" $ERR_GET_JOD_CONFIGS
cp -r "$JOD_DIST_DIR/$DIST_JOD_SHELL_CONFIGS.ps1" "$DEST_DIR/configs/configs.ps1"
[ "$?" -ne 0 ] && logFat "Can't include 'jod_configs.ps1' to JOD Distribution because can't copy file '$JOD_DIST_DIR/$DIST_JOD_SHELL_CONFIGS.ps1'" $ERR_GET_JOD_CONFIGS

logDeb "Generate JOD Distribution dist_configs.sh and dist_configs.ps1"
echo "#!/bin/bash
export JOD_DIST_NAME=\"$DIST_ARTIFACT\"
export JOD_DIST_VER=\"$DIST_VER\"
" >"$DEST_DIR/configs/dist_configs.sh"
echo "#!/usr/bin/env powershell
\$global:JOD_DIST_NAME='$DIST_ARTIFACT'
\$global:JOD_DIST_VER='$DIST_VER'" >"$DEST_DIR/configs/dist_configs.ps1"

logDeb "Copy JOD Distribution scripts"
cp -r "$JOD_DIST_DIR/dists/scripts/"* "$DEST_DIR"
[ "$?" -ne 0 ] && logFat "Can't include 'scripts' dir to JOD Distribution because can't copy dir '$JOD_DIST_DIR/dists/scripts'" $ERR_GET_JOD_SCRIPTS

logDeb "Copy JOD Distribution resources"
cd "$JOD_DIST_DIR/dists/resources"
find . -type f -not \( -name '*_EXMPL' -o -path '*_EXMPL*' \) -exec cp '{}' "$DEST_DIR"/'{}' ';'
RES="$?"
cd - > /dev/null
[ $RES -ne 0 ] && logFat "Can't include 'resources' dir to JOD Distribution because can't copy dir '$JOD_DIST_DIR/dists/resources'" $ERR_GET_JOD_RESOURCES

logDeb "Generate JOD Distribution VERSIONS.md"
echo "# JOD '$DIST_NAME' Distribution

JOD Distribution Version:           $DIST_VER
JOD Distribution TEMPLATE Version:  $JOD_TMPL_VERSION
JOD included Version:               $DIST_JOD_VER" >"$DEST_DIR/VERSIONS.md"

logInf "JOD Distribution built successfully"

###############################################################################
logScriptEnd
