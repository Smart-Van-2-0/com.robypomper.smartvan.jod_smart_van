#!/bin/bash

################################################################################
# The John Operating System Project is the collection of software and configurations
# to generate IoT EcoSystem, like the John Operating System Platform one.
# Copyright (C) 2022 Roberto Pompermaier
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

#
# TAG = { ... }
# PROPERTY = "key": "value"
#            "key": TAG
#


# ################# #
# Query JSON string #
# ################# #

## JSON  string containing JSON code
## PROP_NAME  the name of the property to be extracted
#function extractProp() {
#  JSON=$1
#  PROP_NAME=$2
#
#  # ...
#}

# JSON  string containing JSON code
# TAG_NAME  the name of the tag to be extracted
function extractTag() {
  JSON=$1
  TAG_NAME=$2

  # idx of start contains tag
  searchStr="\"$TAG_NAME"
  rest=${JSON#*$searchStr}
  idxStart=$(( ${#JSON} - ${#rest} - ${#searchStr} ))
  if [[ "$idxStart" -lt 0 ]]
  then
    echo "Error tag '$TAG_NAME' not found"
    return
  fi
  #echo "idxStart=$idxStart" >&2

  # string post include contains tag
  JSONpost_INC=${JSON:$idxStart}
  #echo "JSONpost_INC=\"$JSONpost_INC\"" >&2

  # idx of end contains tag
  open=false
  tot=0
  count=0
  tag=""
  for (( i=0; i<${#JSONpost_INC}; i++ ))
  do
    c="${JSONpost_INC:$i:1}"
    #echo -n "[$count]$c" >&2
    tag="$tag$c"

    if [ "$c" == "{" ]; then
      open=true
      tot=$(($tot+1))
      #echo "$tot" >&2
    elif [ "$c" == "}" ]; then
      tot=$(($tot-1))
      #echo "$tot" >&2
    fi

    if [[ "$tot" -eq "0" ]] && [ "$open" = true ]; then
      break
    fi

    count=$((count+1))
  done
  #echo "" >&2

  #echo "tag=\"$tag\"" >&2
  echo "$tag"
}

# TAG  string containing the JSON tag to list his properties
# LEVEL  the JSON level to looking for (LEVEL=0 return the TAG's name)
function listPropertiesSubLevel() {
  TAG=$1
  LEVEL=${2:-1}

  open="false"; currentLevel=0; count=0
  inApex="false"; apexContent="";
  inPropName="false"; propArray=()

  # for each char in 'tag'
  for (( i=0; i<${#TAG}; i++ ))
  do
    c="${TAG:$i:1}"
    #echo -n "[$count]$c" >&2

    # incr/decr 'current level' depending on parsed '{' and '}' chars
    if [ "$c" == "{" ]; then
      open="true"
      currentLevel=$(($currentLevel+1))
      #echo "$currentLevel" >&2
    elif [ "$c" == "}" ]; then
      currentLevel=$(($currentLevel-1))
      #echo "$currentLevel" >&2
    fi

    # if 'current level' = 'required level', analyze content
    if [[ "$currentLevel" -eq "$LEVEL" && ( "$LEVEL" -eq "0" || "$open" == "true" ) ]]; then

      # if current char is '"', switch 'apex string' and (if needed) store 'property key'
      if [[ "$c" == "\"" ]]; then
        inApex=$([[ "$inApex" == "true" ]] && echo "false" || echo "true" )
        #echo "[$count]APEX=$inApex" >&2

        # on exit 'apex string'
        if [[ "$inApex" == "false" ]]; then
          # if in 'property name' > store 'property key'
          if [[ "$inPropName" == "true" ]]; then
            propArray+=("$apexContent")
            #echo "APEX_CONT=$apexContent" >&2
          fi

          # reset 'apex string'
          apexContent=""
        fi

        # on enter 'apex string'
        if [[ "$inApex" == "true" ]]; then
          # update 'property name' (1st apex string is property key, 2nd id property value (or tag content))
          inPropName=$([[ "$inPropName" == "true" ]] && echo "false" || echo "true" )
          #echo "APEX_PROP=$inPropName" >&2
        fi
      fi

      # if in 'apex string', add current char to 'apex string'
      if [[ "$inApex" == "true" ]]; then
        if [[ "$c" != "\"" ]]; then
          apexContent="$apexContent$c"
        fi
      fi
    fi

    # if 'current level' > 'required level', exit from 'property name'
    if [[ "$currentLevel" -gt "$LEVEL" ]]; then
      inPropName="false"
    fi

    count=$((count+1))
  done
  #echo "" >&2

  for i in "${propArray[@]}"; do
    echo "$i"
  done
}

# TAG  string containing the JSON tag to get his properties
function listProperties() {
  TAG=$1

  PROPERTIES="$(listPropertiesSubLevel "$TAG" 1)"
  IFS=$'\n' read -rd '' -a ARR <<<"$PROPERTIES"

  for i in "${ARR[@]}"
  do
    echo "$i"
  done
}

# TAG  string containing the JSON tag to get his name
function getTagName() {
  TAG=$1

  PROPERTIES="$(listPropertiesSubLevel "$TAG" 0)"
  IFS=$'\n' read -rd '' -a ARR <<<"$PROPERTIES"
  if [[ "${#ARR[@]}" -ne "1" ]]
  then
    echo "Error given tag wrong formatted (the JSON string representing a tag must be '\"tag_name\" : {...}'"
    return
  fi

  echo "${ARR[0]}"
}

# TAG  string containing the JSON tag to format
function formatTag() {
  TAG=$1

  # remove all new lines
  TAG=${TAG//$'\n'/}
  TAG=${TAG%$'\n'}

  # add new lines for each { and }
  tmp=""
  for (( i=0; i<${#TAG}; i++ ))
  do
    c="${TAG:$i:1}"
    if [[ "$c" == "{" ]]; then
      tmp="$tmp$c"$'\n'
    elif [[ "$c" == "}" ]]; then
      tmp="$tmp"$'\n'"$c"
    elif [[ "$c" == "," ]]; then
      tmp="$tmp$c"$'\n'
    else
      tmp="$tmp$c"
    fi
  done
  TAG=$tmp

  # for each line
  IFS=$'\n' read -rd '' -a ARR <<<"$TAG"
  tmp=""
  indent="  "; indentCount=0
  for i in "${ARR[@]}"
  do
    # trim line
    i="$(echo $i | sed 's/ *$//g')"
    [[ -z "$i" ]] && continue

    #  if line contains }, decrement indent
    [[ "$i" == *"}" || "$i" == *"}"* ]] && indentCount=$((indentCount-1))

    #  add indent to line
    repeat() { for ((ir=0; ir<$2; ir++)); do echo -n "$1"; done }
    indentStr="$(repeat "$indent" $indentCount)"
    i="$indentStr$i"

    # add line to result
    tmp="$tmp$i"$'\n'

    #  if line contains {, increment indent
    [[ "$i" == *"{" || "$i" == *"{"* ]] && indentCount=$((indentCount+1))
  done
  TAG=$tmp

  echo "$TAG"
}


# ################## #
# Update JSON string #
# ################## #

# TAG  string containing the JSON tag where to add the SUB_TAG
# SUB_TAG  string containing the JSON tag to add to the TAG
function addTag() {
  TAG=$1
  SUB_TAG=$2

  # list tag's properties
  PROPERTIES="$(listProperties "$TAG")"
  IFS=$'\n' read -rd '' -a ARR <<<"$PROPERTIES"
  #for i in "${ARR[@]}"; do
  #  echo "- $i" >&2
  #done

  # get sub tag's name
  tagName=$(getTagName "$SUB_TAG")
  #echo "#$tagName#" >&2

  # check if sub tag's name conflict with a property name already present
  for i in "${ARR[@]}"; do
    if [[ "$tagName" == "$i" ]]
    then
      echo "Error adding sub-tag '$tagName' because tag already contains another property with the same name"
      return
    fi
  done

  postTag=${TAG##*\}}
  #echo "#$postTag#" >&2

  tagWithoutEnd=${TAG:0:${#TAG}-${#postTag}-1}
  #echo "#$tagWithoutEnd#" >&2

  tagEnd=${TAG:${#TAG}-${#postTag}-1}
  #echo "#$tagEnd#" >&2

  if [[ "${#ARR[@]}" -ne "0" ]]; then
    TAG="$tagWithoutEnd,$SUB_TAG"$'\n'"$tagEnd"
  else
    TAG="$tagWithoutEnd$SUB_TAG"$'\n'"$tagEnd"
  fi
  #echo "$TAG"
  #return

  formatTag "$TAG"
}
