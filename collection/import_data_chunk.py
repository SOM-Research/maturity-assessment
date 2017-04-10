__author__ = 'valerio cosentino'

import json
from gitana.gitana import Gitana
import os
import logging


class ImportProject(object):

    HEADS_TO_NONEXISTENT_REF = ["106-1", "107-2", "111-1", "129-1", "132-1", "140-5",
                                "141-1", "143-1", "155-1", "167-1", "27-1", "29-1",
                                "34-1", "36-1", "4-1", "55-1", "57-1", "63-1", "65-1",
                                "67-1", "68-1", "70-1", "78-1", "84-1", "93-1", "42-1", "94-1", "94-2"]

    # CHECKOUT_FAILED = ["19-41", "19-4", "139-1", "39-1", "19-36", "19-43", "113-9", "121-1", "119-1", "19-16", "142-1",
    #                    "19-50", "19-48", "30-1", "19-22", "140-10", "19-15", "19-12", "19-20", "134-1", "19-39", "113-5",
    #                    "113-2", "19-14", "19-49", "48-1", "19-37", "113-10", "19-8", "19-34", "19-5", "19-38", "51-1",
    #                    "152-1", "19-17", "19-27", "19-44", "59-1", "19-2", "19-7", "159-7", "19-31", "52-1", "158-1",
    #                    "147-1", "19-1", "19-40", "19-3", "19-21", "19-19", "19-28", "113-3", "19-23"]

    def __init__(self, config, gitana_db, output_dir, output_log, project, pos):
        self.config = config
        self.gitana_db = gitana_db
        self.output_dir = output_dir
        self.output_log = output_log
        self.project = project
        self.pos = pos
        self.logger = None
        self.file_handler = None

    def get_file_handler(self, logger, log_filename):
        fileHandler = logging.FileHandler(log_filename + ".log", mode='w')
        formatter = logging.Formatter("%(asctime)s:%(levelname)s:%(message)s", "%Y-%m-%d %H:%M:%S")
        fileHandler.setFormatter(formatter)
        logger.setLevel(logging.INFO)
        logger.addHandler(fileHandler)

        return fileHandler

    def __call__(self):
        log_path = self.output_log + str(os.getpid()) + "-project-" + str(self.pos)
        self.logger = logging.getLogger(log_path)
        self.fileHandler = self.get_file_handler(self.logger, log_path)

        self.gitana = Gitana(self.config, None)
        content = json.loads(self.project)
        project_name = content.keys()[0]

        self.logger.info(project_name + " started")
        self.gitana.create_project(self.gitana_db, project_name + "--" + str(self.pos))
        info_repos = content.get(project_name)

        pos_repo = 1
        for repo_name in info_repos.keys():
            repo_id = ''.join([str(self.pos), '-', str(pos_repo)])
            repo_path = self.output_dir + repo_id

            if repo_id not in ImportProject.HEADS_TO_NONEXISTENT_REF:
                if os.path.exists(repo_path):
                    if os.listdir(repo_path):
                        self.logger.info("start importing git data " + repo_name + " (" + repo_id + ")")
                        #self.gitana.import_git_data(self.gitana_db, project_name + "--" + str(self.pos), repo_name + "--" + str(repo_id), repo_path, None, 1, ["origin/master"], 20)
                        self.gitana.update_git_data(self.gitana_db, project_name + "--" + str(self.pos), repo_name + "--" + str(repo_id), repo_path, None, 20)
                        self.logger.info("finish importing git data " + repo_name + " (" + repo_id + ")")
                    else:
                        self.logger.info("directory " + repo_path + " is empty")
                else:
                    self.logger.info("repo path for " + repo_name + " (" + repo_id + ") not found!")
            else:
                self.logger.info("repo name " + repo_name + " (" + repo_id + ") filtered!")

            pos_repo += 1

        self.logger.info(project_name + " finished")
        self.logger.removeHandler(self.fileHandler)
