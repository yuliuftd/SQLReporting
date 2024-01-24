/*young business owners being supported (aged 15-24)*/
--Number of young business owners being supported (aged 15-24)'
(SELECT 
	socoro_shareholderid AS 'Shareholder id',
	socoro_firstname + ' ' + socoro_lastname AS 'Name',
	FORMAT(a.createdon, 'yyyy-MM-dd') AS 'Account Created On',
	COALESCE(DATEDIFF(hour, s.socoro_birthday,getDate())/8766, DATEDIFF(hour, c.birthdate,getDate())/8766) AS 'Age',
	CASE 
		WHEN a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'Existing'
		WHEN a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'New'
		END AS 'Owner Type'
FROM dbo.socoro_shareholder s
	LEFT JOIN dbo.account a ON s.socoro_account = a.accountid
	LEFT JOIN dbo.contact c ON s.socoro_email = c.emailaddress1
	--created within reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--contact active
	AND s.statecode = 0
	--young
	AND (
	(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
	OR 
	(DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 AND c.socoro_businessowner = 1)
	)

UNION ALL

SELECT 
	s.socoro_shareholderid,
	c.fullname,
	FORMAT(c.createdon, 'yyyy-MM-dd'),
	DATEDIFF(hour, c.birthdate,getDate())/8766,
	CASE 
		WHEN c.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'Existing'
		WHEN c.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') THEN 'New'
		END AS 'Owner Type'
FROM dbo.contact c LEFT JOIN dbo.socoro_shareholder s ON s.socoro_email = c.emailaddress1
--created within reporting period
WHERE c.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--contact active
	AND c.statecode = 0
	--business owner
	AND c.socoro_businessowner = 1
	--young
	AND DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25
	AND	c.emailaddress1 NOT IN (SELECT socoro_email FROM dbo.socoro_shareholder)
)

--What percentage of services delivered were accessed by young business owners?
SELECT DISTINCT
	hs.cr67a_hubserviceid AS 'Service id',
	a.name AS 'Hub Service provided to:',
	hs.socoro_servicepackagename AS 'Service Package',
	hs.socoro_servicetypename AS 'Service Type',
	hs.socoro_modeofdeliveryname AS 'Delivery Mode',
	hs.socoro_locationofdeliveryname AS 'Delivery Location',
	c.fullname AS 'Contact'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.account a ON hs.socoro_account = a.accountid
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.contact c ON o.parentcontactid = c.contactid
FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--service created within reporting period
WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
		--service created prior to reporting period, opportunity open
		OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0)
		)
--young business owner
AND  (
	(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
	AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
	AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25
	AND c.socoro_businessowner = 1)
	)
--active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL;


SELECT DISTINCT
	ab.cr67a_assetid AS 'Asset id',
	a.name AS 'Booked By',
	r.socoro_typename AS 'Service Tyep',
	r.socoro_locationname AS 'Location',
	c.fullname AS 'Contact'
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset r ON r.socoro_assetid = ab.socoro_asset
LEFT JOIN dbo.account a ON a.accountid = ab.cr67a_account
LEFT JOIN dbo.contact c ON ab.cr67a_contact = c.contactid
FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--booking date within reporting period
WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--young business owner
AND  (
		(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
		AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
	OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
		AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 
		AND c.socoro_businessowner = 1)
		)
--active
AND ab.statecode = 0
AND ab.socoro_bookingstatus <> 2
--exclude whole hub booking
AND ab.socoro_bookwholehub = 0;

--'What percentage of events delivered were accessed by young business owners?'

SELECT
	e.cr67a_eventid AS 'Event id',
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
		FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE e.cr67a_eventid = e2.cr67a_eventid
		--event falls within reporting period
		AND e2.cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e2.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--young business owner
		AND  (
				(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
				AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
			OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
				AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 
				AND c.socoro_businessowner = 1)
			)
		);

DECLARE @a INT, @b INT, @c INT;

--Number of hubservice accessed by young owner
SELECT @a = COUNT(*) FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.account a ON hs.socoro_account = a.accountid
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.contact c ON o.parentcontactid = c.contactid
FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--service created within reporting period
WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
		--service created prior to reporting period, opportunity open
		OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0)
		)
--service active
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--young business owner
AND  (
	(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
	AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
	AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25
	AND c.socoro_businessowner = 1)
	);

--Number of hub asset accessed by young owner
SELECT @b = COUNT(*) 
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset r ON r.socoro_assetid = ab.socoro_asset
LEFT JOIN dbo.account a ON a.accountid = ab.cr67a_account
LEFT JOIN dbo.contact c ON ab.cr67a_contact = c.contactid
FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--booking date within reporting period
WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--active
AND ab.statecode = 0
AND ab.socoro_bookingstatus <> 2
--exclude whole hub booking
AND ab.socoro_bookwholehub = 0
--young business owner
AND  (
		(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
		AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
	OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
		AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 
		AND c.socoro_businessowner = 1)
		)

--Number of event accessed by young owner
SELECT @c = COUNT(*)
FROM dbo.cr67a_event e
WHERE EXISTS (
	SELECT er.cr67a_eventregistrationid
	FROM dbo.cr67a_event e2
		LEFT JOIN dbo.cr67a_eventregistration er ON e2.cr67a_eventid = er.cr67a_event
		LEFT JOIN dbo.contact c ON er.cr67a_contact = c.contactid
		FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE e.cr67a_eventid = e2.cr67a_eventid
		--event falls within reporting period
		AND e2.cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e2.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--young business owner
		AND  (
				(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
				AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
			OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
				AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 
				AND c.socoro_businessowner = 1)
			)
		)

SELECT 
	'Details' AS 'Data Type',
	@a AS 'Hub Service Accessed By Youth',
	(
	SELECT COUNT(cr67a_hubserviceid) 
	FROM dbo.cr67a_hubservice hs 
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
		--service created prior to reporting period, opportunity open
		OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0)
		)
		--active service
		AND hs.statecode = 0
		AND hs.socoro_opportunity IS NOT NULL

	) AS 'Total Hub Service',
	FORMAT( @a * 1.0 /NULLIF(
		(SELECT COUNT(cr67a_hubserviceid) FROM dbo.cr67a_hubservice hs 
		LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
		WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
		--service created prior to reporting period, opportunity open
		OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0)
		)
		--active service
		AND hs.statecode = 0
		AND hs.socoro_opportunity IS NOT NULL), 0), 'P') AS 'Percentage',
	@b AS 'Hub Asset Accessed By Youth',
	(
	SELECT COUNT(cr67a_assetid) 
	FROM dbo.cr67a_asset ab 
	WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--active
		AND ab.statecode = 0
		AND ab.socoro_bookingstatus <> 2
		--exclude whole hub booking
		AND ab.socoro_bookwholehub = 0
	),
	FORMAT( @b * 1.0 /NULLIF((SELECT COUNT(cr67a_assetid) FROM dbo.cr67a_asset ab WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--active
		AND ab.statecode = 0
		AND ab.socoro_bookingstatus <> 2
		--exclude whole hub booking
		AND ab.socoro_bookwholehub = 0
	), 0), 'P') AS 'Percentage',
	@c AS 'Event',
	(SELECT COUNT(cr67a_eventid) FROM dbo.cr67a_event e WHERE e.cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')),
	FORMAT( @c * 1.0 /NULLIF((SELECT COUNT(cr67a_eventid) FROM dbo.cr67a_event e WHERE e.cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')), 0), 'P') AS 'Percentage'