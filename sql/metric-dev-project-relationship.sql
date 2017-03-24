/* 
dev-project relationship 
*/
select prj_dev_rel.*, pt1.mde as x_mde, pt1.incubation as x_incubation, pt2.mde as y_mde, pt2.incubation as y_incubation
from (
	select prj_dev_x.project_id as x_project_id, prj_dev_y.project_id as y_project_id, 
	prj_dev_x.name as x_name, prj_dev_y.name as y_name,
	CONCAT(prj_dev_x.project_id, '-', prj_dev_y.project_id) as link, 
	prj_dev_x.author_id as dev_id
	from (
	select p.id as project_id, p.name, c.author_id
	from project p join repository r on p.id = r.project_id
	join commit c on c.repo_id = r.id
	group by p.id, c.author_id) as prj_dev_x
	join
	(select p.id as project_id, p.name, c.author_id
	from project p join repository r on p.id = r.project_id
	join commit c on c.repo_id = r.id
	group by p.id, c.author_id) as prj_dev_y
	on prj_dev_x.author_id = prj_dev_y.author_id and prj_dev_x.project_id <> prj_dev_y.project_id
	where prj_dev_x.project_id > prj_dev_y.project_id
	group by link, prj_dev_x.author_id) as prj_dev_rel
join project_type pt1 on prj_dev_rel.x_project_id = pt1.project_id
join project_type pt2 on prj_dev_rel.y_project_id = pt2.project_id;