__author__ = 'valerio cosentino'

import ConfigParser
import os
import multiprocessing
from util import multiprocessing_util
from clone_repo import CloneRepo

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)
PROCESSES = 3


def create_folder(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def main():
    input_file = configParser.get('params', 'file')
    output_dir = configParser.get('params', 'directory')

    create_folder(output_dir)
    cloning_log_path = "cloning-log/"

    create_folder(cloning_log_path)
    pos = 1
    with open(input_file, "r") as input:
        queue_projects = multiprocessing.JoinableQueue()
        results = multiprocessing.Queue()
        multiprocessing_util.start_consumers(PROCESSES, queue_projects, results)

        for line in input:
            if not line.startswith('#'):
                process_project = CloneRepo(output_dir, line, pos, cloning_log_path)
                queue_projects.put(process_project)

            pos += 1

    # Add end-of-queue markers
    multiprocessing_util.add_poison_pills(PROCESSES, queue_projects)

    # Wait for all of the tasks to finish
    queue_projects.join()

if __name__ == "__main__":
    main()