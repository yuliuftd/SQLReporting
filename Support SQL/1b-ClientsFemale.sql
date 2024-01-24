SELECT 
	s.socoro_name AS 'Shareholder ID',
	ISNULL(s.socoro_firstname, '') AS 'First Name',
	ISNULL(s.socoro_lastname, '') AS 'Last Name',
	CASE 
		WHEN a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'New'
		WHEN a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'Existing'
	END AS 'New/Existing',
	s.socoro_shareholdertypename AS 'Shareholder Type',
	s.socoro_gendername AS 'Gender',
	a.name as 'Account Name',
	FORMAT(a.createdon , 'yyyy-MM-dd') AS 'Created On'
FROM dbo.socoro_shareholder s
LEFT JOIN dbo.account a ON s.socoro_account = a.accountid
--created within reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--contact active
	AND s.statecode = 0
	--application (paid) not draft 
	AND a.cr67a_accountstatus <> 0
	--indigenous
	AND s.socoro_aboriginalstatus = 1
	--individual
	AND s.socoro_shareholdertype = 1
	--female
	AND s.socoro_gender = '2'
ORDER BY a.createdon DESC;


/*Breakdown by timeline*/

/*Number of businesses with a minimum of 50% female Indigenous ownership */
SELECT DISTINCT
	a.name as 'Account Name',
	c.fullname AS 'Contact',
	FORMAT(a.createdon, 'yyyy-MM-dd') AS 'Created On',
	a.socoro_indigenouslyfemaleownedname AS 'Minimun 50% Indigenously Female Owned'
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--minimum of 50% female Indigenous ownership
AND a.socoro_indigenouslyfemaleowned = 1
--registered with the Hub
AND (
--hub asset 
	(a3.relationshiptype = 3 AND a4.nonmembersubcategory =1)
	--services client
	OR (
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
		OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
	)
	--certified member
	OR (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))
	--event attendee
	OR (
		UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
	)
)
ORDER BY 'Created On' DESC;


SELECT
	hs.cr67a_hubserviceid AS 'Service Id',
	c.fullname AS 'Contact',
	a.name AS 'Account Name',
	hs.socoro_servicepackagename AS 'Service Package',
	hs.socoro_servicetypename AS 'Service Type',
	hs.socoro_modeofdeliveryname AS 'Delivery Mode',
	hs.socoro_locationofdeliveryname AS 'Delivery Location'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.account a ON hs.socoro_account = a.accountid
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.contact c ON o.parentcontactid = c.contactid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--service created within reporting period
WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
		--service created prior to reporting period, opportunity open
		OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0)
		)
--indigenous --female
AND ((s.socoro_aboriginalstatus = 1 AND s.socoro_gender = '2') OR (c.socoro_businessowner = 1 AND gendercode = '977380001' AND cr67a_ismemberaboriginal = 1))
--active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL;
	
SELECT
	ab.cr67a_assetid AS 'Asset ID',
	a.name AS 'Booked By',
	r.socoro_typename AS 'Service Tyep',
	r.socoro_locationname AS 'Location',
	c.fullname AS 'Contact'
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset r ON r.socoro_assetid = ab.socoro_asset
LEFT JOIN dbo.account a ON a.accountid = ab.cr67a_account
LEFT JOIN dbo.contact c ON ab.cr67a_contact = c.contactid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--booking created within reporting period
WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--indigenous --female
AND ((s.socoro_aboriginalstatus = 1 AND s.socoro_gender = '2') OR (c.socoro_businessowner = 1 AND gendercode = '977380001' AND cr67a_ismemberaboriginal = 1))
--active
AND ab.statecode = 0
AND ab.socoro_bookingstatus <> 2
--exclude whole hub booking
AND ab.socoro_bookwholehub = 0

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname AS 'Event Type',
	e.cr67a_venue as 'Event Venue',
	FORMAT(e.createdon, 'yyyy-MM-dd') AS 'Created On',
	FORMAT(e.cr67a_startdate, 'yyyy-MM-dd') AS 'Started Date',
	FORMAT(e.cr67a_enddate, 'yyyy-MM-dd') AS 'End Date'
FROM dbo.cr67a_event e
WHERE EXISTS (
	SELECT er.cr67a_eventregistrationid
	FROM dbo.cr67a_event e2
		LEFT JOIN dbo.cr67a_eventregistration er ON e2.cr67a_eventid = er.cr67a_event
		LEFT JOIN dbo.contact c ON er.cr67a_contact = c.contactid
		LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE e.cr67a_eventid = e2.cr67a_eventid
		--event falls within reporting period
		AND e2.cr67a_startdate >=(SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e2.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--indigenous --female
		AND ((s.socoro_aboriginalstatus = 1 AND s.socoro_gender = '2') OR (c.socoro_businessowner = 1 AND gendercode = '977380001' AND cr67a_ismemberaboriginal = 1))
);