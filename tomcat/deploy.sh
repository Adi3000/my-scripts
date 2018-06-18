#!/bin/bash

if [ $# -lt 1 ]; then
        echo "Not enough argument" 1>&2
        echo "Usage: $0 <groupId:artifactId:version> [<environment>]" 1>&2
        exit 1
fi


TOMCAT_HOME=$(test -z "$TOMCAT_HOME" && echo $TOMCAT_HOME || echo "/opt/tomcat")
TOMCAT_DEPLOY_CONFIG=$TOMCAT_HOME/conf/deployment.properties
TOMCAT_DEPLOY_DIR=$TOMCAT_HOME
NXFETCH=/usr/local/bin/nxfetch
WGET=/usr/bin/wget
WAR_TEMP_DIR=$HOME/temp
USER_MANAGER=tomcat
PASSWORD_MANAGER=tomcat

artifact=$1
shift
environment=$1

if [ ! -d $TOMCAT_HOME ]; then
        echo "No such directory for TOMCAT_HOME : $TOMCAT_HOME" 1>&2
        exit 2
fi

if [ ! -d $TOMCAT_HOME ]; then
        echo "No such directory for TOMCAT_TEMP_DIR : $TOMCAT_HOME" 1>&2
        exit 3
fi

if [ ! -f $TOMCAT_DEPLOY_CONFIG ]; then
        echo "No such file for TOMCAT_DEPLOY_CONFIG : $TOMCAT_DEPLOY_CONFIG" 1>&2
        exit 4
fi

groupid="$(echo "$artifact" | cut -d: -f1)"
artifactid="$(echo "$artifact" | cut -d: -f2)"
versionid="$(echo "$artifact" | cut -d: -f3)"
groupartifactid="$(echo "${groupid}:${artifactid}")"

war_file=${artifactid}.war

pattern_for_param="^$groupartifactid.*$environment"
command_param=$(grep -m 1 $pattern_for_param $TOMCAT_DEPLOY_CONFIG)

if [ -z "$command_param" ]; then
        echo "$groupartifactid ($environment) is not set in configuration $TOMCAT_DEPLOY_CONFIG" 1>&2
        echo "Usage: $0 <groupId:artifactId:version> <environment>"
        exit 5
fi

#destionation=$TOMCAT_DEPLOY_DIR/$(echo "$command_param" | cut -f2 -s)
tomcat_manager=$(echo "$command_param" | cut -f2 -s)
deploy_path=$(echo "$command_param" | cut -f3 -s)
if [ ! -d $destionation ]; then
        echo "Check $TOMCAT_DEPLOY_CONFIG : $destionation doesn't exists" 1>&2
        exit 6
fi
tmp_war_file_path=$WAR_TEMP_DIR/$war_file
echo "Begin transfert of $artifact to $tmp_war_file_path"
echo "$NXFETCH -v -i $artifact > $tmp_war_file_path"
$NXFETCH -v -i $artifact > $tmp_war_file_path
if [ $(head $tmp_war_file_path | grep -c "^<html>") -gt 0 ]; then
        echo -e "Error on fetching nexus :\n $(cat $tmp_war_file_path)" 1>&2
        exit 9
fi

echo "Starting deployment of $artifact on host '$tomcat_manager' (path $deploy_path)"
manager_message=$(curl -s -T - -u ${USER_MANAGER}:${PASSWORD_MANAGER} "$tomcat_manager/manager/text/deploy?update=true&path=$deploy_path" < $tmp_war_file_path)
echo "TOMCAT MANAGER : $manager_message"
rm $tmp_war_file_path || exit 7
if [ $(echo $manager_message | grep -c ^OK) -eq 0 ]; then
        echo "Deployment error : $manager_message" 1>&2
        exit 8
fi
echo "Deployment success for $artifact on host $tomcat_manager (path $deploy_path)"
exit 0
