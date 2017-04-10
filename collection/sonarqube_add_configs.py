__author__ = 'valerio cosentino'

import ConfigParser
import os
import json

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)

SONAR_PROPS = "sonar-project.properties"


def write_content(f, repo_id, repo_name, src_folders):
    f.write("# Required metadata" + "\n")
    f.write("sonar.projectKey=" + str(repo_id) + "\n")
    f.write("sonar.projectName=" + repo_name + "\n")
    #f.write("sonar.projectVersion=1.0" + "\n")
    f.write("sonar.branch=master" + "\n")
    f.write("\n")
    f.write("# Comma-separated paths to directories with sources (required)" + "\n")
    #f.write("sonar.sources=" + ','.join(src_folders) + "\n")
    f.write("sonar.sources=.")
    f.write("\n")
    f.write("sonar.sourceEncoding=UTF-8")
    f.write("\n")
    f.write("# Language" + "\n")
    #f.write("sonar.language=java" + "\n")
    f.write("\n")
    f.write("# Encoding of the source files" + "\n")
    f.write("sonar.sourceEncoding=UTF-8" + "\n")


def collect_src_folders(root_path):
    src_folders = []
    for root, dirs, files in os.walk(root_path):
        for name in dirs:
            if name.endswith('src'):
                src_folders.append(os.path.join(root, name).replace('\\', '/').replace(root_path + '/', ''))

    return src_folders


def main():
    input_file = configParser.get('params', 'file')
    output_dir = configParser.get('params', 'directory')

    project_pos = 1
    with open(input_file, "r") as input:

        for line in input:
            if line.startswith('#'):
                line = line[1:]

            content = json.loads(line)
            project_name = content.keys()[0]
            info_repos = content.get(project_name)

            repo_pos = 1

            for repo_name in info_repos.keys():
                info_repo = info_repos.get(repo_name)
                git_url = info_repo.get('git')

                if git_url != "not-found":
                    repo_path = output_dir + ''.join([str(project_pos), '-', str(repo_pos)])

                    if os.path.exists(repo_path):
                        src_folders = collect_src_folders(repo_path)

                        f = open(repo_path + "/" + SONAR_PROPS, "w")
                        write_content(f, ''.join([str(project_pos), '-', str(repo_pos)]), repo_name, src_folders)
                        f.close()
                    else:
                        print "repo path " + repo_path + " does not exist!"
                else:
                    print "git repo for " + repo_name + " not found!"

                repo_pos += 1

            project_pos += 1


if __name__ == "__main__":
    main()
