/*
	Service providers over the reporting period-Indigenous
*/



SELECT
	a.name as 'Service Provider', 
	ISNULL(c.fullname,'--') as 'Client',
	ISNULL(acc.name,'--') as 'Account',
    CASE hs.socoro_servicetype
        WHEN 1 THEN 'Mentor / coaching'
        WHEN 2 THEN 'Business planning'
        WHEN 3 THEN 'Business in a box'
        WHEN 4 THEN 'Document library'
        WHEN 5 THEN 'Ideation / incubation'
        WHEN 6 THEN 'Business concierge'
        WHEN 7 THEN 'Policy development'
        WHEN 8 THEN 'Networking & connecting opportunities'
        WHEN 24 THEN 'Support letter'
        WHEN 10 THEN 'Grant writing'
        WHEN 11 THEN 'Tender writing'
        WHEN 12 THEN 'Financial feasibility'
        WHEN 13 THEN 'Financial management'
        WHEN 14 THEN 'HR services'
        WHEN 25 THEN 'Legal services'
        WHEN 15 THEN 'Website development'
        WHEN 16 THEN 'Systems development'
        WHEN 17 THEN 'JV/partnership support'
        WHEN 18 THEN 'Risk management'
        WHEN 19 THEN 'Crisis management'
        WHEN 20 THEN 'Ecommerce services'
        WHEN 21 THEN 'Export services'
        WHEN 22 THEN 'Marketing and social media'
        WHEN 23 THEN 'Back-of-house support'
    END AS 'Services', FORMAT(ISNULL(hs.socoro_costofservice, 0),'N1') as 'Cost', hs. createdon as 'Created On', hs.socoro_opportunity as OpportunityID, 
	CASE o.statecode
	WHEN 0 THEN 'Open'
	WHEN 1 THEN 'Won'
	WHEN 2 THEN 'Lost' END AS 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account acc ON hs.socoro_account = acc.accountid
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified,
		name
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
ORDER BY 1 ASC


/*
	Service providers over the reporting period - non-Indigenous
*/



SELECT
	a.name as 'Service Provider', 
	ISNULL(c.fullname,'--') as 'Client',
	ISNULL(acc.name,'--') as 'Account',
    CASE hs.socoro_servicetype
        WHEN 1 THEN 'Mentor / coaching'
        WHEN 2 THEN 'Business planning'
        WHEN 3 THEN 'Business in a box'
        WHEN 4 THEN 'Document library'
        WHEN 5 THEN 'Ideation / incubation'
        WHEN 6 THEN 'Business concierge'
        WHEN 7 THEN 'Policy development'
        WHEN 8 THEN 'Networking & connecting opportunities'
        WHEN 24 THEN 'Support letter'
        WHEN 10 THEN 'Grant writing'
        WHEN 11 THEN 'Tender writing'
        WHEN 12 THEN 'Financial feasibility'
        WHEN 13 THEN 'Financial management'
        WHEN 14 THEN 'HR services'
        WHEN 25 THEN 'Legal services'
        WHEN 15 THEN 'Website development'
        WHEN 16 THEN 'Systems development'
        WHEN 17 THEN 'JV/partnership support'
        WHEN 18 THEN 'Risk management'
        WHEN 19 THEN 'Crisis management'
        WHEN 20 THEN 'Ecommerce services'
        WHEN 21 THEN 'Export services'
        WHEN 22 THEN 'Marketing and social media'
        WHEN 23 THEN 'Back-of-house support'
    END AS 'Services', FORMAT(ISNULL(hs.socoro_costofservice, 0),'N1') as 'Cost', hs. createdon as 'Created On', hs.socoro_opportunity as OpportunityID, 
	CASE o.statecode
	WHEN 0 THEN 'Open'
	WHEN 1 THEN 'Won'
	WHEN 2 THEN 'Lost' END AS 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account acc ON hs.socoro_account = acc.accountid
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified,
		name
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
--non-indigenous business
AND (
	--certified by NTIBN, certification level is 50/50 or registered/ally
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380002', '977380003'))
	--certified by Supply Nation or other body, certification level is registered/ally
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel = '977380002')
	--certified by is none, self identified is no
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
)
ORDER BY 1 ASC




/*
	Service providers over the contract period -Indigenous
*/



