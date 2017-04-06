SELECT span, SUM(topics) as active_topics, SUM(messages) as total_messages
FROM (
	SELECT CONCAT(YEAR(m.created_at), '-', MONTH(m.created_at)) AS span, COUNT(DISTINCT t.id) as topics, COUNT(m.id) AS messages
	FROM forum f JOIN topic t ON f.id = t.forum_id JOIN message m ON t.id = m.topic_id
	WHERE f.type = 'eclipse_forum'
	GROUP BY YEAR(m.created_at), MONTH(m.created_at)
	UNION ALL
	SELECT CONCAT(YEAR(m.created_at), '-', MONTH(m.created_at)) AS span, COUNT(DISTINCT t.id) as topics, COUNT(m.id) AS messages
	FROM forum f JOIN topic t ON f.id = t.forum_id JOIN message m ON t.id = m.topic_id
	WHERE f.type = 'stackoverflow'
	GROUP BY YEAR(m.created_at), MONTH(m.created_at)) AS messages
GROUP BY span;