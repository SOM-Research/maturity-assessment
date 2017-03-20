###################################################################################################################
## Descriptives metrics
###################################################################################################################

use eclipse_projects_14022017;

DROP TABLE metrics_descriptives;
CREATE TABLE metrics_descriptives(
  repo_id int(20) PRIMARY KEY,
  num_commits INT(20),
  num_authors INT(20),
  num_committers INT(20),
  commit_size INT(20),
  num_files INT(20),
  commits_vs_num_files FLOAT (10,4)
);
INSERT INTO metrics_descriptives(repo_id, num_commits, num_authors, num_committers, commit_size, num_files, commits_vs_num_files)
    SELECT
      mq.repo_id,
      q1.num_commits,
      q1.num_authors,
      q1.num_committers,
      q1.commit_size,
      q2.num_files,
      q1.num_commits / q2.num_files
    FROM
      (SELECT r.id as repo_id FROM repository r) mq
      LEFT JOIN
      (
        SELECT c.repo_id, COUNT(DISTINCT c.sha) as num_commits, COUNT(DISTINCT c.author_id) num_authors, COUNT(DISTINCT c.committer_id) num_committers, AVG(c.size) as commit_size
        FROM commit c GROUP BY c.repo_id
      ) q1
      ON mq.repo_id = q1.repo_id
      LEFT JOIN
      (
        SELECT f.repo_id, COUNT(DISTINCT f.id) as num_files
        FROM file f GROUP BY f.repo_id
      ) q2
      ON mq.repo_id = q2.repo_id;

##########################################################
## Summary table
##########################################################

DROP TABLE metrics_descriptives_project;
CREATE TABLE metrics_descriptives_project(
  project_id int(20) PRIMARY KEY,
  num_commits INT(20),
  num_authors INT(20),
  num_committers INT(20),
  commit_size INT(20),
  num_files INT(20),
  commits_vs_num_files FLOAT (10,4)
);
INSERT INTO metrics_descriptives_project(project_id, num_commits, num_authors, num_committers, commit_size, num_files, commits_vs_num_files)
    SELECT
      mq.project_id,
      AVG(md.num_commits),
      AVG(md.num_authors),
      AVG(md.num_committers),
      AVG(md.commit_size),
      AVG(md.num_files),
      AVG(md.commits_vs_num_files)
    FROM
      (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id) mq
      LEFT JOIN
      metrics_descriptives md
      ON  mq.repo_id = md.repo_id
    GROUP BY mq.project_id;