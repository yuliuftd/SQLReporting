/*
	Procurement opportunities
*/

SELECT

	DISTINCT(a.accountid) AS Accountid, ISNULL(a.name,'--') AS Stakeholder, ISNULL(co.fullname,'--') as 'Register User',
	CASE a.cr67a_indigenousbusinessengagement 
	WHEN 1 THEN 'YES'
	WHEN 0 THEN 'NO'
	END as 'indigenous business engagement EOI' , r.createdon as ' RFQ Date', r.cr67a_projectname as 'RFQ project Name'
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_rfq r ON a.accountid = r.cr67a_account
LEFT JOIN dbo.contact co ON a.cr67a_owner = co.contactid
--has RFQ within reporting period or indigenous business engagement EOI marked yes
WHERE (
	(
		r.cr67a_account IS NOT NULL
		AND r.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND r.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	)
	OR a.cr67a_indigenousbusinessengagement = 1
)
--account active
AND a.statecode = 0
--stakeholder
AND (
	--certified by is none, self identified is no
	(a2.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
	--partner
	OR (a3.relationshiptype = 7)
	--employment support service provider
	OR (a3.relationshiptype = 4 AND a4.servicepackage = 2)
	--ally member
	OR (a3.relationshiptype = 2)
)
ORDER BY 2



/*
	Employment opportunities
*/



SELECT
	DISTINCT(a.accountid) AS Accountid, ISNULL(a.name,'--') AS Stakeholder, ISNULL(co.fullname,'--') as 'Register User',
	CASE a.socoro_seekingindigenousemployees
	WHEN 1 THEN 'YES'
	WHEN 0 THEN 'NO'
	END as 'seeking indigenous employees' , l.createdon as 'Employment Service Date', l.leadid as leadid
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
LEFT JOIN dbo.contact co ON a.cr67a_owner = co.contactid
--has employment services within reporting period or seeking indigenous employees marked yes
WHERE 
(
	(
		l.parentaccountid IS NOT NULL
		AND l.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
		AND l.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
		AND l.socoro_leadtype = 6
	)
	OR a.socoro_seekingindigenousemployees  = 1
)
--account active
AND a.statecode = 0
--stakeholder
AND (
	--certified by is none, self identified is no
	(a2.certifiedby = '977380003' AND a.socoro_selfidentified = 0)
	--partner
	OR (a3.relationshiptype = 7)
	--employment support service provider
	OR (a3.relationshiptype = 4 AND a4.servicepackage = 2)
	--ally member
	OR (a3.relationshiptype = 2)
)
ORDER BY 2