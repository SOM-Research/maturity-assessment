###################################################################################################################
## Maturity metrics
## ECOSYSTEM
###################################################################################################################

use eclipse_projects_14022017;

select * from metrics_ecosystem_act_starting;

##########################################################
## Activity
##########################################################

DROP TABLE metrics_ecosystem_act;
CREATE TABLE metrics_ecosystem_act(
  repo_id int(20) PRIMARY KEY,
  act_avg_commits_developer FLOAT(10,4),
  act_avg_size_commit_developer FLOAT (10,4),
  act_avg_num_commits_month FLOAT (10,4),
  act_num_developers INT(20)
);
INSERT INTO metrics_ecosystem_act(repo_id, act_avg_commits_developer, act_avg_size_commit_developer, act_avg_num_commits_month, act_num_developers)
    SELECT
      mq.repo_id,
      q1.avg_commits_developer,
      q2.avg_size_commit_developer,
      q3.avg_num_commits_month,
      q4.num_developers
    FROM
    (SELECT r.id as repo_id FROM repository r) mq
    LEFT JOIN
    (SELECT cs.repo_id, AVG(cs.num_commits) as avg_commits_developer
    FROM
      (SELECT r.id as repo_id, c.author_id as commit_author, COUNT(c.sha) as num_commits
      FROM commit c, repository r
      WHERE c.repo_id = r.id
      GROUP BY r.id, c.author_id) cs
    GROUP BY cs.repo_id) q1
    ON mq.repo_id = q1.repo_id
    LEFT JOIN
    (SELECT cs.repo_id, AVG(cs.avg_size_dev) as avg_size_commit_developer
    FROM
      (SELECT r.id as repo_id, c.author_id as commit_author, AVG(c.size) as avg_size_dev
      FROM commit c, repository r
      WHERE c.repo_id = r.id
      GROUP BY r.id, c.author_id) cs
    GROUP BY cs.repo_id) q2
    ON mq.repo_id = q2.repo_id
    LEFT JOIN
    (SELECT cs.repo_id, AVG(cs.num_commits) as avg_num_commits_month
    FROM
      (SELECT r.id as repo_id, MONTH(c.committed_date) as month, YEAR(c.committed_date) as year, COUNT(c.sha) as num_commits
      FROM commit c, repository r
      WHERE c.repo_id = r.id
      GROUP BY r.id, MONTH(c.committed_date), YEAR(c.committed_date)) cs
    GROUP BY cs.repo_id) q3
    ON mq.repo_id = q3.repo_id
    LEFT JOIN
    (SELECT c.repo_id, COUNT(DISTINCT c.author_id) as num_developers
    FROM
      commit c
    GROUP BY c.repo_id) q4
    ON mq.repo_id = q4.repo_id;


##########################################################
## Diversity
##########################################################

