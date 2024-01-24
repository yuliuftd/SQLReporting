/*
	4.1 Corporate engagements and networking events
*/

SELECT
	'Number of corporate engagements and networking events' AS Measurement,
	COUNT(DISTINCT(e.cr67a_eventid)) AS Result
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--meeting or networking event
AND e.socoro_eventcategory = 10;



SELECT
	ROW_NUMBER() OVER (ORDER BY e.cr67a_startdate) AS '#',
	e.cr67a_eventname AS 'Event',
	e.socoro_numberofregistrations AS '# attendees',
	e.cr67a_venue AS 'Location',
	e.socoro_eventcategoryname AS 'Category',
	FORMAT(e.cr67a_startdate, 'dd MMM yyyy') AS 'Date'
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--meeting or networking event
AND e.socoro_eventcategory = 10
ORDER BY e.cr67a_startdate;



/*
	4.1 Workshops
*/

SELECT
	ROW_NUMBER() OVER (ORDER BY e.cr67a_startdate) AS '#',
	e.cr67a_eventname AS 'Event',
	e.socoro_numberofregistrations AS '# attendees',
	e.cr67a_venue AS 'Location',
	e.socoro_eventcategoryname AS 'Category',
	FORMAT(e.cr67a_startdate, 'dd MMM yyyy') AS 'Date'
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--class, training, or workshop
AND e.socoro_eventcategory = 9
ORDER BY e.cr67a_startdate;



/*
	4.1 Business training and education
*/

SELECT
	ROW_NUMBER() OVER (ORDER BY e.cr67a_startdate) AS '#',
	e.cr67a_eventname AS 'Event',
	e.socoro_numberofregistrations AS '# attendees',
	e.cr67a_venue AS 'Location',
	e.socoro_eventcategoryname AS 'Category',
	FORMAT(e.cr67a_startdate, 'dd MMM yyyy') AS 'Date'
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--seminar or talk
AND e.socoro_eventcategory = 2
ORDER BY e.cr67a_startdate;


/*
	4.2 Employment events
*/

SELECT
	ROW_NUMBER() OVER (ORDER BY e.cr67a_startdate) AS '#',
	e.cr67a_eventname AS 'Event',
	e.socoro_numberofregistrations AS '# attendees',
	e.cr67a_venue AS 'Location',
	e.socoro_eventcategoryname AS 'Category',
	FORMAT(e.cr67a_startdate, 'dd MMM yyyy') AS 'Date'
FROM dbo.cr67a_event e
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--employment event (i.e. other)
AND e.socoro_eventcategory = 100
ORDER BY e.cr67a_startdate;