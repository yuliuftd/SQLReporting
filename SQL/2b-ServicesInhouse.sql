SELECT
	'Total number of businesses on the Business Services Package, being supported in-house' AS Measurement,
	COUNT(DISTINCT CASE WHEN socoro_location = 1 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS Darwin,
	COUNT(DISTINCT CASE WHEN socoro_location = 2 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS 'Alice Springs',
	COUNT(DISTINCT CASE WHEN socoro_location = 3 THEN COALESCE(c.contactid,a.accountid, l.leadid) END) AS Katherine,
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
	--in-house
	AND hs.socoro_serviceprovidertype = 1

UNION ALL

SELECT
	'Number of in-house business advisory activities delivered to clients',
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
--in-house
AND hs.socoro_serviceprovidertype = 1

UNION ALL

SELECT
	'Number of IEC-led meetings with clients to deliver in-house support',
	COUNT(DISTINCT CASE WHEN socoro_location = 1 THEN appt.subject END) AS Darwin,
	COUNT(DISTINCT CASE WHEN socoro_location = 2 THEN appt.subject END) AS 'Alice Springs',
	COUNT(DISTINCT CASE WHEN socoro_location = 3 THEN appt.subject END) AS Katherine,
	COUNT(appt.subject)
FROM dbo.appointment appt
LEFT JOIN dbo.systemuser u ON appt.createdby = u.systemuserid

--appointment falls within reporting period
WHERE appt.scheduledstart >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND appt.scheduledstart < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	AND appt.statecode != 2;



/*
	Type of support provided
*/

SELECT
	map.label AS Service,
	COUNT(DISTINCT CASE WHEN data.createdon < qstart.cr67a_value AND data.oppstatus = 0 THEN data.id END) AS '# active services',
	COUNT(DISTINCT CASE WHEN data.createdon >= qstart.cr67a_value AND data.createdon < qend.cr67a_value THEN data.id END) AS '# new services'
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
		hs.cr67a_hubserviceid AS id,
		hs.socoro_servicetype AS servicetype,
		hs.createdon,
		o.statecode AS oppstatus
	FROM dbo.cr67a_hubservice hs
	LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid

	--in-house
	WHERE hs.socoro_serviceprovidertype = 1
		--Active service
	AND hs.statecode = 0
	AND hs.socoro_opportunity IS NOT NULL
) data
ON map.value = data.servicetype
INNER JOIN dbo.cr67a_configuration qstart ON qstart.cr67a_variable = 'QUARTER_START_DATE'
INNER JOIN dbo.cr67a_configuration qend ON qend.cr67a_variable = 'QUARTER_END_DATE'
GROUP BY map.sort, map.label, map.value
ORDER BY map.sort;



/*
	Number of new coaching & mentoring services with demographics
*/

SELECT
	ROW_NUMBER() OVER (ORDER BY hs.createdon) AS '#',
	ISNULL(CAST(COALESCE(DATEDIFF(hour,c.birthdate,getDate())/8766,DATEDIFF(hour, s.socoro_birthday,getDate())/8766) AS VARCHAR), '--') AS Age,
	ISNULL(
		CASE
			WHEN c.gendercode = 977380000 THEN 'Male'
			WHEN c.gendercode = 977380001 THEN 'Female'
			WHEN c.gendercode = 977380003 THEN 'Non-Binary'
		END, '--') AS Gender,
	ISNULL(
		CASE COALESCE(c.socoro_northernterritoryregion, s.socoro_northterritoryregion, a.socoro_northernterritoryregion)
			WHEN 1 THEN 'Barkly'
			WHEN 2 THEN 'Big Rivers'
			WHEN 3 THEN 'Central Australia'
			WHEN 4 THEN 'Darwin'
			WHEN 5 THEN 'East Arnhem'
			WHEN 6 THEN 'Top End'
			WHEN 7 THEN 'None'
		END, 'None') AS Location
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email

--service created within reporting period
WHERE hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--mentoring/coaching
AND hs.socoro_servicetype = 1
--in-house
AND hs.socoro_serviceprovidertype = 1;



/*
	Breakdown of procure connect activity
*/

SELECT
	map.value AS 'Project size',
	COUNT(DISTINCT CASE WHEN data.status = '977380000' THEN data.id ELSE NULL END) AS '# RFQs open',
	COUNT(DISTINCT CASE WHEN data.status = '977380003' THEN data.id ELSE NULL END) AS '# RFQs awarded',
	COUNT(DISTINCT CASE WHEN data.status = '977380001' THEN data.id ELSE NULL END) AS '# RFQs closed without awarding',
	ISNULL(SUM(data.eoicount), 0) AS '# EOIs'
FROM
(
	SELECT 'Less than $5,000' AS value, 0 AS sort UNION ALL
	SELECT '$5,000 to $19,999', 1 UNION ALL
	SELECT '$20,000 to $49,999', 2 UNION ALL
	SELECT '$50,000 to $149,9990', 3 UNION ALL
	SELECT '$150,000 to $499,999', 4 UNION ALL
	SELECT '$500,000 to $2,499,999', 5 UNION ALL
	SELECT '$2,500,000 and more', 6
) map
LEFT JOIN
(
	SELECT
		r.cr67a_rfqid AS id,
		r.cr67a_status AS status,
		r.cr67a_eoicount AS eoicount,
		r.socoro_projectsize AS projectsize
	FROM dbo.cr67a_rfq r
	--created within reporting period
	WHERE r.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
	AND r.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')

) data
ON map.sort = data.projectsize
GROUP BY map.sort, map.value
ORDER BY map.sort;