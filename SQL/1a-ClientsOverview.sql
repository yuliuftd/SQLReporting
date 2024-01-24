/*
	Breakdown of total businesses
*/

SELECT
	'Hub asset' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub asset client
AND (a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)

UNION ALL

SELECT
	'Hub service',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub service client
AND (
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
		OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
)

UNION ALL

SELECT
	'Certified member',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--certified member
AND  (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))

UNION ALL

SELECT
	'Event attendee',
	COUNT(DISTINCT(er.cr67a_contact))
FROM dbo.cr67a_eventregistration er 
LEFT JOIN dbo.contact c ON er.cr67a_contact = c.contactid
LEFT JOIN dbo.account a ON c.parentcustomerid = a.accountid 
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--event attendee
AND (
	UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
);

/*
	Total businesses
*/

SELECT
	'Number of total Indigenous businesses registered with the Hub' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN dbo.lead l on a.accountid = l.parentaccountid
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--registered with the Hub
AND (
	--hub asset / hub service client
	(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)
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
);

/*
	Breakdown by Address Region
*/

SELECT
		CASE WHEN map.value >= 7 THEN 'None' ELSE map.label END AS 'Address region',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 3 AND data.nonmembersubcategory = 1) THEN data.id END) AS 'Hub asset',
		COUNT(DISTINCT CASE WHEN (
			(data.relationshiptype = 3 AND data.nonmembersubcategory = 3) 
			OR (data.leadtype IN (3,5) AND data.leadstatus = 0)
		) THEN data.id END) as 'Hub service',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 1 and data.accountstatus IN (4, 5, 9, 11, 12)) THEN data.id END) AS 'Certified members',
		COUNT(DISTINCT CASE WHEN (
			(UPPER(data.eventname) NOT LIKE '%BBA%'
			AND UPPER(data.eventname) NOT LIKE '%Blak Business Awards%'
			AND UPPER(data.eventname) NOT LIKE '%AEDF%'
			AND UPPER(data.eventname) NOT LIKE '%Aboriginal Economic Development Forum%')
		) THEN data.id END) AS 'Event attendees'
	FROM
	(
		SELECT 1 AS value, 'Barkly' AS label UNION ALL
		SELECT 2, 'Big Rivers' UNION ALL
		SELECT 3, 'Central Australia' UNION ALL
		SELECT 4, 'Darwin' UNION ALL
		SELECT 5, 'East Arnhem' UNION ALL
		SELECT 6, 'Top End' UNION ALL
		SELECT 7 , 'None' 
	) map
	LEFT JOIN 
	(
		SELECT 
			a.accountid AS id,
			a3.relationshiptype AS relationshiptype,
			a4.nonmembersubcategory AS nonmembersubcategory,
			l.socoro_leadtype AS leadtype,
			l.statecode AS leadstatus,
			cr67a_accountstatus AS accountstatus,
			e.cr67a_eventname AS eventname,
			COALESCE(c.socoro_northernterritoryregion, a.socoro_northernterritoryregion) AS region
		FROM dbo.account a 
			LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
				ON a.accountid = a2.accountid
			LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
				ON a.accountid = a3.accountid
			LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
				ON a.accountid = a4.accountid
			LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
			LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
			LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
			LEFT JOIN lead l ON a.accountid = l.parentaccountid
		WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
				--account active
				AND a.statecode = 0
				--indigenous business
				AND (
					--certified by NTIBN, certification level is 100% or majority
					(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
					--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
					OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
					--certified by is none, self identified is yes
					OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
				) 
	) data ON map.value = data.region
GROUP BY map.value,map.label 
ORDER BY map.value


/*
	Breakdown of existing businesses
*/

SELECT
	'Hub asset' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
--created prior to reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub asset client
AND (a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)

UNION ALL

SELECT
	'Hub service',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
--created prior to reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub service client
AND (
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
		OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
)

UNION ALL

SELECT
	'Certified member',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
--created prior to reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--certified member
AND (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))

UNION ALL

SELECT
	'Event attendee',
	COUNT(DISTINCT(er.cr67a_contact))
