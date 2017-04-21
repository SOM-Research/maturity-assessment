###################################################################################################################
## Maturity metrics
## ECOSYSTEM
###################################################################################################################

use eclipse_projects_master_23032017;

##########################################################
## Activity
##########################################################

DROP TABLE metrics_ecosystem_act;
CREATE TABLE metrics_ecosystem_act(
  repo_id int(20) PRIMARY KEY,
  act_avg_commits_developer FLOAT(10,4),
  act_num_commits INT(20),
  act_num_committers INT(20),
  act_avg_size_commit_developer FLOAT (10,4),
  act_avg_num_commits_month FLOAT (10,4),
  act_num_developers INT(20),
  act_avg_commits_week FLOAT(10,4),
  act_avg_churn_week FLOAT(10,4),
  act_ratio_commits_last_year FLOAT(10,4),
  act_num_commits_last_year FLOAT(10,4)
);
INSERT INTO metrics_ecosystem_act(repo_id, act_avg_commits_developer, act_num_commits, act_num_committers, act_avg_size_commit_developer, act_avg_num_commits_month, act_num_developers, act_avg_commits_week, act_avg_churn_week,act_ratio_commits_last_year, act_num_commits_last_year)
    SELECT
      mq.repo_id,
      q1.avg_commits_developer,
      q9.num_commits,
      q9.num_committers,
      q2.avg_size_commit_developer,
      q3.avg_num_commits_month,
      q4.num_developers,
      q5.avg_num_commits,
      q6.avg_churn_size_week,
      q7.ratio_commits,
      q8.num_commits
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
    ON mq.repo_id = q4.repo_id
    LEFT JOIN
    (SELECT ymwq.repo_id as repo_id, AVG(ymwq.num_commits) as avg_num_commits
    FROM
      (
        SELECT
          c.repo_id,
          YEAR(c.committed_date),
          MONTH(c.committed_date),
          WEEK(c.committed_date),
          COUNT(c.sha) AS num_commits
        FROM commit c
        GROUP BY c.repo_id, YEAR(c.committed_date), MONTH(c.committed_date), WEEK(c.committed_date)
      ) ymwq
    GROUP BY ymwq.repo_id) q5
    ON mq.repo_id = q5.repo_id
    LEFT JOIN
    (SELECT
      mq.repo_id as repo_id, AVG(mq.dif) as avg_churn_size_week
    FROM
      (
      SELECT
        lq.repo_id, lq.row_number as lq_row_number, rq.row_number as rq_row_number, lq.size as lq_size, rq.size as rq_size, rq.size - lq.size as dif
      FROM
        (
        SELECT
          sq.repo_id, sq.year, sq.month, sq.week, sq.size, @n := if(@t = repo_id, @n + 1, 1) as row_number, @t := repo_id as dummy
        FROM
          (SELECT c.repo_id, YEAR(c.committed_date) as year, MONTH(c.committed_date) as month, WEEK(c.committed_date) as week, SUM(c.size) AS size
          FROM commit c
          GROUP BY c.repo_id, YEAR(c.committed_date), MONTH(c.committed_date), WEEK(c.committed_date)
          ORDER BY c.repo_id ASC, YEAR(c.committed_date) ASC, MONTH(c.committed_date) ASC, WEEK(c.committed_date) ASC) sq
        ) lq
        JOIN
        (
        SELECT
          sq.repo_id, sq.year, sq.month, sq.week, sq.size, @n := if(@t = repo_id, @n + 1, 1) as row_number, @t := repo_id as dummy
        FROM
          (SELECT c.repo_id, YEAR(c.committed_date) as year, MONTH(c.committed_date) as month, WEEK(c.committed_date) as week, SUM(c.size) AS size
          FROM commit c
          GROUP BY c.repo_id, YEAR(c.committed_date), MONTH(c.committed_date), WEEK(c.committed_date)
          ORDER BY c.repo_id ASC, YEAR(c.committed_date) ASC, MONTH(c.committed_date) ASC, WEEK(c.committed_date) ASC) sq
        ) rq
        ON lq.repo_id = rq.repo_id AND lq.row_number = rq.row_number - 1
      ) mq
    GROUP BY mq.repo_id) q6
    ON mq.repo_id = q6.repo_id
    LEFT JOIN
    (SELECT
      total.repo_id, max_year.year as last_year, min_year.year as first_year, max_year.year - min_year.year + 1 as lifespan, partial.partial_commits, total.total_commits, partial.partial_commits/total.total_commits as ratio_commits
    FROM
      (SELECT c.repo_id, COUNT(c.sha) as total_commits FROM commit c GROUP BY c.repo_id) total
      LEFT JOIN
      (SELECT c.repo_id, MAX(YEAR(c.committed_date)) as year FROM commit c GROUP BY c.repo_id) max_year
      ON total.repo_id = max_year.repo_id
      LEFT JOIN
      (SELECT c.repo_id, MIN(YEAR(c.committed_date)) as year FROM commit c GROUP BY c.repo_id) min_year
      ON total.repo_id = min_year.repo_id
      LEFT JOIN
      (SELECT
        last.repo_id, SUM(year_commits.partial_commits) as partial_commits
        FROM
          (SELECT c.repo_id, MAX(YEAR(c.committed_date)) as last_year FROM commit c GROUP BY c.repo_id) last
          LEFT JOIN
          (SELECT c.repo_id, YEAR(c.committed_date) as year, COUNT(c.sha) as partial_commits FROM commit c GROUP BY  c.repo_id, YEAR(c.committed_date)) year_commits
          ON last.repo_id = year_commits.repo_id AND year_commits.year >= last.last_year - 1
        GROUP BY last.repo_id) partial
      ON total.repo_id = partial.repo_id) q7
    ON mq.repo_id = q7.repo_id
    LEFT JOIN
    (SELECT c.repo_id, COUNT(c.sha) as num_commits FROM commit c WHERE YEAR(c.committed_date)=2016 GROUP BY c.repo_id) q8
    ON mq.repo_id = q8.repo_id
    LEFT JOIN
    (SELECT c.repo_id, COUNT(DISTINCT c.sha) as num_commits, COUNT(DISTINCT c.author_id) as num_committers FROM commit c GROUP BY c.repo_id) q9
    ON mq.repo_id = q9.repo_id;

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

