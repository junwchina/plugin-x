#!/bin/bash 

set -x 

SHELL_DIR=$(cd "$(dirname "$0")"; pwd)

PLUGINX_DIR=$(cd "$(dirname "$0")/../../"; pwd)
GAME_PROJECT_DIR=$1
GAME_PROJECT_XCODEPROJ_DIR="${GAME_PROJECT_DIR}/$(ls ${GAME_PROJECT_DIR}|grep xcodeproj)"
GAME_PROJECT_PBXPROJ_FILE="${GAME_PROJECT_XCODEPROJ_DIR}/project.pbxproj"
SELECTED_PLUGINS=(${2//:/ })



pushd ${SHELL_DIR}/../

SELECTED_PLUGINS[$#@SELECTED_PLUGINS[@]}]="protocols"


for plugin_name in ${SELECTED_PLUGINS[@]}
do
  plugin_path="${PLUGINX_DIR}/${plugin_name}"

  # find .xcodeproj file
  plugin_xcodeproj="${plugin_path}/proj.ios/$(ls ${plugin_path}/proj.ios/ | grep xcodeproj)"
  plugin_header_paths="${plugin_path}/include"


  ./xcodemodifier/xcodemod --addsubp --subpath ${plugin_xcodeproj} --header_paths ${plugin_header_paths}  --pbxproj ${GAME_PROJECT_PBXPROJ_FILE}
done


popd
