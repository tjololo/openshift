#!/bin/bash

number_regex='^[0-9]+$'
jar_regex='.*\.jar$'

function f_find_number_of_artifacts {
    if [ $# -ne 4 ]; then
        echo "Wrong number of arguments supplied. Usage: f_check_number_of_artifacts bamboo_planKey bamboo_buildNumber bamboo_username bamboo_password"
        return 0
    fi
    NUMBER_OF_ARTIFACTS=`curl --user $3:$4 -s "${BAMBOO_HOST}/rest/api/latest/result/$1/$2.json?expand=artifacts" | jsawk "return this.artifacts.size"` 2> /dev/null
}

function f_find_bamboo_artifact_url {
    if [ $# -lt 4 ]; then
        echo "Wrong number of arguments supplied. Usage: f_find_bamboo_artifact_url bamboo_planKey bamboo_buildNumber bamboo_username bamboo_password [artifact_name]"
        return 0
    fi
    RESPONSE=`curl --user $3:$4 -s "${BAMBOO_HOST}/rest/api/latest/result/$1/$2.json?expand=artifacts"`
    if [ $NUMBER_OF_ARTIFACTS -gt 1 ]; then
        if [ -n "$5" ]; then
            i=0
            while [ $i -lt $NUMBER_OF_ARTIFACTS ]; do
                ARTIFACT_NAME=`echo "$RESPONSE" | jsawk "return this.artifacts.artifact[$i].name"`
                if [ "$ARTIFACT_NAME" == "$5" ]; then
                    ARTIFACT_URL=`echo "$RESPONSE" | jsawk "return this.artifacts.artifact[$i].link.href"`
                    break
                fi
                i=$[$i+1]
            done
        else
            echo "Artifact name must be defined"
            return 0
        fi
    else
        ARTIFACT_URL=` echo "$RESPONSE" | jsawk "return this.artifacts.artifact[0].link.href"`
    fi
}

function f_download_bamboo_artifact {
    if [ $# -lt 5 ]; then
        echo "Wrong number of arguments supplied. Usage: f_find_bamboo_artifact_url bamboo_planKey bamboo_buildNumber bamboo_username bamboo_password download_dir [artifact_name]"
        return 0
    fi
    echo "Trying to find artifact on $BAMBOO_HOST"
    f_find_number_of_artifacts $1 $2 $3 $4
    if ! [[ $NUMBER_OF_ARTIFACTS =~ $number_regex ]]; then
      echo "Could not find bamboo artifact"
      return 0
    fi
    if [ $NUMBER_OF_ARTIFACTS -gt 1 -a $# -lt 6 ]; then
        if [ -z "$6" ]; then
           echo "More than one artifact in build, please supply wanted artifacts name"
           return 0
        fi
    fi
    f_find_bamboo_artifact_url $1 $2 $3 $4 $6
    if ! [[ $ARTIFACT_URL =~ $jar_regex ]]; then
      echo "Could not find bamboo artifact"
      return 0
    fi
    echo "Found artifact: ${ARTIFACT_URL}"
    curl --user $3:$4 -s -o $5 -O ${ARTIFACT_URL}
}
