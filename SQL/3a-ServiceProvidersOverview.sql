/*
	Service providers over the reporting period
*/

SELECT
	'Indigenous' AS 'Service provider type',
	COUNT(DISTINCT(hs.socoro_serviceprovider)) AS 'Engaged',
	FORMAT(ISNULL(SUM(hs.socoro_costofservice), 0), 'C') AS 'Total cost'
FROM dbo.cr67a_hubservice hs
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
LEFT JOIN dbo.opportunity o ON o.opportunityid = hs.socoro_opportunity
--service created within reporting period or prior to reporting period but oppty is open
WHERE (
	(
		hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	OR (
		hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0
	)
)
--hub service is active 
AND hs.statecode = 0
-- link to opportunity
AND hs.socoro_opportunity is not null
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)

UNION ALL

SELECT
	'Non-indigenous' AS 'Service provider type',
	COUNT(DISTINCT(hs.socoro_serviceprovider)) AS 'Engaged',
	FORMAT(ISNULL(SUM(hs.socoro_costofservice), 0), 'C') AS 'Total cost'
FROM dbo.cr67a_hubservice hs
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
LEFT JOIN dbo.opportunity o ON o.opportunityid = hs.socoro_opportunity
--service created within reporting period or prior to reporting period but oppty is open
WHERE (
	(
		hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	OR (
		hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND o.statecode = 0
	)
)
--non-indigenous business
AND (
	--certified by NTIBN, certification level is 50/50 or registered/ally
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380002', '977380003'))
	--certified by Supply Nation or other body, certification level is registered/ally
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel = '977380002')
	--certified by is none, self identified is no
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
);



/*
	Service providers over the contract period
*/

SELECT
	'Indigenous' AS 'Service provider type',
	COUNT(DISTINCT(hs.socoro_serviceprovider)) AS 'Engaged',
	FORMAT(ISNULL(SUM(hs.socoro_costofservice), 0), 'C') AS 'Total cost'
FROM dbo.cr67a_hubservice hs
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
--service created between start of contract period and end of current quarter
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--indigenous business
AND (
	--certified by NTIBN, certification level is 100% or majority
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
	--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
	--certified by is none, self identified is yes
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
)

UNION ALL

SELECT
	'Non-indigenous' AS 'Service provider type',
	COUNT(DISTINCT(hs.socoro_serviceprovider)) AS 'Engaged',
	FORMAT(ISNULL(SUM(hs.socoro_costofservice), 0), 'C') AS 'Total cost'
FROM dbo.cr67a_hubservice hs
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
--service created between start of contract period and end of current quarter
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--non-indigenous business
AND (
	--certified by NTIBN, certification level is 50/50 or registered/ally
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380002', '977380003'))
	--certified by Supply Nation or other body, certification level is registered/ally
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel = '977380002')
	--certified by is none, self identified is no
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
);



/*
	Number of stakeholders engaged
*/

SELECT
	'Engaged in reporting period' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_asset ab ON a.accountid = ab.cr67a_account
LEFT JOIN dbo.lead l ON a.accountid = l.parentaccountid
LEFT JOIN dbo.cr67a_hubservice hs ON a.accountid = hs.socoro_serviceprovider
LEFT JOIN dbo.activitypointer ap ON a.accountid = ap.regardingobjectid
LEFT JOIN dbo.incident i ON a.accountid = i.socoro_account
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
--stakeholder
WHERE (
	--certified by is none, self identified is no
	(a2.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
	--partner
	OR (a3.relationshiptype = 7)
	--employment support service provider
	OR (a3.relationshiptype = 4 AND a4.servicepackage = 2)
	--ally member
	OR (a3.relationshiptype = 2)
)
--engaged within reporting period
AND (
	--asset entry
	(
		ab.cr67a_account IS NOT NULL
		AND ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	--lead or opportunity
	OR (
		l.parentaccountid IS NOT NULL
		AND l.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND l.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	--service provider in a service planning entry
	OR (
		hs.socoro_serviceprovider IS NOT NULL
		AND hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	--timeline entry
	OR (
		ap.regardingobjectid IS NOT NULL
		AND ap.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND ap.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	--enquiry or complaint case
	OR (
		i.socoro_account IS NOT NULL
		AND i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	--event registration
	OR (
		er.cr67a_account IS NOT NULL
		AND er.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND er.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
)

UNION ALL

SELECT
	'Cumulative total',
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_asset ab ON a.accountid = ab.cr67a_account
LEFT JOIN dbo.lead l ON a.accountid = l.parentaccountid
LEFT JOIN dbo.cr67a_hubservice hs ON a.accountid = hs.socoro_serviceprovider
LEFT JOIN dbo.activitypointer ap ON a.accountid = ap.regardingobjectid
LEFT JOIN dbo.incident i ON a.accountid = i.socoro_account
LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
--stakeholder
WHERE (
	--certified by is none, self identified is no
	(a2.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
	--partner
	OR (a3.relationshiptype = 7)
	--employment support service provider
	OR (a3.relationshiptype = 4 AND a4.servicepackage = 2)
	--ally member
	OR (a3.relationshiptype = 2)
)
--engaged within contract period
AND (
	--asset entry
	(
		ab.cr67a_account IS NOT NULL
		AND ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
	--lead or opportunity
	OR (
		l.parentaccountid IS NOT NULL
		AND l.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND l.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
	--service provider in a service planning entry
	OR (
		hs.socoro_serviceprovider IS NOT NULL
		AND hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
	--timeline entry
	OR (
		ap.regardingobjectid IS NOT NULL
		AND ap.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND ap.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
	--enquiry or complaint case
	OR (
		i.socoro_account IS NOT NULL
		AND i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
	--event registration
	OR (
		er.cr67a_account IS NOT NULL
		AND er.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
		AND er.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_END_DATE')
	)
);