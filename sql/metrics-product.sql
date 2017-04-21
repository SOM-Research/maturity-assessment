###################################################################################################################
## Maturity metrics
## PRODUCT
###################################################################################################################

use eclipse_projects_master_23032017;

##########################################################
## Analysability
##########################################################

DROP TABLE metrics_product_anal;
CREATE TABLE metrics_product_anal(
  repo_id int(20) PRIMARY KEY,
  anal_size INT(20),
  anal_num_extensions INT(20),
  anal_class_complexity FLOAT (10,4),
  anal_functions_complexity FLOAT (10,4),
  anal_file_complexity FLOAT (10,4)
);

INSERT INTO metrics_product_anal(repo_id, anal_size, anal_num_extensions, anal_class_complexity, anal_functions_complexity, anal_file_complexity)
    SELECT
      r.id as repo_id,
      ls.value as size,
      ne.num_extensions as num_extensions,
      cc.value as class_complexity,
      fc.value as function_complexity,
      ccc.value as file_complexity
    FROM
      repository r
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "lines" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) ls
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(ls.name, ' ', 1)
    LEFT JOIN
        (SELECT f.repo_id as repo_id, COUNT(DISTINCT f.ext) as num_extensions
        FROM file f
        GROUP BY f.repo_id) ne
    on r.id = ne.repo_id
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "class_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) cc
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(cc.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "function_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) fc
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(fc.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "file_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) ccc
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(ccc.name, ' ', 1);

##########################################################
## Changeability
##########################################################

DROP TABLE metrics_product_change;
CREATE TABLE metrics_product_change(
  repo_id int(20) PRIMARY KEY,
  change_code_smells FLOAT (10,4)
);

INSERT INTO metrics_product_change(repo_id, change_code_smells)
    SELECT
      r.id as repo_id,
      cs.value as code_smells
    FROM
      repository r
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "code_smells" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) cs
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(cs.name, ' ', 1);

##########################################################
## Reliability
##########################################################

DROP TABLE metrics_product_rel;
CREATE TABLE metrics_product_rel(
  repo_id int(20) PRIMARY KEY,
  rel_open_issues FLOAT (10,4)
);

INSERT INTO metrics_product_rel(repo_id, rel_open_issues)
    SELECT
      r.id as repo_id,
      oi.value as open_issues
    FROM
      repository r
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "open_issues" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) oi
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(oi.name, ' ', 1);


##########################################################
## Reusability
##########################################################


DROP TABLE metrics_product_reus;
CREATE TABLE metrics_product_reus(
  repo_id int(20) PRIMARY KEY,
  reus_comment_lines_density FLOAT (10,4),
  reus_technical_debt FLOAT (10,4)
);

INSERT INTO metrics_product_reus(repo_id, reus_comment_lines_density, reus_technical_debt)
    SELECT
      r.id as repo_id,
      cld.value as comment_lines_density,
      td.value as technical_debt
    FROM
      repository r
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "comment_lines_density" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) cld
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(cld.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "sqale_debt_ratio" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" GROUP BY p.name) td
    ON substring_index(r.name, '--', 1) = SUBSTRING_INDEX(td.name, ' ', 1);

##########################################################
## Summary table
##########################################################

DROP TABLE metrics_product_project;
CREATE TABLE metrics_product_project(
  project_id int(20) PRIMARY KEY,
  prod_lines_code INT(20),
  prod_num_extensions INT(20),
  prod_class_complexity FLOAT (10,4),
  prod_functions_complexity FLOAT (10,4),
  prod_file_complexity FLOAT (10,4),
  prod_code_smells FLOAT (10,4),
  prod_open_issues FLOAT (10,4),
  prod_comment_density FLOAT (10,4),
  prod_technical_debt FLOAT (10,4)
);
INSERT INTO metrics_product_project(project_id, prod_lines_code, prod_num_extensions, prod_class_complexity, prod_functions_complexity, prod_file_complexity, prod_code_smells, prod_open_issues, prod_comment_density, prod_technical_debt)
    SELECT
      mq.project_id as project_id,
      SUM(mpa.anal_size),
      AVG(mpa.anal_num_extensions),
      AVG(mpa.anal_class_complexity),
      AVG(mpa.anal_functions_complexity),
      AVG(mpa.anal_file_complexity),
      AVG(mpc.change_code_smells),
      AVG(mpr.rel_open_issues),
      AVG(mpr2.reus_comment_lines_density),
      AVG(mpr2.reus_technical_debt)
    FROM
      (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id
       AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
        "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
        "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
        "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
        "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
      ) mq
      LEFT JOIN
      metrics_product_anal mpa
      ON mq.repo_id = mpa.repo_id
      LEFT JOIN
      metrics_product_change mpc
      ON mq.repo_id = mpc.repo_id
      LEFT JOIN
      metrics_product_rel mpr
      ON mq.repo_id = mpr.repo_id
      LEFT JOIN
      metrics_product_reus mpr2
      ON mq.repo_id = mpr2.repo_id
#       LEFT JOIN
#       metrics_ecosystem_act mea
#       ON mq.repo_id = mea.repo_id
#     WHERE mea.act_ratio_commits_last_year > 0.10
    GROUP BY mq.project_id;