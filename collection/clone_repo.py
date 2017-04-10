__author__ = 'valerio cosentino'
import json
import subprocess


class CloneRepo(object):

    def __init__(self, output_dir, project, pos, log_path):
        self.output_dir = output_dir
        self.project = project
        self.pos = pos
        self.log_path = log_path

    def __call__(self):
        content = json.loads(self.project)
        project_name = content.keys()[0]
        print project_name + " started"
        info_repos = content.get(project_name)

        pos_repo = 1
        for repo_name in info_repos.keys():
            info_repo = info_repos.get(repo_name)
            git_url = info_repo.get('git')

            if git_url != "not-found":
                repo_path = self.output_dir + ''.join([str(self.pos), '-', str(pos_repo)])
                print "cloning " + repo_name + " -- " + str(self.pos), '-', str(pos_repo)
                f = open(''.join([self.log_path, str(self.pos), '-', str(pos_repo), ".log"]), "w")
                subprocess.call("git clone " + git_url + " " + repo_path, stderr=f)
                f.write(project_name + "-" + repo_name + " finished")
                f.close()
            else:
                print "git repo for " + repo_name + " not found!"

            pos_repo += 1

        print project_name + " finished"