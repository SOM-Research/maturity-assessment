__author__ = 'valerio cosentino'

import ConfigParser
import json
import os
import subprocess
import mysql.connector
from mysql.connector import errorcode

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)

CONFIG = {
            'user': 'vcosentino',
            'password': 'vcosentino',
            'host': 'localhost',
            'database': 'eclipse_projects_23032017',
            'port': '3306',
            'raise_on_warnings': False,
            'buffered': True
        }

HEADS_TO_NONEXISTENT_REF = ["106-1", "107-2", "111-1", "129-1", "132-1", "140-5", "94-1",
                            "94-2", "141-1", "143-1", "155-1", "167-1", "27-1", "29-1",
                            "34-1", "36-1", "4-1", "55-1", "57-1", "63-1", "65-1",
                            "67-1", "68-1", "70-1", "78-1", "84-1", "93-1", "42-1"]

def main():
    input_file = configParser.get('params', 'file')
    output_dir = configParser.get('params', 'directory')
    repos = []
    pos = 1
    cnx = mysql.connector.connect(**CONFIG)
    with open(input_file, "r") as input:
        for line in input:
            content = json.loads(line)
            project_name = content.keys()[0]
            info_repos = content.get(project_name)

            pos_repo = 1
            for repo_name in info_repos:
                repo_id = ''.join([str(pos), '-', str(pos_repo)])
                repo_path = output_dir + repo_id

                if repo_id not in HEADS_TO_NONEXISTENT_REF:
                    if os.path.exists(repo_path):
                        if os.listdir(repo_path):
                            cursor = cnx.cursor()
                            query = "SELECT COUNT(*) AS commits " \
                                    "FROM repository r JOIN commit c " \
                                    "ON r.id = c.repo_id " \
                                    "WHERE SUBSTRING_INDEX(r.name, '--', -1) = %s AND c.author_id IS NOT NULL AND c.committer_id IS NOT NULL " \
                                    "AND c.authored_date IS NOT NULL AND c.committed_date IS NOT NULL"
                            arguments = [repo_id]
                            cursor.execute(query, arguments)
                            row = cursor.fetchone()
                            cursor.close()

                            total = 0
                            if row:
                                total = row[0]

                            print str(repo_name) + "," + str(repo_id) + "," + str(total)  + "," + str(subprocess.check_output('git --git-dir="' + repo_path + '"/.git rev-list --count "master"', shell=True))


                        else:
                            print str(repo_id) + " something went wrong!"
                    else:
                        print str(repo_id) + " not found!"

                pos_repo += 1

            pos += 1

    cnx.close()

if __name__ == "__main__":
    main()