FROM dbo.cr67a_eventregistration er 
LEFT JOIN dbo.contact c ON er.cr67a_contact = c.contactid
LEFT JOIN dbo.account a ON c.parentcustomerid = a.accountid 
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
--created within reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--event attendee
AND (
	UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
);

/*
	Existing businesses
*/

SELECT
	'Number of existing Indigenous businesses registered with the Hub' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
--created prior to reporting period
WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--registered with the Hub
AND (
	--hub asset 
	(a3.relationshiptype = 3 AND a4.nonmembersubcategory =1)
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
);

/*
	Breakdown by Address Region
*/

SELECT
		CASE WHEN map.value >= 7 THEN 'None' ELSE map.label END AS 'Address region',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 3 AND data.nonmembersubcategory = 1) THEN data.id END) AS 'Hub asset',
		COUNT(DISTINCT CASE WHEN (
			(data.relationshiptype = 3 AND data.nonmembersubcategory = 3) 
			OR (data.leadtype IN (3,5) AND data.leadstatus = 0)
		) THEN data.id END) as 'Hub service',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 1 and data.accountstatus IN (4, 5, 9, 11, 12)) THEN data.id END) AS 'Certified members',
		COUNT(DISTINCT CASE WHEN (
			(UPPER(data.eventname) NOT LIKE '%BBA%'
			AND UPPER(data.eventname) NOT LIKE '%Blak Business Awards%'
			AND UPPER(data.eventname) NOT LIKE '%AEDF%'
			AND UPPER(data.eventname) NOT LIKE '%Aboriginal Economic Development Forum%')
		) THEN data.id END) AS 'Event attendees'
	FROM
	(
		SELECT 1 AS value, 'Barkly' AS label UNION ALL
		SELECT 2, 'Big Rivers' UNION ALL
		SELECT 3, 'Central Australia' UNION ALL
		SELECT 4, 'Darwin' UNION ALL
		SELECT 5, 'East Arnhem' UNION ALL
		SELECT 6, 'Top End' UNION ALL
		SELECT 7, 'None' 
	) map
	LEFT JOIN 
	(
		SELECT 
			a.accountid AS id,
			a3.relationshiptype AS relationshiptype,
			a4.nonmembersubcategory AS nonmembersubcategory,
			l.socoro_leadtype AS leadtype,
			l.statecode AS leadstatus,
			cr67a_accountstatus AS accountstatus,
			e.cr67a_eventname AS eventname,
			COALESCE(c.socoro_northernterritoryregion, a.socoro_northernterritoryregion) AS region
		FROM dbo.account a 
			LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
				ON a.accountid = a2.accountid
			LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
				ON a.accountid = a3.accountid
			LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
				ON a.accountid = a4.accountid
			LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
			LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
			LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
			LEFT JOIN lead l ON a.accountid = l.parentaccountid
		WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
				--account active
				AND a.statecode = 0
				--indigenous business
				AND (
					--certified by NTIBN, certification level is 100% or majority
					(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
					--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
					OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
					--certified by is none, self identified is yes
					OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
				) 
	) data ON map.value = data.region
GROUP BY map.value,map.label 
ORDER BY map.value



/*
	Breakdown of new businesses
*/

SELECT
	'Hub asset' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub asset client
AND (a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)

UNION ALL

SELECT
	'Hub service',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--hub service client
AND (
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
		OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
)

UNION ALL

SELECT
	'Certified member',
	COUNT(DISTINCT(a.accountid))
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--certified member
AND (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))

UNION ALL

SELECT
	'Event attendee',
	COUNT(DISTINCT(er.cr67a_contact))
FROM dbo.cr67a_eventregistration er 
LEFT JOIN dbo.contact c ON er.cr67a_contact = c.contactid
LEFT JOIN dbo.account a ON c.parentcustomerid = a.accountid 
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--event attendee
AND (
	UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
	AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
);

/*
	New businesses
*/

SELECT
	'Number of new Indigenous businesses registered with the Hub' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT Join dbo.lead l on a.accountid = l.parentaccountid
--created within reporting period
WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--account active
AND a.statecode = 0
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)
--registered with the Hub
AND (
	--hub asset 
	(a3.relationshiptype = 3 AND a4.nonmembersubcategory =1)
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
);

/*
	Breakdown by Address Region
*/


