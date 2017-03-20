###################################################################################################################
## Maturity metrics
## PROCESS
###################################################################################################################

use eclipse_projects_14022017;


SELECT p.name, p.project_uuid, m.name, pm.value, pm.text_value FROM
  sonar.metrics m, sonar.project_measures pm, sonar.projects p
WHERE m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ" AND p.name = "cdo.infrastructure.git master" AND m.name LIKE "%issue%";

SELECT
  SUBSTRING_INDEX(SUBSTRING_INDEX(sp.kee, ':', 1), '-', 1) as sonar_project_id,
  SUBSTRING_INDEX(SUBSTRING_INDEX(sp.kee, ':', 1), '-', -1) as sonar_repo_order,
  sp.name as sonar_repo_name,
  r.id as gitana_repo_id, r.name as gitana_repo_name,
  p.id as gitana_project_id, p.name as gitana_project_name
FROM
  (SELECT p.id as id, p.kee as kee, p.name as name FROM sonar.projects p WHERE p.scope = "PRJ") sp
LEFT JOIN
  project p
ON p.id = SUBSTRING_INDEX(SUBSTRING_INDEX(sp.kee, ':', 1), '-', 1)
LEFT JOIN
  repository r
ON r.name = SUBSTRING_INDEX(sp.name, ' ', 1);

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
      WHERE m.name = "lines" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") ls
    ON r.name = SUBSTRING_INDEX(ls.name, ' ', 1)
    LEFT JOIN
        (SELECT f.repo_id as repo_id, COUNT(DISTINCT f.ext) as num_extensions
        FROM file f
        GROUP BY f.repo_id) ne
    on r.id = ne.repo_id
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "class_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") cc
    ON r.name = SUBSTRING_INDEX(cc.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "function_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") fc
    ON r.name = SUBSTRING_INDEX(fc.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "file_complexity" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") ccc
    ON r.name = SUBSTRING_INDEX(ccc.name, ' ', 1);

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
      WHERE m.name = "code_smells" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") cs
    ON r.name = SUBSTRING_INDEX(cs.name, ' ', 1);

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
      WHERE m.name = "open_issues" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") oi
    ON r.name = SUBSTRING_INDEX(oi.name, ' ', 1);


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
      WHERE m.name = "comment_lines_density" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") cld
    ON r.name = SUBSTRING_INDEX(cld.name, ' ', 1)
    LEFT JOIN
      (SELECT p.name as name, pm.value as value
      FROM sonar.metrics m, sonar.project_measures pm, sonar.projects p
      WHERE m.name = "sqale_debt_ratio" AND m.id = pm.metric_id AND pm.component_uuid = p.uuid AND p.scope="PRJ") td
    ON r.name = SUBSTRING_INDEX(td.name, ' ', 1);

##########################################################
## Summary table
##########################################################

DROP TABLE metrics_product_project;
CREATE TABLE metrics_product_project(
  project_id int(20) PRIMARY KEY,
  anal_size INT(20),
  anal_num_extensions INT(20),
  anal_class_complexity FLOAT (10,4),
  anal_functions_complexity FLOAT (10,4),
  anal_file_complexity FLOAT (10,4),
  change_code_smells FLOAT (10,4),
  rel_open_issues FLOAT (10,4),
  reus_comment_lines_density FLOAT (10,4),
  reus_technical_debt FLOAT (10,4)
);
INSERT INTO metrics_product_project(project_id, anal_size, anal_num_extensions, anal_class_complexity, anal_functions_complexity, anal_file_complexity, change_code_smells, rel_open_issues, reus_comment_lines_density, reus_technical_debt)
    SELECT
      mq.project_id as project_id,
      AVG(mpa.anal_size),
      AVG(mpa.anal_num_extensions),
      AVG(mpa.anal_class_complexity),
      AVG(mpa.anal_functions_complexity),
      AVG(mpa.anal_file_complexity),
      AVG(mpc.change_code_smells),
      AVG(mpr.rel_open_issues),
      AVG(mpr2.reus_comment_lines_density),
      AVG(mpr2.reus_technical_debt)
    FROM
      (SELECT p.id as project_id, r.id as repo_id FROM repository r, project p WHERE r.project_id = p.id) mq
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
    GROUP BY mq.project_id;