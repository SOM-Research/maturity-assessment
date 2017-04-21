###################################################################################################################
## Extensions to our model (bus factor)
###################################################################################################################

use eclipse_projects_master_23032017;

/* bus factor */
DROP TABLE metrics_bus_factor;
CREATE TABLE metrics_bus_factor(
  project_id int(20) PRIMARY KEY,
  bus_factor INT(20)
);

INSERT INTO metrics_bus_factor(project_id, bus_factor)
select project_id, count(*) as bus_factor
from (
select authorship.*, total_authored_files, round((authored_files/total_authored_files)*100, 2) as perc_authored
from (
	select project_id, author_id, count(distinct file_id) as authored_files
	from
		(select p.id as project_id, c.author_id, file_id, fm.id, max(committed_date) as last_modification
		from project p
		join repository r on p.id = r.project_id
       AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
		join commit c on c.repo_id = r.id
		join file_modification fm on fm.commit_id = c.id
		where YEAR(committed_date) >= 2016 and fm.status <> 'deletion' and fm.changes <> 0
		group by p.id, file_id
		order by committed_date) as last_mod
	group by project_id, author_id
	order by project_id, authored_files DESC) as authorship
join
	(
	select project_id, count(distinct file_id) as total_authored_files
	from
		(select p.id as project_id, c.author_id, file_id, fm.id, max(committed_date) as last_modification
		from project p
    join repository r on p.id = r.project_id
       AND substring_index(r.name, '--', -1) not in ("18-1","19-7", "19-19","19-20","19-23","19-27","19-47","19-49","23-1","30-1",
      "36-2","39-1","69-3","92-2","108-1","113-10","117-2","117-12","121-1","130-1",
      "131-1","133-1","140-3","140-6","140-9","140-11","140-13","140-16","145-1",
      "148-1","149-1","149-2","149-3","149-4","149-5","149-6","149-7","149-8",
      "149-9","149-10","149-11","149-12","149-13","149-14","149-15","149-16","159-11")
		join commit c on c.repo_id = r.id
		join file_modification fm on fm.commit_id = c.id
		where YEAR(committed_date) >= 2016 and fm.status <> 'deletion' and fm.changes <> 0
		group by p.id, file_id
		order by committed_date) as last_mod
	group by project_id) as total
on total.project_id = authorship.project_id) as weight_authorship
where perc_authored >= 20
group by project_id;