select count(DISTINCT project_id) from metrics_ecosystem_project mep where mep.act_ratio_commits_last_year > 0.05 ;

DROP TABLE metrics_ecosystem_project;
CREATE TABLE metrics_ecosystem_project(
  project_id int(20) PRIMARY KEY,
  eco_avg_commits_developer FLOAT(10,4),
  eco_num_commits INT(20),
  eco_num_contributors INT(20),
  eco_avg_commits_month FLOAT (10,4),
  eco_avg_commits_week FLOAT(10,4),
  eco_avg_commits_last_year FLOAT(10,4),
  eco_ratio_outsiders FLOAT (10,4),
  eco_ratio_commits_top_committers FLOAT (10,4),
  eco_ratio_casuals FLOAT(10,4)
);
INSERT INTO metrics_ecosystem_project(project_id, eco_avg_commits_developer, eco_num_commits, eco_num_contributors, eco_avg_commits_month, eco_avg_commits_week, eco_avg_commits_last_year, eco_ratio_outsiders, eco_ratio_commits_top_committers, eco_ratio_casuals)
    SELECT
      lq.project_id,
      lq.act_avg_commits_developer,
      rq.act_num_commits,
      rq.act_num_committers,
      lq.act_avg_num_commits_month,
      lq.act_avg_commits_week,
      lq.act_num_commits_last_year,
      lq.div_ratio_outsiders,
      lq.div_ratio_commits_from_top_3_committers,
      lq.div_ratio_casuals
    FROM
      (
      SELECT
        mq.project_id as project_id,
        AVG(mea.act_avg_commits_developer) as act_avg_commits_developer,
        AVG(mea.act_avg_num_commits_month) as act_avg_num_commits_month,
        AVG(mea.act_avg_commits_week) as act_avg_commits_week,
        AVG(mea.act_num_commits_last_year) as act_num_commits_last_year,
        AVG(med.div_ratio_outsiders) as div_ratio_outsiders,
        AVG(med.div_ratio_commits_from_top_3_committers) as div_ratio_commits_from_top_3_committers,
        AVG(med.div_ratio_casuals) as div_ratio_casuals
      FROM
      (SELECT p.id AS project_id, r.id AS repo_id
       FROM repository r, project p
       WHERE r.project_id = p.id
             AND substring_index(r.name, '--', -1) NOT IN
                 ("18-1", "19-7", "19-19", "19-20", "19-23", "19-27", "19-47", "19-49", "23-1", "30-1",
                  "36-2", "39-1", "69-3", "92-2", "108-1", "113-10", "117-2", "117-12", "121-1", "130-1",
                  "131-1", "133-1", "140-3", "140-6", "140-9", "140-11", "140-13", "140-16", "145-1",
                  "148-1", "149-1", "149-2", "149-3", "149-4", "149-5", "149-6", "149-7", "149-8",
                  "149-9", "149-10", "149-11", "149-12", "149-13", "149-14", "149-15", "149-16", "159-11")
       ) mq
       LEFT JOIN
       metrics_ecosystem_act mea
       ON mq.repo_id = mea.repo_id
       LEFT JOIN
       metrics_ecosystem_div med
       ON mq.repo_id = med.repo_id
       LEFT JOIN
       metrics_ecosystem_sup mes
       ON mq.repo_id = mes.repo_id
       # WHERE mea.act_ratio_commits_last_year > 0.10
       GROUP BY mq.project_id
      ) lq,
      (
      SELECT
        p.id as project_id,
        COUNT(DISTINCT c.sha) as act_num_commits,
        COUNT(DISTINCT c.author_id) as act_num_committers
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