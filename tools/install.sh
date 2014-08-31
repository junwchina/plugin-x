#!/bin/bash 

help()
{
cat << EOF
usage: $0 -s sdk1:sdk2 -p project_path options

OPTIONS:
   -h      Show help message
   -s      sdk list. i.e: admob:flurry
   -l      list all plugins
   -v      Verbose
EOF
}

check_requirements()
{
  type gawk >/dev/null 2>&1 || { echo >&2 "gawk is required, PLZ install it first."; exit 1; }
}

SHELL_DIR=$(cd "$(dirname "$0")"; pwd)
pushd ${SHELL_DIR}

source ./config.sh
check_requirements

plugins=()
project_path=""

while getopts "hvls:p:" OPTION
do 
  case $OPTION in 
    h)
      help
      exit 1
      ;;
    v) 
      set -x
      ;;
    l) 
      echo "Plugin List:"
      for plugin in ${ALL_PLUGINS[@]}
      do 
        echo ${plugin}
      done
      exit 0
      ;;
    s)
      plugins=${OPTARG}
      ;;
    p)
      project_path=${OPTARG}
      ;;
    ?)
      help 
      exit 0
      ;;
  esac
done

length=${#plugins[@]}
if [ ${length} -eq 0 -o !-d ${project_path} ]; then 
  help 
  exit 1
fi 

SHELL_DIR=$(cd "$(dirname "$0")"; pwd)
pushd ${SHELL_DIR}

./publish.sh $plugins

if [ $? -ne 0 ]; then 
  echo "Error occurs, please have a check your plugin configuration and try again!"
  exit 1
fi

plugin_arr=(${plugins// /:})
plugin_with_prefix_arr=()
for i in {1..${#plugin_arr[@]}}
do 
  plugin-with_prefix_err[i]=plugin/${plugin_arr[i]}
done

plugin_with_prefix=${plugin_with_prefix_arr[@]}
./toolsForGame/addPluginForGame.sh ${project_path} ${plugin_with_prefix// /:}