SELECT
		CASE WHEN map.value >= 7 THEN 'None' ELSE map.label END AS 'Address region',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 3 AND data.nonmembersubcategory = 1) THEN data.id END) AS 'Hub asset',
		COUNT(DISTINCT CASE WHEN (
			(data.relationshiptype = 3 AND data.nonmembersubcategory = 3) 
			OR (data.leadtype IN (3,5) AND data.leadstatus = 0)
		) THEN data.id END) as 'Hub service',
		COUNT(DISTINCT CASE WHEN (data.relationshiptype = 1 and data.accountstatus IN (4, 5, 9, 11, 12)) THEN data.id END) AS 'Certified members',
		COUNT(DISTINCT CASE WHEN (
			(UPPER(data.eventname) NOT LIKE '%BBA%'
			AND UPPER(data.eventname) NOT LIKE '%Blak Business Awards%'
			AND UPPER(data.eventname) NOT LIKE '%AEDF%'
			AND UPPER(data.eventname) NOT LIKE '%Aboriginal Economic Development Forum%')
		) THEN data.id END) AS 'Event attendees'
	FROM
	(
		SELECT 1 AS value, 'Barkly' AS label UNION ALL
		SELECT 2, 'Big Rivers' UNION ALL
		SELECT 3, 'Central Australia' UNION ALL
		SELECT 4, 'Darwin' UNION ALL
		SELECT 5, 'East Arnhem' UNION ALL
		SELECT 6, 'Top End' UNION ALL
		SELECT 7, 'None' 
	) map
	LEFT JOIN 
	(
		SELECT 
			a.accountid AS id,
			a3.relationshiptype AS relationshiptype,
			a4.nonmembersubcategory AS nonmembersubcategory,
			l.socoro_leadtype AS leadtype,
			l.statecode AS leadstatus,
			cr67a_accountstatus AS accountstatus,
			e.cr67a_eventname AS eventname,
			COALESCE(c.socoro_northernterritoryregion, a.socoro_northernterritoryregion) AS region
		FROM dbo.account a 
			LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
				ON a.accountid = a2.accountid
			LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
				ON a.accountid = a3.accountid
			LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
				ON a.accountid = a4.accountid
			LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
			LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
			LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
			LEFT JOIN lead l ON a.accountid = l.parentaccountid
		WHERE a.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
				--account active
				AND a.statecode = 0
				--indigenous business
				AND (
					--certified by NTIBN, certification level is 100% or majority
					(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
					--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
					OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
					--certified by is none, self identified is yes
					OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
				) 
	) data ON map.value = data.region
GROUP BY map.value,map.label 
ORDER BY map.value



/*
	Emerging entrepreneurs
*/

SELECT
	'Number of emerging entrepreneurs registered with the Hub' AS Measurement,
	COUNT(DISTINCT(s.socoro_shareholderid)) AS Result
FROM dbo.socoro_shareholder s
LEFT JOIN dbo.account a ON s.socoro_account = a.accountid
LEFT JOIN dbo.contact c ON c.emailaddress1 = s.socoro_email
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
--created within reporting period
WHERE s.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND s.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--contact active
AND s.statecode = 0
--account start date within 2 years
AND YEAR(a.cr67a_accountstartdate) >= YEAR(GETDATE()) - 2

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

/*
	Breakdown by Address Region
*/
SELECT 
	map.label AS 'ADDRESS REGION',
	COUNT(DISTINCT(data.id)) AS 'EMERGING ENTREPRENEURS '
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
	s.socoro_shareholderid as id,
	COALESCE(c.socoro_northernterritoryregion, a.socoro_northernterritoryregion) AS region

FROM dbo.socoro_shareholder s
LEFT JOIN dbo.account a ON s.socoro_account = a.accountid
LEFT JOIN dbo.contact c ON c.emailaddress1 = s.socoro_email
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
LEFT JOIN lead l ON a.accountid = l.parentaccountid


--created within reporting period
WHERE s.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND s.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--contact active
AND s.statecode = 0
--account start date within 2 years
AND YEAR(a.cr67a_accountstartdate) >= YEAR(GETDATE()) - 2

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
))data 
ON map.value = data.region
GROUP BY map.value,map.label
ORDER BY map.value