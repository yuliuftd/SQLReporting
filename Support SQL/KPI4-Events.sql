/*
	4.1 Corporate engagements and networking events
*/

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname AS 'Event Type',
	e.cr67a_venue AS 'Event Venue',
	CASE 
		WHEN a.name IS NOT NULL THEN a.name
		ELSE er.cr67a_companyname
	END AS 'Attendees (Account Name)',
	CASE 
		WHEN c.fullname IS NOT NULL THEN c.fullname
		ELSE er.cr67a_firstname + ' ' + er.cr67a_lastname
	END AS 'Contact',
	FORMAT(e.createdon, 'yyyy-MM-dd') AS 'Created On',
	FORMAT(e.cr67a_startdate, 'yyyy-MM-dd') AS 'Started Date',
	FORMAT(e.cr67a_enddate, 'yyyy-MM-dd') AS 'End Date'
FROM dbo.cr67a_event e
LEFT JOIN dbo.cr67a_eventregistration er ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN dbo.account a ON er.cr67a_account = a.accountid
LEFT JOIN dbo.contact c ON c.parentcustomerid = a.accountid
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--meeting or networking event
AND e.socoro_eventcategory = 10
--attendees greater than 0
AND e.socoro_numberofregistrations > 0
ORDER BY e.cr67a_startdate;

/*
	4.1 Workshops
*/

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname AS 'Event Type',
	e.cr67a_venue AS 'Event Venue',
	CASE 
		WHEN a.name IS NOT NULL THEN a.name
		ELSE er.cr67a_companyname
	END AS 'Attendees (Account Name)',
	CASE 
		WHEN c.fullname IS NOT NULL THEN c.fullname
		ELSE er.cr67a_firstname + ' ' + er.cr67a_lastname
	END AS 'Contact',
	FORMAT(e.createdon, 'yyyy-MM-dd') AS 'Created On',
	FORMAT(e.cr67a_startdate, 'yyyy-MM-dd') AS 'Started Date',
	FORMAT(e.cr67a_enddate, 'yyyy-MM-dd') AS 'End Date'
FROM dbo.cr67a_event e
LEFT JOIN dbo.cr67a_eventregistration er ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN dbo.account a ON er.cr67a_account = a.accountid
LEFT JOIN dbo.contact c ON c.parentcustomerid = a.accountid
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--workshops
AND e.socoro_eventcategory = 9
--attendees greater than 0
AND e.socoro_numberofregistrations > 0
ORDER BY e.cr67a_startdate;



/*
	4.1 Business training and education
*/

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname AS 'Event Type',
	e.cr67a_venue AS 'Event Venue',
	CASE 
		WHEN a.name IS NOT NULL THEN a.name
		ELSE er.cr67a_companyname
	END AS 'Attendees (Account Name)',
	CASE 
		WHEN c.fullname IS NOT NULL THEN c.fullname
		ELSE er.cr67a_firstname + ' ' + er.cr67a_lastname
	END AS 'Contact',
	FORMAT(e.createdon, 'yyyy-MM-dd') AS 'Created On',
	FORMAT(e.cr67a_startdate, 'yyyy-MM-dd') AS 'Started Date',
	FORMAT(e.cr67a_enddate, 'yyyy-MM-dd') AS 'End Date'
FROM dbo.cr67a_event e
LEFT JOIN dbo.cr67a_eventregistration er ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN dbo.account a ON er.cr67a_account = a.accountid
LEFT JOIN dbo.contact c ON c.parentcustomerid = a.accountid
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--seminar or talk
AND e.socoro_eventcategory = 2
--attendees greater than 0
AND e.socoro_numberofregistrations > 0
ORDER BY e.cr67a_startdate;

/*
	4.2 Employment events
*/

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname AS 'Event Type',
	e.cr67a_venue AS 'Event Venue',
	CASE 
		WHEN a.name IS NOT NULL THEN a.name
		ELSE er.cr67a_companyname
	END AS 'Attendees (Account Name)',
	CASE 
		WHEN c.fullname IS NOT NULL THEN c.fullname
		ELSE er.cr67a_firstname + ' ' + er.cr67a_lastname
	END AS 'Contact',
	FORMAT(e.createdon, 'yyyy-MM-dd') AS 'Created On',
	FORMAT(e.cr67a_startdate, 'yyyy-MM-dd') AS 'Started Date',
	FORMAT(e.cr67a_enddate, 'yyyy-MM-dd') AS 'End Date'
FROM dbo.cr67a_event e
LEFT JOIN dbo.cr67a_eventregistration er ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN dbo.account a ON er.cr67a_account = a.accountid
LEFT JOIN dbo.contact c ON c.parentcustomerid = a.accountid
--started within reporting period
WHERE e.cr67a_startdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND e.cr67a_startdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--employment event (i.e. other)
AND e.socoro_eventcategory = 100
--attendees greater than 0
AND e.socoro_numberofregistrations > 0
ORDER BY e.cr67a_startdate;