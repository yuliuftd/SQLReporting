SELECT
	hs.cr67a_hubserviceid AS 'Service Id',
	a.name AS 'Hub Service provided to:', 
	hs.socoro_servicepackagename AS 'Service Package',
	hs.socoro_servicetypename AS 'Service Type',
	hs.socoro_modeofdeliveryname AS 'Delivery Mode',
	hs.socoro_locationofdeliveryname AS 'Delivery Location',
	c.fullname AS 'Contact',
	ISNULL(hs.socoro_fundingtypename, '') as 'Funding Type',
	ISNULL(FORMAT(hs.socoro_costofservice, 'N1'), '') AS 'Cost of Service'
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
--business owner --indigenous --live not in Darwin
AND (
(s.socoro_aboriginalstatus = 1 AND s.socoro_northterritoryregion not in (4,7)) 
OR (c.socoro_businessowner = 1 AND c.socoro_northernterritoryregion not in (4,7) AND c.cr67a_ismemberaboriginal = 1))
--service active
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL;

SELECT
a.name AS 'Booking Service provided TO:',
--ast.socoro_locationname AS 'Location',
c.fullname AS Contact,
socoro_bookingstatusname AS 'Status',
FORMAT(cr67a_bookingdate, 'yyyy-MM-dd') AS 'Booking Date',
socoro_bookingstarttimename AS 'Start',
socoro_bookingendtimename AS 'End'
FROM dbo.cr67a_asset ab
--LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
LEFT JOIN dbo.contact c ON ab.cr67a_contact = c.contactid
LEFT JOIN dbo.account a ON a.accountid = ab.cr67a_account
FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--booking created within reporting period
WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--business owner --indigenous --live not in Darwin
AND (
(s.socoro_aboriginalstatus = 1 AND s.socoro_northterritoryregion not in (4,7)) 
OR (c.socoro_businessowner = 1 AND c.socoro_northernterritoryregion not in (4,7) AND c.cr67a_ismemberaboriginal = 1))
--booking active
AND ab.statecode = 0
AND ab.socoro_bookingstatus <> 2
--exclude whole hub booking
AND ab.socoro_bookwholehub = 0;

SELECT
	e.cr67a_eventname AS 'Event Name',
	e.socoro_eventcategoryname 'Events Type',
	e.socoro_numberofregistrations AS 'Number of Participants',
	e.cr67a_venue AS 'Event Venue',
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
		AND e2.cr67a_startdate >=(SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e2.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--business owner --indigenous --live not in Darwin
		AND (
		(s.socoro_aboriginalstatus = 1 AND s.socoro_northterritoryregion not in (4,7)) 
		OR (c.socoro_businessowner = 1 AND c.socoro_northernterritoryregion not in (4,7) AND c.cr67a_ismemberaboriginal = 1))
);