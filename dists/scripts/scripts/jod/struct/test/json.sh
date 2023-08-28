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
# Artifact: JOD Dist Template
# Version:  1.0.3
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
source "$SCRIPT_DIR/../builder.sh"


# ################# #
# Query JSON string #
# ################# #

strJSON="\"tag1\" : {
  \"prop1\": \"value1\",
  \"subtag\" : {
  },
  \"propN\": \"valueN\"
}"

echo "#### extractTag test (main) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
echo "$strTAG"
echo "#### extractTag test (main) - END"

#echo "#### extractTag test (property) - START"
#strPROP="$(extractProp "$strJSON" "prop1")"
#echo "$strPROP"
#echo "#### extractTag test (property) - END"

echo "#### extractTag test (tag) - START"
strSUB_TAG="$(extractTag "$strJSON" "subtag")"
echo "$strSUB_TAG"
echo "#### extractTag test (tag) - END"

echo "#### extractTag test (not-exist) - START"
strERROR="$(extractTag "$strJSON" "not-exist")"
echo "$strERROR"
echo "#### extractTag test (not-exist) - END"


echo "#### listPropertiesSubLevel test (tag1=0) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
arrTAG_PROPS="$(listPropertiesSubLevel "$strTAG" 0)"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "> $i"
done
echo "#### listPropertiesSubLevel test (tag1=0) - END"

echo "#### listPropertiesSubLevel test (tag1=1) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
arrTAG_PROPS="$(listPropertiesSubLevel "$strTAG" 1)"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "> $i"
done
echo "#### listPropertiesSubLevel test (tag1=1) - END"


echo "#### listProperties test (tag1) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
arrTAG_PROPS="$(listProperties "$strTAG")"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "> $i"
done
echo "#### listProperties test (tag1) - END"

echo "#### listProperties test (subtag) - START"
strSUB_TAG="$(extractTag "$strJSON" "subtag")"
arrTAG_PROPS="$(listProperties "$strSUB_TAG")"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "> $i"
done
echo "    it must be empty"
echo "#### listProperties test (subtag) - END"


echo "#### getTagName test (tag1) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
strTAG_NAME="$(getTagName "$strTAG")"
echo ">$strTAG_NAME"
echo "#### getTagName test (tag1) - END"

echo "#### getTagName test (subtag) - START"
strSUB_TAG="$(extractTag "$strJSON" "subtag")"
strTAG_NAME="$(getTagName "$strSUB_TAG")"
echo ">$strTAG_NAME"
echo "#### getTagName test (subtag) - END"


# ################## #
# Update JSON string #
# ################## #

strJSON="\"tag1\" : {
  \"prop1\": \"value1\",
  \"subtag\" : {
  },
  \"propN\": \"valueN\"
}"
strJSONSubTag1="\"subTag1\" : {
  \"k1\": \"v1\",
  \"k2\" : \"v2\"
}"
strJSONSubTag2="\"subTag2\" : {
  \"k1\": \"v1\",
  \"k2\" : \"v2\"
}"

echo "#### extractTag test (main) - START"
strTAG="$(extractTag "$strJSON" "tag1")"
arrTAG_PROPS="$(listProperties "$strTAG")"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "PRE $i"
done

strTAG="$(addTag "$strTAG" "$strJSONSubTag1")"
strTAG="$(addTag "$strTAG" "$strJSONSubTag2")"

arrTAG_PROPS="$(listProperties "$strTAG")"
IFS=$'\n' read -rd '' -a ARR <<<"$arrTAG_PROPS"
for i in "${ARR[@]}"; do
  echo "POST $i"
done
echo "#### extractTag test (main) - END"
