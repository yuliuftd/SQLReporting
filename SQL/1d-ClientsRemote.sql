SELECT
	'What percentage of services delivered were accessed by Indigenous business owners living in remote Australia?' AS Measurement,
	FORMAT(
		((
			SELECT
				COUNT(DISTINCT(hs.cr67a_hubserviceid))
			FROM dbo.cr67a_hubservice hs
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
			--active service
					AND hs.statecode = 0
					AND hs.socoro_opportunity IS NOT NULL
			--business owner --indigenous --live not in Darwin
			AND (
			(s.socoro_aboriginalstatus = 1 AND s.socoro_northterritoryregion not in (4,7)) 
			OR (c.socoro_businessowner = 1 AND c.socoro_northernterritoryregion not in (4,7) AND c.cr67a_ismemberaboriginal = 1))

		)

		+

		(
			SELECT
				COUNT(DISTINCT(ab.cr67a_assetid))
			FROM dbo.cr67a_asset ab
			LEFT JOIN dbo.contact c ON ab.cr67a_contact = c.contactid
			FULL OUTER JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
			--booking created within reporting period
			WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
			AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
			--active
					AND ab.statecode = 0
					AND ab.socoro_bookingstatus <> 2
			--exclude whole hub booking
					AND ab.socoro_bookwholehub = 0
			--business owner --indigenous --live not in Darwin
			AND (
			(s.socoro_aboriginalstatus = 1 AND s.socoro_northterritoryregion not in (4,7)) 
			OR (c.socoro_businessowner = 1 AND c.socoro_northernterritoryregion not in (4,7) AND c.cr67a_ismemberaboriginal = 1))
		)) * 1.0
		/ NULLIF(
			((SELECT COUNT(cr67a_hubserviceid) FROM dbo.cr67a_hubservice hs 
				LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
				WHERE ((hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
					AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
					--service created prior to reporting period, opportunity open
					OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
					AND o.statecode = 0)
					)
					--active service
					AND hs.statecode = 0
					AND hs.socoro_opportunity IS NOT NULL)
			+ (SELECT COUNT(cr67a_assetid) 
				FROM dbo.cr67a_asset ab 
				WHERE ab.cr67a_bookingdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
					AND ab.cr67a_bookingdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
					--active
					AND ab.statecode = 0
					AND ab.socoro_bookingstatus <> 2
					--exclude whole hub booking
					AND ab.socoro_bookwholehub = 0))
		, 0),
	'P') AS Result

UNION ALL

SELECT
	'What percentage of events delivered were accessed by Indigenous business owners living in remote Australia?',
	FORMAT(
		COUNT(DISTINCT(e.cr67a_eventid)) * 1.0
		/ NULLIF((SELECT COUNT(DISTINCT(cr67a_eventid)) FROM dbo.cr67a_event WHERE  createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')), 0),
	'P')
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