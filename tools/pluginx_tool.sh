#!/bin/bash

set -x

AUTO_GIT_PULL=1

SHELL_DIR=$(cd "$(dirname "$0")"; pwd)
PLUGINX_DIR=$(cd "$(dirname "$0")/../"; pwd)
PROJECT_DIR=
PROJECT_PLUGIN_DIR=
PLUGIN_LIST=

# 1. copy pluginx to project
# 2. setup environments variables
setup()
{
  if [ ${AUTO_GIT_PULL} -eq 1 ]; 
  then 
    pushd $PLUGINX_DIR 
    git pull origin master
    popd
  fi

  # remove old plugin files and copy new files
  rm -rf "${PROJECT_PLUGIN_DIR}"    
  mkdir -p ${PROJECT_PLUGIN_DIR}
  cp -rf ${PLUGINX_DIR}/* ${PROJECT_PLUGIN_DIR}
}


install_sdk()
{
  pushd ${PROJECT_PLUGIN_DIR}/tools

  ./publish.sh $PLUGIN_LIST

  if [ $? -ne 0 ]; then 
    echo "Error occurs, please have a check your plugin configuration and try again!"
    exit 1
  fi

  plugin_arr=(${PLUGIN_LIST//:/ })
  plugin_with_prefix_arr=()
  for i in $(seq 1 ${#plugin_arr[@]})
  do 
    index=$(($i - 1))
    plugin_with_prefix_arr[$index]="plugins/${plugin_arr[$index]}"
  done

  plugin_with_prefix=${plugin_with_prefix_arr[@]}
  ./toolsForGame/addPluginForAndroid" ${PROJECT_DIR}/proj.android" ${plugin_with_prefix// /:}

  project_ios_dir=
  if [ -d "${PROJECT_DIR}/proj.ios"  ]; then 
    project_ios_dir=${PROJECT_DIR}/proj.ios
  elif [ -d "${PROJECT_DIR}/proj.ios_mac" ]; then
    project_ios_dir=${PROJECT_DIR}/proj.ios_mac
  fi

  if [ -n "$project_ios_dir" ]; then
    ./toolsForGame/addPluginForIOS.sh ${project_ios_dir} ${plugin_with_prefix// /:}
  else 
    echo "Error: There is no ios project!!!"
  fi

  popd
}


help()
{
cat << EOF
usage: $0 -a action [options]

OPTIONS:
   -h      Show help message
   -a      action name. [setup |install_sdk]
   -l      list all plugins
   -s      sdk names. such as admob:googleanalytics:flurry
   -p      project path
   -v      Verbose
EOF

}



action=""
while getopts "ha:ls:vp:" OPTION
do 
  case $OPTION in 
    h)
      help
      exit 0
      ;;
    l) 
      echo "Plugin List:"
      ;;
    s)
      PLUGIN_LIST=${OPTARG}
      ;;
    a)
      action=$OPTARG
      ;;
    p)
      PROJECT_DIR=${OPTARG%/}
      PROJECT_PLUGIN_DIR="${PROJECT_DIR}/cocos2d/plugin"
      ;;
    ?)
      help 
      exit 1
      ;;
  esac
done


if [ ${action} = "setup" -a -n "${PROJECT_DIR}" ]; then 
  setup
elif [ "${action}" = "install_sdk" -a -n "${PLUGIN_LIST}" -a -n "${PROJECT_DIR}" ]; then
  install_sdk
else
  help
fi
