###################################################################################################################
## Descriptives metrics
###################################################################################################################

use eclipse_projects_master_23032017;

# To calculate main distributions
SELECT COUNT(DISTINCT mq.repo_id)
FROM
  (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
    AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
  ) mq
  LEFT JOIN project_type pt
  ON mq.project_id = pt.project_id
WHERE
  pt.mde = 1;


SELECT COUNT(DISTINCT c.sha)
FROM
  (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
    AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
  ) mq,
  commit c
WHERE
  (mq.repo_id = c.repo_id);

SELECT COUNT(DISTINCT f.id)
FROM
  (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
    AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
  ) mq,
  file f
WHERE
  mq.repo_id = f.repo_id;

SELECT COUNT(DISTINCT u.id)
FROM
  (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
    AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
  ) mq,
  commit c, user u
WHERE
  mq.repo_id = c.repo_id AND c.author_id = u.id);

# Main table
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
  num_contributors INT(20),
  commit_size INT(20),
  num_files INT(20)
);
INSERT INTO metrics_descriptives_project(project_id, num_commits, num_contributors, commit_size, num_files)
    SELECT
      rq.project_id,
      rq.num_commits,
      rq.num_committers,
      rq.commit_size,
      lq.num_files
    FROM
      (
        SELECT
          mq.project_id,
          AVG(md.num_files) as num_files
        FROM
        (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
         AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
          "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
          "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
          "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
          "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
        ) mq
        LEFT JOIN
        metrics_descriptives md
        ON  mq.repo_id = md.repo_id
        GROUP BY mq.project_id
      ) lq,
      (
        SELECT
          p.id as project_id,
          AVG(c.size) as commit_size,
          COUNT(DISTINCT c.sha) as num_commits,
          COUNT(DISTINCT c.author_id) as num_committers
        FROM
          commit c, repository r, project p
        WHERE
          c.repo_id = r.id AND r.project_id = p.id
          AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
            "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
            "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
            "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
            "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
        GROUP BY p.id
      ) rq
    WHERE lq.project_id = rq.project_id;