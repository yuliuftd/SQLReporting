/*
	Breakdown by number of events and participants
*/

SELECT
	CASE 
		WHEN e.socoro_eventcategory = 2 THEN 'Training and education'
		WHEN e.socoro_eventcategory = 10 THEN 'Industry networking'
		WHEN e.socoro_eventcategory = 9 THEN 'Workshop'
	END AS 'Events Type',
	e.cr67a_eventname AS 'Event Name',
	e.socoro_numberofregistrations AS 'Number of Participants',
	CASE 
		WHEN a.name IS NOT NULL THEN a.name
		ELSE er.cr67a_companyname
	END AS 'Attendees (Account Name)',
	CASE 
		WHEN c.fullname IS NOT NULL THEN c.fullname
		ELSE er.cr67a_firstname + ' ' + er.cr67a_lastname
	END AS 'Contact',
	e.cr67a_venue AS 'Event Venue',
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
AND (e.socoro_eventcategory = 2 OR e.socoro_eventcategory = 10 OR e.socoro_eventcategory = 9)
ORDER BY e.socoro_eventcategory ASC, e.createdon DESC;