SELECT
	a.name as 'Service Provider', 
	ISNULL(c.fullname,'--') as 'Client',
	ISNULL(acc.name,'--') as 'Account',
    CASE hs.socoro_servicetype
        WHEN 1 THEN 'Mentor / coaching'
        WHEN 2 THEN 'Business planning'
        WHEN 3 THEN 'Business in a box'
        WHEN 4 THEN 'Document library'
        WHEN 5 THEN 'Ideation / incubation'
        WHEN 6 THEN 'Business concierge'
        WHEN 7 THEN 'Policy development'
        WHEN 8 THEN 'Networking & connecting opportunities'
        WHEN 24 THEN 'Support letter'
        WHEN 10 THEN 'Grant writing'
        WHEN 11 THEN 'Tender writing'
        WHEN 12 THEN 'Financial feasibility'
        WHEN 13 THEN 'Financial management'
        WHEN 14 THEN 'HR services'
        WHEN 25 THEN 'Legal services'
        WHEN 15 THEN 'Website development'
        WHEN 16 THEN 'Systems development'
        WHEN 17 THEN 'JV/partnership support'
        WHEN 18 THEN 'Risk management'
        WHEN 19 THEN 'Crisis management'
        WHEN 20 THEN 'Ecommerce services'
        WHEN 21 THEN 'Export services'
        WHEN 22 THEN 'Marketing and social media'
        WHEN 23 THEN 'Back-of-house support'
    END AS 'Services', FORMAT(ISNULL(hs.socoro_costofservice, 0),'N1') as 'Cost', hs. createdon as 'Created On', hs.socoro_opportunity as OpportunityID, 
	CASE o.statecode
	WHEN 0 THEN 'Open'
	WHEN 1 THEN 'Won'
	WHEN 2 THEN 'Lost' END AS 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account acc ON hs.socoro_account = acc.accountid
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified,
		name
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
LEFT JOIN dbo.opportunity o ON o.opportunityid = hs.socoro_opportunity
--service created between start of contract period and end of current quarter
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
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
ORDER BY 1 ASC


/*
	Service providers over the contract period -non-Indigenous
*/


SELECT
	a.name as 'Service Provider', 
	ISNULL(c.fullname,'--') as 'Client',
	ISNULL(acc.name,'--') as 'Account',
    CASE hs.socoro_servicetype
        WHEN 1 THEN 'Mentor / coaching'
        WHEN 2 THEN 'Business planning'
        WHEN 3 THEN 'Business in a box'
        WHEN 4 THEN 'Document library'
        WHEN 5 THEN 'Ideation / incubation'
        WHEN 6 THEN 'Business concierge'
        WHEN 7 THEN 'Policy development'
        WHEN 8 THEN 'Networking & connecting opportunities'
        WHEN 24 THEN 'Support letter'
        WHEN 10 THEN 'Grant writing'
        WHEN 11 THEN 'Tender writing'
        WHEN 12 THEN 'Financial feasibility'
        WHEN 13 THEN 'Financial management'
        WHEN 14 THEN 'HR services'
        WHEN 25 THEN 'Legal services'
        WHEN 15 THEN 'Website development'
        WHEN 16 THEN 'Systems development'
        WHEN 17 THEN 'JV/partnership support'
        WHEN 18 THEN 'Risk management'
        WHEN 19 THEN 'Crisis management'
        WHEN 20 THEN 'Ecommerce services'
        WHEN 21 THEN 'Export services'
        WHEN 22 THEN 'Marketing and social media'
        WHEN 23 THEN 'Back-of-house support'
    END AS 'Services', FORMAT(ISNULL(hs.socoro_costofservice, 0),'N1') as 'Cost', hs. createdon as 'Created On', hs.socoro_opportunity as OpportunityID, 
	CASE o.statecode
	WHEN 0 THEN 'Open'
	WHEN 1 THEN 'Won'
	WHEN 2 THEN 'Lost' END AS 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account acc ON hs.socoro_account = acc.accountid
LEFT JOIN (
	SELECT
		accountid,
		value AS certifiedby,
		cr67a_certificationlevel,
		socoro_selfidentified,
		name
	FROM dbo.account
	OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')
) a
	ON hs.socoro_serviceprovider = a.accountid
LEFT JOIN dbo.opportunity o ON o.opportunityid = hs.socoro_opportunity
--service created between start of contract period and end of current quarter
WHERE hs.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'CONTRACT_START_DATE')
AND hs.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub service is active 
AND hs.statecode = 0
-- link to opportunity
AND hs.socoro_opportunity is not null
--non-indigenous business
AND (
	--certified by NTIBN, certification level is 50/50 or registered/ally
	(a.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380002', '977380003'))
	--certified by Supply Nation or other body, certification level is registered/ally
	OR (a.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel = '977380002')
	--certified by is none, self identified is no
	OR (a.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
)
ORDER BY 1 ASC



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