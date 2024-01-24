SELECT
	'Total number of businesses on the Employment Support Package' AS Measurement,
	COUNT(DISTINCT CASE WHEN socoro_location = 1 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS Darwin,
	COUNT(DISTINCT CASE WHEN socoro_location = 2 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS 'Alice Springs',
	COUNT(DISTINCT CASE WHEN socoro_location = 3 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS Katherine,
	COUNT(DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid))) AS Total
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
--Employment support
AND hs.socoro_servicepackage = 3

UNION ALL

SELECT
	'Number of Employment business advisory activities delivered to clients',
	COUNT(DISTINCT CASE WHEN socoro_location = 1 THEN hs.cr67a_hubserviceid END) AS Darwin,
	COUNT(DISTINCT CASE WHEN socoro_location = 2 THEN hs.cr67a_hubserviceid END) AS 'Alice Springs',
	COUNT(DISTINCT CASE WHEN socoro_location = 3 THEN hs.cr67a_hubserviceid END) AS Katherine,
	COUNT(hs.cr67a_hubserviceid) AS Total
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
--Employment support
AND hs.socoro_servicepackage = 3




/*
	Type of support provided
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
	, 'C') AS 'New services total cost'FROM
(
	SELECT 250 AS Sort, 'Resume support services'AS label, 25 AS value UNION ALL
	SELECT 260, 'Referrals to employment service providers', 26 UNION ALL
	SELECT 270, 'Access to Hub facilities ', 27 UNION ALL
	SELECT 280, 'Career assessment', 28 UNION ALL
	SELECT 290, 'Potential employment opportunities', 29 UNION ALL
	SELECT 300, 'Interview support services', 30 UNION ALL
	SELECT 310, 'Education and training guidance', 31
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
	WHERE --Employment support
	hs.socoro_servicepackage = 3
		--Active service
	AND hs.statecode = 0
	AND hs.socoro_opportunity IS NOT NULL
) data
ON map.value = data.servicetype
INNER JOIN dbo.cr67a_configuration qstart ON qstart.cr67a_variable = 'QUARTER_START_DATE'
INNER JOIN dbo.cr67a_configuration qend ON qend.cr67a_variable = 'QUARTER_END_DATE'
GROUP BY map.sort, map.label, map.value
ORDER BY map.sort;




