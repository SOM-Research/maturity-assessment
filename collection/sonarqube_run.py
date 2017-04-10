__author__ = 'valerio cosentino'

import ConfigParser
import os
import subprocess

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)

HEADS_TO_NONEXISTENT_REF = ["106-1", "107-2", "111-1", "129-1", "132-1", "140-5",
                                "141-1", "143-1", "155-1", "167-1", "27-1", "29-1",
                                "34-1", "36-1", "4-1", "55-1", "57-1", "63-1", "65-1",
                                "67-1", "68-1", "70-1", "78-1", "84-1", "93-1", "42-1", "94-1", "94-2"]

TO_PROCESS = ["39-1"] 

def main():
    output_dir = configParser.get('params', 'directory')
    runner = configParser.get('params', 'runner')

    for e in os.listdir(output_dir):
        if e in TO_PROCESS:
        #if e not in HEADS_TO_NONEXISTENT_REF:
             os.chdir(output_dir + e)
             os.system(runner)

if __name__ == "__main__":
    main()
