/*
	Procurement opportunities
*/

SELECT
	'Number of engagements with stakeholders to generate procurement opportunities for Indigenous job seekers' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN dbo.cr67a_rfq r ON a.accountid = r.cr67a_account
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
);




/*
	Employment opportunities
*/

SELECT
	'Number of engagements with stakeholders to generate employment opportunities for Indigenous job seekers' AS Measurement,
	COUNT(DISTINCT(a.accountid)) AS Result
FROM dbo.account a
LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
	ON a.accountid = a2.accountid
LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
	ON a.accountid = a3.accountid
LEFT JOIN (SELECT accountid, value AS servicepackage FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_servicepackage, ',')) a4
	ON a.accountid = a4.accountid
LEFT JOIN lead l ON a.accountid = l.parentaccountid
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
);