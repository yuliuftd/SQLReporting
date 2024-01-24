/*young business owners being supported (aged 15-24)*/
SELECT 		'Number of young business owners being supported (aged 15-24)' AS Measurement,
	(
		(SELECT COUNT(DISTINCT(s.socoro_shareholderid))
		FROM dbo.socoro_shareholder s
			LEFT JOIN dbo.account a ON s.socoro_account = a.accountid
			LEFT JOIN dbo.contact c ON s.socoro_email = c.emailaddress1
			--created within reporting period
		WHERE 
		--a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND 
		a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
			--contact active
			AND s.statecode = 0
			--young
			AND (
			(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
			OR 
			(DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 AND c.socoro_businessowner = 1)
			)
		)
	 +
		(SELECT COUNT(DISTINCT(c.contactid))
		FROM dbo.contact c
		--created within reporting period
		WHERE 
			--c.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND 
			c.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
			--contact active
			AND c.statecode = 0
			--young
			AND DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25
			AND c.emailaddress1 NOT IN (
				SELECT socoro_email
				FROM dbo.socoro_shareholder s
			))
	) AS Result

SELECT
	'What percentage of services delivered were accessed by young business owners?' AS Measurement,
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
			--young business owner
			AND  (
				(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
				AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 25) 
			OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
				AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 25 
				AND c.socoro_businessowner = 1)
				)

		)* 1.0

		+

		(
			SELECT
				COUNT(DISTINCT(ab.cr67a_assetid))
			FROM dbo.cr67a_asset ab
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
					AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 24) 
				OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
					AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 24 
					AND c.socoro_businessowner = 1)
					)
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
	'What percentage of events delivered were accessed by young business owners?',
	FORMAT(
		COUNT(DISTINCT(e.cr67a_eventid)) * 1.0
		/ NULLIF((SELECT COUNT(DISTINCT(cr67a_eventid)) FROM dbo.cr67a_event WHERE cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')), 0),
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
		AND e2.cr67a_startdate >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND e2.cr67a_startdate < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		--young business owner
		AND  (
				(DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 
				AND DATEDIFF(hour, s.socoro_birthday,getDate())/8766 < 24) 
			OR (DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 
				AND DATEDIFF(hour,c.birthdate,getDate())/8766 < 24 
				AND c.socoro_businessowner = 1)
			)
);