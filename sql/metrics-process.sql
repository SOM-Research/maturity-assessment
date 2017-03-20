###################################################################################################################
## Maturity metrics
## PROCESS
###################################################################################################################

use eclipse_projects_14022017;

##########################################################
## Configuration management
##########################################################

DROP TABLE metrics_process_conf_manag;
CREATE TABLE metrics_process_conf_manag(
  repo_id int(20) PRIMARY KEY,
  conf_manag_commits INT(20),
  conf_manag_committers INT(20)
);

INSERT INTO metrics_process_conf_manag(repo_id, conf_manag_commits, conf_manag_committers)
    SELECT
      c.repo_id, COUNT(DISTINCT c.sha), COUNT(DISTINCT c.author_id)
    FROM
      commit c
    GROUP BY c.repo_id;

##########################################################
## Change Management
##########################################################

DROP TABLE metrics_process_change_manag;
CREATE TABLE metrics_process_change_manag(
  repo_id int(20) PRIMARY KEY,
  change_manag_governance INT(20)
);

INSERT INTO metrics_process_change_manag(repo_id, change_manag_governance)
    SELECT
      f.repo_id, COUNT(DISTINCT f.id)
    FROM
      file f
    WHERE
      f.ext = "md" AND (f.name LIKE "%governance%" OR f.name LIKE "%contribution")
    GROUP BY f.repo_id;

##########################################################
## Intellectual Property Management
##########################################################

DROP TABLE metrics_process_int;
CREATE TABLE metrics_process_int(
  repo_id int(20) PRIMARY KEY,
  int_license INT(20)
);

INSERT INTO metrics_process_int(repo_id, int_license)
    SELECT
      f.repo_id, COUNT(DISTINCT f.id)
    FROM
      file f
    WHERE
      f.ext = "md" AND (f.name LIKE "%license%")
    GROUP BY f.repo_id;


##########################################################
## Summary table
##########################################################

DROP TABLE metrics_process_project;
CREATE TABLE metrics_process_project(
  project_id int(20) PRIMARY KEY,
  conf_manag_commits INT(20),
  conf_manag_committers INT(20),
  change_manag_governance INT(20),
  int_license INT(20)
);
INSERT INTO metrics_process_project(project_id, conf_manag_commits, conf_manag_committers, change_manag_governance, int_license)
    SELECT
      mq.project_id as project_id,
      AVG(mpcm.conf_manag_commits),
      AVG(mpcm.conf_manag_committers),
      AVG(mpcm2.change_manag_governance),
      AVG(mpi.int_license)
    FROM
      (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id) mq
      LEFT JOIN
      metrics_process_conf_manag mpcm
      ON mq.repo_id = mpcm.repo_id
      LEFT JOIN
      metrics_process_change_manag mpcm2
      ON mq.repo_id = mpcm2.repo_id
      LEFT JOIN
      metrics_process_int mpi
      ON mq.repo_id = mpi.repo_id
    GROUP BY mq.project_id;