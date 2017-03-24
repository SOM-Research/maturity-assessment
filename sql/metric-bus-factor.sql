/* bus factor */
select project_id, count(*) as bus_factor
from (
select authorship.*, total_authored_files, round((authored_files/total_authored_files)*100, 2) as perc_authored
from (
	select project_id, author_id, count(distinct file_id) as authored_files
	from 
		(select p.id as project_id, c.author_id, file_id, fm.id, max(committed_date) as last_modification
		from project p join repository r on p.id = r.project_id
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
		from project p join repository r on p.id = r.project_id
		join commit c on c.repo_id = r.id
		join file_modification fm on fm.commit_id = c.id
		where YEAR(committed_date) >= 2016 and fm.status <> 'deletion' and fm.changes <> 0
		group by p.id, file_id
		order by committed_date) as last_mod
	group by project_id) as total
on total.project_id = authorship.project_id) as weight_authorship
where perc_authored >= 20
group by project_id;