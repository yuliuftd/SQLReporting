/*
	5.1 Satisfaction with Hub
*/

SELECT
	'On a scale of 1 to 5, how satisfied are you with the services you have received from the Hub in the last six months?' AS 'Survey question',
	COUNT(qr.msfp_questionresponseid) AS '# of responses',
	ISNULL(FORMAT(AVG(CAST(qr.msfp_response AS INT) / 5), 'P'), '--') AS '% of satisfaction'
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = 'f6e5685c-0990-ee11-be36-000d3a794d5b'
--question 1 of survey
AND qr.msfp_questionid = 'f7e5685c-0990-ee11-be36-000d3a794d5b';



SELECT
	qr.msfp_response
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = 'f6e5685c-0990-ee11-be36-000d3a794d5b'
--question 2 of survey
AND qr.msfp_questionid = 'f8e5685c-0990-ee11-be36-000d3a794d5b'
ORDER BY sr.createdon;



SELECT
	qr.msfp_response
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = 'f6e5685c-0990-ee11-be36-000d3a794d5b'
--question 3 of survey
AND qr.msfp_questionid = 'f9e5685c-0990-ee11-be36-000d3a794d5b'
ORDER BY sr.createdon;



/*
	5.2 Satisfaction with external service providers
*/

SELECT
	map.label AS 'Survey question',
	COUNT(data.id) AS '# of responses',
	ISNULL(FORMAT(AVG(CAST(data.msfp_response AS INT) / 5), 'P'), '--') AS '% of satisfaction'
FROM
(
	SELECT
		10 AS sort,
		'How satisfied are you with the overall service provided by [Service Provider]?' AS label,
		'3c8cbd42-0990-ee11-be36-000d3a794d5b' AS value
	UNION ALL
	SELECT
		20,
		'How likely are you to recommend [Service Provider] to others based on the service provided?',
		'3b8cbd42-0990-ee11-be36-000d3a794d5b'
	UNION ALL
	SELECT
		30,
		'How much has [Service Provider] service impacted your business operations or growth?',
		'3d8cbd42-0990-ee11-be36-000d3a794d5b'
) map
LEFT JOIN
(
	SELECT
		qr.msfp_questionresponseid AS id,
		qr.msfp_questionid,
		qr.msfp_response
	FROM dbo.msfp_questionresponse qr
	LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
	LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
	LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
	LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
	--survey sent out within reporting period
	WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--service provision feedback survey
	AND s.msfp_surveyid = '328cbd42-0990-ee11-be36-000d3a794d5b'
) data
ON map.value = data.msfp_questionid
GROUP BY map.sort, map.label, map.value
ORDER BY map.sort;



/*
	5.3 Complaints
*/

SELECT
	'# of clients in caseload' AS Measurement,
	CAST(COUNT(DISTINCT(a.accountid)) AS VARCHAR) AS Result
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
--account created prior to next reporting period
WHERE a.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
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
	OR (a3.relationshiptype = 1 and a.cr67a_accountstatus != '977380004')
	--event attendee
	OR (
		UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
	)
)

UNION ALL

SELECT
	'# of clients in caseload who engaged in complaints process',
	CAST(COUNT(DISTINCT a.accountid) AS VARCHAR)
FROM dbo.account a
LEFT JOIN dbo.incident i ON a.accountid = i.socoro_account
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
--account created prior to next reporting period
WHERE a.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
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
	OR (a3.relationshiptype = 1 and a.cr67a_accountstatus != '977380004')
	--event attendee
	OR (
		UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
	)
)
--engaged in complaints process during 12-month period
AND i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'COMPLAINT_PERIOD_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
AND i.socoro_enquirytype = '324330001'

UNION ALL

SELECT
	'% of caseload who engaged in complaints process',
	CAST(
		FORMAT(
			COUNT(DISTINCT CASE WHEN
				i.createdon >= cpstart.cr67a_value
				AND i.createdon < qend.cr67a_value
				AND i.socoro_enquirytype = '324330001'
			THEN a.accountid ELSE NULL END) * 1.0
			/ COUNT(DISTINCT(a.accountid))
		, 'P')
	AS VARCHAR)
FROM dbo.account a
LEFT JOIN dbo.incident i ON a.accountid = i.socoro_account
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
INNER JOIN dbo.cr67a_configuration cpstart ON cpstart.cr67a_variable = 'COMPLAINT_PERIOD_START_DATE'
INNER JOIN dbo.cr67a_configuration qend ON qend.cr67a_variable = 'QUARTER_END_DATE'
--account created prior to next reporting period
WHERE a.createdon < qend.cr67a_value
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
		OR (l.socoro_leadtype IN (3, 5) AND l.statecode = 0)
	)
	--certified member
	OR (a3.relationshiptype = 1 and a.cr67a_accountstatus != '977380004')
	--event attendee
	OR (
		UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
		AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
	)
);


/*
	5.4 Complaint resolution
*/

SELECT
	ROW_NUMBER() OVER (ORDER BY i.createdon) AS '#',
	i.socoro_productservicename AS 'Nature of complaint',
	FORMAT(i.createdon, 'yyyy-MM-dd') AS 'Reported',
	i.statecodename AS 'Status'
FROM dbo.incident i
--created within reporting period
WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--complaint
AND i.socoro_enquirytype = '324330001';


SELECT
	i.socoro_productservicename AS 'Nature of complaint',
	COUNT(i.incidentid) AS 'Number of Complaints'
	--ir.subject AS 'Resolution of complaint',
	--i.incidentstagecode AS 'Status'
FROM dbo.incident i
LEFT JOIN dbo.incidentresolution ir ON i.incidentid = ir.incidentid
--created within reporting period
WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--complaint
AND i.socoro_enquirytype = '324330001'
GROUP BY i.socoro_productservicename;