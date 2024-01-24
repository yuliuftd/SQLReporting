/*
	Breakdown of total businesses
*/

SELECT DISTINCT
	'Hub asset' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Hub service' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Certified member' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Event attendee' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	c.fullname AS 'Contact'
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
)
ORDER BY 'Account From' DESC, 'Áddress Region' DESC;

/*
	Total businesses
*/
--Number of total Indigenous businesses registered with the Hub
SELECT DISTINCT
	a.name AS 'Name'
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
	Breakdown of existing businesses
*/

SELECT DISTINCT
	'Hub asset' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Hub service' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Certified member' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	'' AS 'Contact'
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

SELECT DISTINCT
	'Event attendee' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	c.fullname AS 'Contact'
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
)
ORDER BY 'Account From' DESC, 'Áddress Region' DESC;

/*
	Existing businesses
*/
--Number of existing Indigenous businesses registered with the Hub

SELECT DISTINCT
	a.name
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
	Breakdown of new businesses
*/

SELECT DISTINCT
	'Hub asset' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region'
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

SELECT DISTINCT
	'Hub service' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region'
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

SELECT DISTINCT
	'Certified member' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region'
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
	'Event attendee' AS 'Account From',
	a.name AS 'Account Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region'
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
)
ORDER BY 'Account From' DESC, 'Address Region' DESC;

/*
	New businesses
*/

SELECT DISTINCT
	a.name
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
	Emerging entrepreneurs
*/

--'Number of emerging entrepreneurs registered with the Hub'
SELECT DISTINCT
	s.socoro_shareholderid AS 'Entrepreneurs id',
	a.name AS 'Account Name',
	ISNULL(s.socoro_firstname + ' ' + s.socoro_lastname, '--') AS 'Shareholder Name',
	ISNULL(a.socoro_northernterritoryregionname, 'None') AS 'Address Region',
	FORMAT(a.cr67a_accountstartdate, 'yyyy-MM-dd') AS 'Account Start Date'
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
ORDER BY 'Address Region';