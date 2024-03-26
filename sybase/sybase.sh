#!/bin/bash
set echo off

PLUGIN_VERSION="1"
HEARTBEAT_REQUIRED="true"


HOST="localhost"
PORT="5000"
USERNAME="sa"
PASSWORD="site24x7"
JAVA_HOME="/usr/bin"

PLUGIN_FOLDER_NAME="sybase"

PLUGIN_PATH="/home/local/ZOHOCORP/sathvika-11460/Downloads/BACKUP/Downloads/Plugins/sybase"
export CLASS_PATH=$PLUGIN_PATH/json-20140107.jar:$PLUGIN_PATH/jconn4.jar

$JAVA_HOME/javac -cp $CLASS_PATH -d $PLUGIN_PATH $PLUGIN_PATH"/sybase.java"
data=$($JAVA_HOME/java -cp $CLASS_PATH:$PLUGIN_PATH "sybase" $PLUGIN_VERSION $HEARTBEAT_REQUIRED $HOST $PORT $USERNAME $PASSWORD)

echo "$data"
