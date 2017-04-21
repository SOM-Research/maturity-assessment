###################################################################################################################
## Extensions to our model (use of forums)
###################################################################################################################

# Select the database where you want to apply this metric
#use papyrus_gitana;
use jdt_gitana;

DROP TABLE metrics_forum;
CREATE TABLE metrics_forum(
  year int(20),
	month int(20),
  active_topics INT(20),
	total_messages INT(20),
	ratio_messages_per_topic FLOAT(4,2),
	ratio_contributors_per_topic FLOAT(4,2),
	PRIMARY KEY (year,month)
);

INSERT metrics_forum(year, month, active_topics, total_messages, ratio_messages_per_topic, ratio_contributors_per_topic)
SELECT
	q1.year,
	q1.month,
	q1.active_topics,
	q1.total_messages,
	q1.ratio,
	q2.avg_contributors_per_topic
FROM
	(
	SELECT year, month, SUM(topics) as active_topics, SUM(messages) as total_messages, SUM(messages)/SUM(topics) as ratio
	FROM (
		SELECT CONCAT(YEAR(m.created_at), '-', MONTH(m.created_at)) AS span, YEAR(m.created_at) as year, MONTH(m.created_at) as month, COUNT(DISTINCT t.id) as topics, COUNT(m.id) AS messages
		FROM forum f JOIN topic t ON f.id = t.forum_id JOIN message m ON t.id = m.topic_id
		WHERE f.type = 'eclipse_forum'
		GROUP BY YEAR(m.created_at), MONTH(m.created_at)) AS messages
	GROUP BY year, month
	) as q1,
	(
	SELECT year, month, SUM(topics) as active_topics, SUM(messages) as total_messages, AVG(people) as avg_contributors_per_topic
	FROM (
		SELECT YEAR(m.created_at) as year, MONTH(m.created_at) as month, COUNT(DISTINCT t.id) as topics, COUNT(m.id) as messages, COUNT(m.author_id)+1 as people /* we add the author of the topic */
		FROM forum f JOIN topic t ON f.id = t.forum_id JOIN message m ON t.id = m.topic_id
		WHERE f.type = 'eclipse_forum'
		GROUP BY YEAR(m.created_at), MONTH(m.created_at), t.id) AS messages
	GROUP BY year, month
	) as q2
WHERE q1.year = q2.year and q1.month = q2.month;

SELECT *
FROM metrics_forum;