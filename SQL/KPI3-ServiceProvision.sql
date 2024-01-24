/*
	3.1 Number of individuals receiving referral specialist services
*/

SELECT
	'Existing individuals' AS 'Status',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) AS 'Total',
	FORMAT(
		COUNT(DISTINCT CASE WHEN (c.gendercode = '977380001' or s.socoro_gender = 2) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% female',
		FORMAT(
		COUNT(DISTINCT CASE WHEN ((DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 <= 24) 
									or (DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour,s.socoro_birthday,getDate())/8766 <=
									24)) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% youth', 
		FORMAT(
		COUNT(DISTINCT CASE WHEN COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) not in (4,7) AND COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NOT NULL THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% remote',
	FORMAT(
		COUNT(DISTINCT CASE WHEN
			((c.gendercode <> '977380001' OR c.gendercode IS NULL) AND (s.socoro_gender <> '2' OR s.socoro_gender IS NULL))
			AND ((DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) < 15 OR (DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) > 24 OR COALESCE(c.birthdate,s.socoro_birthday) IS NULL)
			AND (COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) in (4,7) OR COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NULL)
		THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% other'

	FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	LEFT JOIN lead l ON o.originatingleadid = l.leadid
	LEFT JOIN contact c ON hs.socoro_contact = c.contactid
	LEFT JOIN account a ON hs.socoro_account  = a.accountid
	LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE
		--service created prior to reporting period, opportunity open
		(
			hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
			AND o.statecode = 0
		)
	--Active service
	AND hs.statecode = 0
	AND hs.socoro_opportunity IS NOT NULL
	--referred specialist
	AND hs.socoro_serviceprovidertype = 2

UNION ALL

SELECT
	'New individuals',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) ,
	FORMAT(
		COUNT(DISTINCT CASE WHEN (c.gendercode = '977380001' or s.socoro_gender = 2) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% female',
		FORMAT(
		COUNT(DISTINCT CASE WHEN ((DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 <= 24) 
									or (DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour,s.socoro_birthday,getDate())/8766 <= 24)) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% youth', 
		FORMAT(
		COUNT(DISTINCT CASE WHEN COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) not in (4,7) AND COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NOT NULL THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% remote',
	FORMAT(
		COUNT(DISTINCT CASE WHEN
			((c.gendercode <> '977380001' OR c.gendercode IS NULL) AND (s.socoro_gender <> '2' OR s.socoro_gender IS NULL))
			AND ((DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) < 15 OR (DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) > 24 OR COALESCE(c.birthdate,s.socoro_birthday) IS NULL)
			AND (COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) in (4,7) OR COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NULL)
		THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% other'

FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	LEFT JOIN lead l ON o.originatingleadid = l.leadid
	LEFT JOIN contact c ON hs.socoro_contact = c.contactid
	LEFT JOIN account a ON hs.socoro_account  = a.accountid
	LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--hub service created within reporting period
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2;



/*
	3.2 Number of individuals receiving in-house services
*/
SELECT
	'Existing individuals' AS 'Status',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) AS 'Total',
	FORMAT(
		COUNT(DISTINCT CASE WHEN (c.gendercode = '977380001' or s.socoro_gender = 2) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% female',
		FORMAT(
		COUNT(DISTINCT CASE WHEN ((DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 <= 24) 
									or (DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour,s.socoro_birthday,getDate())/8766 <=
									24)) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% youth', 
		FORMAT(
		COUNT(DISTINCT CASE WHEN COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) not in (4,7) AND COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NOT NULL THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% remote',
	FORMAT(
		COUNT(DISTINCT CASE WHEN
			((c.gendercode <> '977380001' OR c.gendercode IS NULL) AND (s.socoro_gender <> '2' OR s.socoro_gender IS NULL))
			AND ((DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) < 15 OR (DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) > 24 OR COALESCE(c.birthdate,s.socoro_birthday) IS NULL)
			AND (COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) in (4,7) OR COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NULL)
		THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% other'

	FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	LEFT JOIN lead l ON o.originatingleadid = l.leadid
	LEFT JOIN contact c ON hs.socoro_contact = c.contactid
	LEFT JOIN account a ON hs.socoro_account  = a.accountid
	LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE
		--service created prior to reporting period, opportunity open
		(
			hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
			AND o.statecode = 0
		)
	--Active service
	AND hs.statecode = 0
	AND hs.socoro_opportunity IS NOT NULL
	--in-house
	AND hs.socoro_serviceprovidertype = 1

UNION ALL

SELECT
	'New individuals',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) ,
	FORMAT(
		COUNT(DISTINCT CASE WHEN (c.gendercode = '977380001' or s.socoro_gender = 2) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% female',
		FORMAT(
		COUNT(DISTINCT CASE WHEN ((DATEDIFF(hour, c.birthdate,getDate())/8766 >= 15 AND DATEDIFF(hour,c.birthdate,getDate())/8766 <= 24) 
									or (DATEDIFF(hour, s.socoro_birthday,getDate())/8766 >= 15 AND DATEDIFF(hour,s.socoro_birthday,getDate())/8766 <= 24)) THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% youth', 
		FORMAT(
		COUNT(DISTINCT CASE WHEN COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) not in (4,7) AND COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NOT NULL THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% remote',
	FORMAT(
		COUNT(DISTINCT CASE WHEN
			((c.gendercode <> '977380001' OR c.gendercode IS NULL) AND (s.socoro_gender <> '2' OR s.socoro_gender IS NULL))
			AND ((DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) < 15 OR (DATEDIFF(hour, COALESCE(c.birthdate,s.socoro_birthday),getDate())/8766) > 24 OR COALESCE(c.birthdate,s.socoro_birthday) IS NULL)
			AND (COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) in (4,7) OR COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) IS NULL)
		THEN COALESCE(c.contactid,a.accountid, l.leadid) END) * 1.0
		/ NULLIF(COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))), 0),
	'P') AS '% other'

FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	LEFT JOIN lead l ON o.originatingleadid = l.leadid
	LEFT JOIN contact c ON hs.socoro_contact = c.contactid
	LEFT JOIN account a ON hs.socoro_account  = a.accountid
	LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
--hub service created within reporting period
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--in-house
AND hs.socoro_serviceprovidertype = 1;


/*
	Breakdown by business activity
*/

SELECT
	map.label AS Measurement,
	COUNT(DISTINCT(data.hubid)) AS 'Total',
	ISNULL(
		FORMAT(
			COUNT(DISTINCT CASE WHEN (data.gendercode = '977380001' or data.socoro_gender = 2) THEN data.id END) * 1.0
			/ NULLIF(COUNT(DISTINCT(data.id)), 0),
		'P')
	, '--') AS '% female',
	ISNULL(
		FORMAT(
			COUNT(DISTINCT CASE WHEN (DATEDIFF(hour, data.birthday,getDate())/8766 >= 15 AND DATEDIFF(hour,data.birthday,getDate())/8766 <= 24) THEN data.id END) * 1.0
			/ NULLIF(COUNT(DISTINCT(data.id)), 0),
		'P')
	, '--') AS '% youth',
	ISNULL(
		FORMAT(
			COUNT(DISTINCT CASE WHEN (data.region not in (4,7) AND data.region IS NOT NULL)THEN data.id END) * 1.0
			/ NULLIF(COUNT(DISTINCT(data.id)), 0),
		'P')
	, '--') AS '% remote',
	ISNULL(
		FORMAT(
			COUNT(DISTINCT CASE WHEN
			((data.gendercode <> '977380001' OR data.gendercode IS NULL) AND (data.socoro_gender <> '2' OR data.socoro_gender IS NULL))
				AND ((DATEDIFF(hour, data.birthday,getDate())/8766) < 15 OR (DATEDIFF(hour, data.birthday,getDate())/8766) > 24 OR data.birthday IS NULL)
				AND (data.region in (4,7) OR data.region IS NULL)
		THEN data.id END) * 1.0
			/ NULLIF(COUNT(DISTINCT(data.id)), 0),
		'P')
	, '--') AS '% other'
FROM
(
	SELECT 10 AS sort, 'Mentor / coaching' AS label, 1 AS value UNION ALL
	SELECT 20, 'Business planning', 2 UNION ALL
	SELECT 30, 'Business in a box', 3 UNION ALL
	SELECT 40, 'Document library', 4 UNION ALL
	SELECT 50, 'Ideation / incubation', 5 UNION ALL
	SELECT 60, 'Business concierge', 6 UNION ALL
	SELECT 70, 'Policy development', 7 UNION ALL
	SELECT 80, 'Networking & connecting opportunities', 8 UNION ALL
	SELECT 90, 'Support letter', 24 UNION ALL
	SELECT 100, 'Grant writing', 10 UNION ALL
	SELECT 110, 'Tender writing', 11 UNION ALL
	SELECT 120, 'Financial feasibility', 12 UNION ALL
	SELECT 130, 'Financial management', 13 UNION ALL
	SELECT 140, 'HR services', 14 UNION ALL
	SELECT 150, 'Website development', 15 UNION ALL
	SELECT 160, 'Systems development', 16 UNION ALL
	SELECT 170, 'JV/partnership support', 17 UNION ALL
	SELECT 180, 'Risk management', 18 UNION ALL
	SELECT 190, 'Crisis management', 19 UNION ALL
	SELECT 200, 'Ecommerce services', 20 UNION ALL
	SELECT 210, 'Export services', 21 UNION ALL
	SELECT 220, 'Marketing and social media', 22 UNION ALL
	SELECT 230, 'Back-of-house support', 23
) map
LEFT JOIN
(
	SELECT
		hs.cr67a_hubserviceid as hubid,
		COALESCE(c.contactid,a.accountid, l.leadid) AS id,
		COALESCE(c.socoro_northernterritoryregion, 
			s.socoro_northterritoryregion, a.socoro_northernterritoryregion) AS region,
		c.gendercode,
		s.socoro_gender,
		COALESCE(c.birthdate,s.socoro_birthday) AS birthday,
		hs.socoro_servicetype AS service
	FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	LEFT JOIN lead l ON o.originatingleadid = l.leadid
	LEFT JOIN contact c ON hs.socoro_contact = c.contactid
	LEFT JOIN account a ON hs.socoro_account  = a.accountid
	LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
	WHERE (
		--service created within reporting period
		(
			hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
			AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		)
		--service created prior to reporting period, opportunity open
		OR (
			hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
			AND o.statecode = 0
		)
	)
		--Active service
		AND hs.statecode = 0
		AND hs.socoro_opportunity IS NOT NULL
) data
ON map.value = data.service
GROUP BY map.sort, map.label, map.value
ORDER BY map.sort;




/*
	3.4 Hub facility bookings
*/

SELECT
	'Number of Hub facility bookings' AS Measurement,
	COUNT(ab.cr67a_assetid) AS Result
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
-- not book the whole hub
AND ab.socoro_bookwholehub = 0;



/*
	Breakdown by category
*/

SELECT
	'Business client bookings to use the Hub facilities to work or meet with clients' AS 'Booking category',
	COUNT(ab.cr67a_assetid) AS '# of bookings'
FROM dbo.cr67a_asset ab
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
-- not book the whole hub
AND ab.socoro_bookwholehub = 0
--work or meet with clients
AND (ab.socoro_bookingpurpose = 0 or ab.socoro_bookingpurpose IS NULL)

UNION ALL

SELECT
	'Job seeker booking to use the facilities to develop and submit employment applications',
	COUNT(ab.cr67a_assetid)
FROM dbo.cr67a_asset ab
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
-- not book the whole hub
AND ab.socoro_bookwholehub = 0
--develop and submit employment application
AND ab.socoro_bookingpurpose = 1

UNION ALL

SELECT
	'Other stakeholder bookings to connect Aboriginal and Torres Strait Islander businesses and/or job seekers',
	COUNT(ab.cr67a_assetid)
FROM dbo.cr67a_asset ab
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
-- not book the whole hub
AND ab.socoro_bookwholehub = 0
--connect Aboriginal and Torres Strait Islander businesses and/or job seekers
AND ab.socoro_bookingpurpose = 2

UNION ALL

SELECT
	'Other stakeholder bookings to consult with NT stakeholders on economic matters of interest to NT businesses',
	COUNT(ab.cr67a_assetid)
FROM dbo.cr67a_asset ab
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
-- not book the whole hub
AND ab.socoro_bookwholehub = 0
--consult with NT stakeholders on economic matters of interest to NT businesses
AND ab.socoro_bookingpurpose = 3;



/*
	3.6 Business interactions to employ job seekers
*/

SELECT COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--employment services
AND hs.socoro_serviceprovidertype = 3;