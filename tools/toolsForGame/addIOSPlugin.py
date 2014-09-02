#!/usr/bin/python


import sys
import os
import yaml

sys.path.insert(1, os.path.join(sys.path[0], '../xcodemodifier'))

from mod_pbxproj import XcodeProject


if __name__ == "__main__":
  plugin_xcodeproj = sys.argv[1]
  project_pbxproj = sys.argv[2]
  plugin_header_path = os.path.normpath(os.path.join(plugin_xcodeproj, "../../include"))
  config = os.path.normpath(os.path.join(plugin_xcodeproj, "../config.yaml"))

  project = XcodeProject.Load(project_pbxproj)

  if os.path.isfile(config):
    stream = open(config, "r")
    config_dict = yaml.load(stream)

    plugin_config = config_dict.get("production", {})
    project.add_subproject_as_dependency(plugin_xcodeproj,
                                         header_paths = [plugin_header_path],
                                         sdk_dependencies = plugin_config.get("sdk_dependencies", []),
                                         dev_dependencies = plugin_config.get("dev_dependencies", []))
  else:
    project.add_subproject_as_dependency(plugin_xcodeproj, header_paths = [plugin_header_path])

  project.save()
