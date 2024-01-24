/*
	Total businesses
*/

SELECT
	'Darwin' AS Measurement,
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) AS Result
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
---darwin
AND u.socoro_location = 1

UNION ALL

SELECT
	'Alice Springs',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid)))
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--alice springs
AND u.socoro_location = 2

UNION ALL

SELECT
	'Katherine',
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid)))
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--katherine
AND u.socoro_location = 3;



SELECT
	'Total number of businesses on the Business Services Package, being supported by a referred specialist' AS Measurement,
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) AS Result
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2



/*
	Breakdown by address region
*/

SELECT 
	map.label AS 'Address Region',
	COUNT(DISTINCT(data.id)) AS '# of Businesses '
FROM 
	(
	SELECT 1 AS value, 'Barkly' AS label UNION ALL
	SELECT 2, 'Big Rivers' UNION ALL
	SELECT 3, 'Central Australia'  UNION ALL
	SELECT 4, 'Darwin'UNION ALL
	SELECT 5, 'East Arnhem'  UNION ALL
	SELECT 6, 'Top End' UNION ALL
	SELECT 7, 'None'  

) map
LEFT JOIN (
	SELECT
		COALESCE(c.contactid,a.accountid, l.leadid) as id,
		COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion) AS region
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
LEFT JOIN account a ON hs.socoro_account  = a.accountid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
		--referred specialist
		AND hs.socoro_serviceprovidertype = 2
		--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
) data 
ON map.value = data.region
GROUP BY map.value,map.label
ORDER BY map.value;



/*
	Referral specialist service
*/

SELECT
	'Darwin' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result 
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--darwin
AND u.socoro_location = 1

UNION ALL

SELECT
	'Alice Springs',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--alice springs
AND u.socoro_location = 2

UNION ALL

SELECT
	'Katherine',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--katherine
AND u.socoro_location = 3;



SELECT
	'Number of referred specialist business advisory activities delivered to clients' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2;




/*
	Commonwealth service
*/

SELECT
	'Darwin' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result 
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--commonwealth
AND hs.socoro_serviceprovidertype = 3
--darwin
AND u.socoro_location = 1

UNION ALL

SELECT
	'Alice Springs',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--commonwealth
AND hs.socoro_serviceprovidertype = 3
--alice springs
AND u.socoro_location = 2

UNION ALL

SELECT
	'Katherine',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--commonwealth specialist
AND hs.socoro_serviceprovidertype = 3
--katherine
AND u.socoro_location = 3;



SELECT
	'Number of Referrals to other Commonwealth funded programs ' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--commonwealth specialist
AND hs.socoro_serviceprovidertype = 3;



/*
	NTG service
*/

SELECT
	'Darwin' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result 
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--ntg
AND hs.socoro_serviceprovidertype = 4
--darwin
AND u.socoro_location = 1

UNION ALL

SELECT
	'Alice Springs',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
AND hs.socoro_serviceprovidertype = 4
--alice springs
AND u.socoro_location = 2

UNION ALL

SELECT
	'Katherine',
	COUNT(hs.cr67a_hubserviceid)
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--ntg specialist
AND hs.socoro_serviceprovidertype = 4
--katherine
AND u.socoro_location = 3;



SELECT
	'Number of Referrals to NTG programs' AS Measurement,
	COUNT(hs.cr67a_hubserviceid) AS Result
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--ntg specialist
AND hs.socoro_serviceprovidertype = 4;



/*
	Total referred specialist services & cost
*/

SELECT
	map.label AS Service,
	COUNT(DISTINCT CASE WHEN data.createdon < qstart.cr67a_value AND data.oppstatus = 0 THEN data.id END) AS '# active services',
	FORMAT(
		ISNULL(
			SUM(CASE WHEN data.createdon < qstart.cr67a_value AND data.oppstatus = 0 THEN data.cost END)
		, 0)
	, 'C') AS 'Active services total cost',
	COUNT(DISTINCT CASE WHEN data.createdon >= qstart.cr67a_value AND data.createdon < qend.cr67a_value THEN data.id END) AS '# new services',
	FORMAT(
		ISNULL(
			SUM(CASE WHEN data.createdon >= qstart.cr67a_value AND data.createdon < qend.cr67a_value THEN data.cost END)
		, 0)
	, 'C') AS 'New services total cost'
FROM
(
	SELECT 10 AS sort, 'Grant writing' AS label, 10 AS value UNION ALL
	SELECT 20, 'Tender writing', 11 UNION ALL
	SELECT 30, 'Financial feasibility', 12 UNION ALL
	SELECT 40, 'Financial management', 13 UNION ALL
	SELECT 50, 'HR services', 14 UNION ALL
	SELECT 60, 'Website development', 15 UNION ALL
	SELECT 70, 'Systems development', 16 UNION ALL
	SELECT 80, 'JV/partnership support', 17 UNION ALL
	SELECT 90, 'Risk management', 18 UNION ALL
	SELECT 100, 'Crisis management', 19 UNION ALL
	SELECT 110, 'Ecommerce services', 20 UNION ALL
	SELECT 120, 'Export services', 21 UNION ALL
	SELECT 130, 'Marketing and social media', 22 UNION ALL
	SELECT 140, 'Back-of-house support', 23
) map
LEFT JOIN
(
	SELECT
		hs.cr67a_hubserviceid AS id,
		hs.socoro_servicetype AS servicetype,
		hs.socoro_costofservice AS cost,
		hs.createdon,
		o.statecode AS oppstatus
	FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
	--referred specialist
	WHERE hs.socoro_serviceprovidertype = 2
		--Active service
	AND hs.statecode = 0
	AND hs.socoro_opportunity IS NOT NULL
) data
ON map.value = data.servicetype
INNER JOIN dbo.cr67a_configuration qstart ON qstart.cr67a_variable = 'QUARTER_START_DATE'
INNER JOIN dbo.cr67a_configuration qend ON qend.cr67a_variable = 'QUARTER_END_DATE'
GROUP BY map.sort, map.label, map.value
ORDER BY map.sort;