__author__ = 'valerio cosentino'

from gitana.gitana import Gitana
import ConfigParser
import os
import multiprocessing
from util import multiprocessing_util
from import_data_chunk import ImportProject

CONFIG = {
            'user': 'vcosentino',
            'password': 'vcosentino',
            'host': '127.0.0.1',
            'port': '3306',
            'raise_on_warnings': False,
            'buffered': True
        }

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)

INIT_DB = False
ACTIVATE_COUNTER = False
PROCESSES = 1


def create_folder(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def main():
    input_file = configParser.get('params', 'file')
    gitana_db = configParser.get('params', 'gitana-db')
    output_dir = configParser.get('params', 'directory')
    output_log = configParser.get('params', 'log')

    create_folder(output_dir)
    create_folder(output_log)
    gitana = Gitana(CONFIG, None)

    if INIT_DB:
        gitana.init_db(gitana_db)

    queue_projects = multiprocessing.JoinableQueue()
    results = multiprocessing.Queue()

    # Start consumers
    multiprocessing_util.start_consumers(PROCESSES, queue_projects, results)

    pos = 1
    with open(input_file, "r") as input:

        for line in input:
            if not line.startswith("#"):
                process_project = ImportProject(CONFIG, gitana_db, output_dir, output_log, line, pos)
                queue_projects.put(process_project)

            pos += 1

    # Add end-of-queue markers
    multiprocessing_util.add_poison_pills(PROCESSES, queue_projects)

    # Wait for all of the tasks to finish
    queue_projects.join()


if __name__ == "__main__":
    main()