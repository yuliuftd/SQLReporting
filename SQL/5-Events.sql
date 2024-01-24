/*
	Breakdown by number of events and participants
*/

SELECT
	'Number of industry networking events and the number of participants' AS Measurement,
	COUNT(DISTINCT(e.cr67a_eventid)) AS '# of events',
	SUM(e.socoro_numberofregistrations) AS '# of participants'
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--meeting or networking event
AND e.socoro_eventcategory = 10

UNION ALL

SELECT
	'Number of workshops and the number of participants',
	COUNT(DISTINCT(e.cr67a_eventid)),
	SUM(e.socoro_numberofregistrations)
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--class, training, or workshop
AND e.socoro_eventcategory = 9

UNION ALL

SELECT
	'Number of training and education events and the number of participants',
	COUNT(DISTINCT(e.cr67a_eventid)),
	SUM(e.socoro_numberofregistrations)
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--seminar or talk
AND e.socoro_eventcategory = 2;