SELECT top_info.repo_id, top_info.num_top_commits/gen_info.num_commits as ratio_top_commits_from_committers
    FROM
      (
        SELECT
          q.repo_id as repo_id, SUM(q.num_commits) as num_top_commits
        FROM
          (
          SELECT
            /* We need to enumerate rows to be able to select the top @topn */
            sq.repo_id, sq.commit_author, sq.num_commits, @n := if(@t = repo_id, @n + 1, 1) as row_number, @t := repo_id as dummy
          FROM
            (SELECT c.repo_id as repo_id, c.author_id as commit_author, COUNT(c.sha) as num_commits
            FROM commit c
            GROUP BY c.repo_id, c.author_id
            ORDER BY c.repo_id ASC, num_commits DESC) sq
          ) q
        WHERE q.row_number <= @topn
        GROUP BY q.repo_id
      ) top_info,
      (
        SELECT
          c.repo_id, 0.25 * COUNT(DISTINCT c.sha) as commit_threshold
        FROM
          commit c
        GROUP BY c.repo_id;

;


DROP TABLE metrics_ecosystem_div;
CREATE TABLE metrics_ecosystem_div(
  repo_id int(20) PRIMARY KEY,
  div_ratio_outsiders FLOAT (10,4),
  div_ratio_eclipse_email FLOAT (10,4),
  div_ratio_commits_from_top_3_committers FLOAT (10,4),
  div_ratio_casuals FLOAT(10,4)
);
set @n := 0, @t := '', @topn = 3;
INSERT INTO metrics_ecosystem_div(repo_id, div_ratio_outsiders, div_ratio_eclipse_email, div_ratio_commits_from_top_3_committers, div_ratio_casuals)
    SELECT
      mq.repo_id,
      q52.ext_devs / q51.devs as ratio_outsiders,
      q6.eclipse_devs / q51.devs as ratio_eclipse_email,
      q7.ratio_top_commits_from_committers as ratio_top_commits_from_committers,
      q8.ratio_casuals as ratio_casuals
    FROM
    (SELECT r.id as repo_id FROM repository r) mq
    LEFT JOIN
    (SELECT t1.repo_id as repo_id, COUNT(DISTINCT t1.dev) as devs
    FROM
      (SELECT c.repo_id, c.committer_id as dev FROM commit c
       UNION
      SELECT c.repo_id, c.author_id as dev FROM commit c) t1
    GROUP BY t1.repo_id) q51
    ON mq.repo_id = q51.repo_id
    LEFT JOIN
    (SELECT c.repo_id, COUNT(DISTINCT c.author_id) as ext_devs
    FROM
      commit c
    WHERE c.committer_id <> c.author_id
    GROUP BY c.repo_id) q52
    ON mq.repo_id = q52.repo_id
    LEFT JOIN
    (SELECT c.repo_id, COUNT(DISTINCT c.author_id) as eclipse_devs
    FROM
      commit c, user u
    WHERE c.author_id = u.id AND u.email LIKE "%eclipse.org"
    GROUP BY c.repo_id) q6
    ON mq.repo_id = q6.repo_id
    LEFT JOIN
    (SELECT top_info.repo_id, top_info.num_top_commits/gen_info.num_commits as ratio_top_commits_from_committers
    FROM
      (
        SELECT
          q.repo_id as repo_id, SUM(q.num_commits) as num_top_commits
        FROM
          (
          SELECT
            /* We need to enumerate rows to be able to select the top @topn */
            sq.repo_id, sq.commit_author, sq.num_commits, @n := if(@t = repo_id, @n + 1, 1) as row_number, @t := repo_id as dummy
          FROM
            (SELECT c.repo_id as repo_id, c.author_id as commit_author, COUNT(c.sha) as num_commits
            FROM commit c
            GROUP BY c.repo_id, c.author_id
            ORDER BY c.repo_id ASC, num_commits DESC) sq
          ) q
        WHERE q.row_number <= @topn
        GROUP BY q.repo_id
      ) top_info,
      (
        SELECT
          c.repo_id, COUNT(DISTINCT c.sha) as num_commits
        FROM
          commit c
        GROUP BY c.repo_id
      ) gen_info
    WHERE top_info.repo_id = gen_info.repo_id) q7
    ON mq.repo_id = q7.repo_id
    LEFT JOIN
    (
    SELECT rs.repo_id, casuals.num_casuals/totals.num_totals as ratio_casuals
    FROM
      (SELECT r.id as repo_id FROM repository r) rs
      LEFT JOIN
      (
        SELECT
          commits.repo_id                       AS repo_id,
          COUNT(DISTINCT commits.commit_author) AS num_casuals
        FROM
          (SELECT
             c.repo_id    AS repo_id,
             c.author_id  AS commit_author,
             COUNT(c.sha) AS num_commits
           FROM commit c
           GROUP BY c.repo_id, c.author_id
           ORDER BY c.repo_id ASC, num_commits DESC) commits,
          (SELECT
             c.repo_id,
             0.05 * COUNT(DISTINCT c.sha) AS commit_threshold
           FROM commit c
           GROUP BY c.repo_id) threshold
        WHERE commits.repo_id = threshold.repo_id AND commits.num_commits <= threshold.commit_threshold
        GROUP BY commits.repo_id
      ) casuals
      ON rs.repo_id = casuals.repo_id
      LEFT JOIN
      (
        SELECT c.repo_id, COUNT(DISTINCT c.author_id) as num_totals FROM commit c GROUP BY c.repo_id
      ) totals
      ON rs.repo_id = totals.repo_id
    ) q8
    ON mq.repo_id = q8.repo_id;

##########################################################
## Support
##########################################################

DROP TABLE metrics_ecosystem_sup;
CREATE TABLE metrics_ecosystem_sup(
  repo_id int(20) PRIMARY KEY,
  sup_md_files FLOAT (10,4)
);

INSERT INTO metrics_ecosystem_sup(repo_id, sup_md_files)
    SELECT
      f.repo_id as repo_id, COUNT(DISTINCT f.id)
    FROM
      file f
    WHERE
      f.ext = "md"
    GROUP BY f.repo_id;


##########################################################
## Summary table
##########################################################

DROP TABLE metrics_ecosystem_project;
CREATE TABLE metrics_ecosystem_project(
  project_id int(20) PRIMARY KEY,
  act_avg_commits_developer FLOAT(10,4),
  act_avg_size_commit_developer FLOAT (10,4),
  act_avg_num_commits_month FLOAT (10,4),
  act_num_developers INT(20),
  div_ratio_outsiders FLOAT (10,4),
  div_ratio_eclipse_email FLOAT (10,4),
  div_ratio_commits_from_top_3_committers FLOAT (10,4),
  div_ratio_casuals FLOAT(10,4),
  sup_md_files INT(20)
);
INSERT INTO metrics_ecosystem_project(project_id, act_avg_commits_developer, act_avg_size_commit_developer, act_avg_num_commits_month, act_num_developers, div_ratio_outsiders, div_ratio_eclipse_email, div_ratio_commits_from_top_3_committers, div_ratio_casuals, sup_md_files)
    SELECT
      mq.project_id as project_id,
      AVG(mea.act_avg_commits_developer),
      AVG(mea.act_avg_size_commit_developer),
      AVG(mea.act_avg_num_commits_month),
      AVG(mea.act_num_developers),
      AVG(med.div_ratio_outsiders),
      AVG(med.div_ratio_eclipse_email),
      AVG(med.div_ratio_commits_from_top_3_committers),
      AVG(med.div_ratio_casuals),
      AVG(mes.sup_md_files)
    FROM
      (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id) mq
      LEFT JOIN
      metrics_ecosystem_act mea
      ON mq.repo_id = mea.repo_id
      LEFT JOIN
      metrics_ecosystem_div med
      ON mq.repo_id = med.repo_id
      LEFT JOIN
      metrics_ecosystem_sup mes
      ON mq.repo_id = mes.repo_id
    GROUP BY mq.project_id;

##########################################################
## Extra tables (for more precise analysis)
##########################################################

# activity first 12 months
DROP TABLE metrics_ecosystem_act_starting;
CREATE TABLE metrics_ecosystem_act_starting(
  project_id int(20),
  mde boolean,
  incubation boolean,
  repo_id int(20),
  year INT(20),
  month INT(20),
  row_number INT(20),
  num_commits INT(20),
  PRIMARY KEY (repo_id, year, month)
);
set @n := 0, @t := '', @topmonths = 12;
INSERT INTO metrics_ecosystem_act_starting(project_id, mde, incubation, repo_id, year, month, row_number, num_commits)
SELECT
  mq.project_id, mq.mde, mq.incubation, q1.repo_id, q1.year, q1.month, q1.row_number, q1.num_commits
FROM
  (SELECT p.id as project_id, pt.mde, pt.incubation, r.id as repo_id FROM repository r, project_type pt, project p WHERE r.project_id = p.id AND p.id = pt.project_id) mq
  JOIN
  (
        SELECT
          q.repo_id as repo_id, q.year, q.month, q.num_commits, q.row_number
        FROM
          (
          SELECT
            /* We need to enumerate rows to be able to select the top @topn */
            sq.repo_id, sq.year, sq.month, sq.num_commits, @n := if(@t = repo_id, @n + 1, 1) as row_number, @t := repo_id as dummy
          FROM
            (SELECT c.repo_id as repo_id, YEAR(c.authored_date) as year,  MONTH(c.committed_date) as month, COUNT(c.sha) as num_commits
            FROM commit c
            GROUP BY c.repo_id, YEAR(c.authored_date), MONTH(c.committed_date)
            ORDER BY c.repo_id ASC, YEAR(c.authored_date) ASC, MONTH(c.committed_date) ASC) sq
          ) q
        WHERE q.row_number <= @topmonths
  ) q1
  ON mq.repo_id = q1.repo_id;

# activity first 12 months CONSECUTIVE
DROP TABLE metrics_ecosystem_act_consecutive;
CREATE TABLE metrics_ecosystem_act_consecutive(
  project_id int(20),
  repo_id int(20),
  mde boolean,
  incubation boolean,
  month INT(20),
  num_commits INT(20),
  PRIMARY KEY (repo_id, month)
);
INSERT INTO metrics_ecosystem_act_consecutive(project_id, repo_id, mde, incubation, month, num_commits)
SELECT
  mq.project_id, aq.repo_id, mq.mde, mq.incubation, aq.month, aq.num_commits
FROM
  (SELECT p.id as project_id, pt.mde, pt.incubation, r.id as repo_id FROM repository r, project_type pt, project p WHERE r.project_id = p.id AND p.id = pt.project_id) mq
  RIGHT JOIN
  (SELECT
    q.month, qa.repo_id, qa.num_commits
  FROM
    ((SELECT 1 as month) UNION (SELECT 2 as month) UNION (SELECT 3 as month) UNION (SELECT 4 as month) UNION (SELECT 5 as month) UNION (SELECT 6 as month) UNION
     (SELECT 7 as month) UNION (SELECT 8 as month) UNION (SELECT 9 as month) UNION (SELECT 10 as month) UNION (SELECT 11 as month) UNION (SELECT 12 as month)) q
    LEFT JOIN
    (
      SELECT qmins.repo_id, qmins.min_year, qsums.month, qsums.num_commits
      FROM
        (SELECT c.repo_id, MIN(YEAR(c.committed_date)) as min_year FROM commit c GROUP BY c.repo_id) qmins
          LEFT JOIN
        (SELECT c.repo_id AS repo_id, YEAR(c.committed_date) as year, MONTH(c.committed_date) AS month, COUNT(c.sha) AS num_commits FROM commit c GROUP BY c.repo_id, YEAR(c.committed_date), MONTH(c.committed_date)) qsums
        ON qmins.repo_id = qsums.repo_id AND qmins.min_year = qsums.year
    ) qa
    ON qa.month = q.month) aq
  ON mq.repo_id = aq.repo_id;

# monthly activity
DROP TABLE metrics_ecosystem_act_monthly;
CREATE TABLE metrics_ecosystem_act_monthly(
  project_id int(20),
  repo_id int(20),
  mde boolean,
  incubation boolean,
  month INT(20),
  num_commits INT(20),
  PRIMARY KEY (repo_id, month)
);
INSERT INTO metrics_ecosystem_act_monthly(project_id, repo_id, mde, incubation, month, num_commits)
SELECT
  mq.project_id, sq.repo_id, mq.mde, mq.incubation, sq.month, sq.num_commits
FROM
  (SELECT p.id as project_id, pt.mde, pt.incubation, r.id as repo_id FROM repository r, project_type pt, project p WHERE r.project_id = p.id AND p.id = pt.project_id) mq
  JOIN
  (
    SELECT c.repo_id as repo_id, MONTH(c.committed_date) as month, COUNT(c.sha) as num_commits
      FROM commit c
      GROUP BY c.repo_id, MONTH(c.committed_date)
      ORDER BY c.repo_id ASC, MONTH(c.committed_date) ASC
  ) sq
  ON mq.repo_id = sq.repo_id
ORDER BY sq.repo_id ASC, sq.month ASC;