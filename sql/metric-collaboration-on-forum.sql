/* nodes */
SELECT author_id as id, u.name as label, COUNT(DISTINCT m.id) AS size
FROM message m JOIN user u on m.author_id = u.id JOIN topic t ON t.id = m.topic_id 
JOIN forum f ON f.id = t.forum_id 
WHERE f.type = 'eclipse_forum' 
GROUP BY author_id;

/* edges */
SELECT source, target, COUNT(*) AS weight
FROM ( 
	SELECT m1.topic_id, m1.author_id AS source, m2.author_id AS target, CONCAT(m1.author_id, '-', m2.author_id) AS pair 
	from message m1 JOIN message m2 
	ON m1.id <> m2.id AND m1.topic_id = m2.topic_id AND m1.author_id <> m2.author_id AND m1.author_id > m2.author_id 
	JOIN topic t ON m1.topic_id = t.id JOIN forum f
	ON f.id = t.forum_id 
	WHERE f.type = 'eclipse_forum') AS forum_interaction 
GROUP BY pair;