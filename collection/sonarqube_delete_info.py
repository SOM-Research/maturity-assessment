__author__ = 'valerio cosentino'

import ConfigParser
import os
import json
import shutil

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)

SONAR_FOLDER = ".sonar"


def main():
    output_dir = configParser.get('params', 'directory')

    for e in os.listdir(output_dir):
        sonar_info = output_dir + e + "/" + SONAR_FOLDER
        if os.path.exists(sonar_info):
            shutil.rmtree(sonar_info, ignore_errors=True)


if __name__ == "__main__":
    main()
