/*
	5.1 Satisfaction with Hub
*/

SELECT
	CAST(qr.msfp_response AS INT) AS 'Score',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
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
	qr.msfp_response AS 'Response',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
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
	qr.msfp_response AS 'Response',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
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

--How satisfied are you with the overall service provided by [Service Provider]
SELECT
	CAST(qr.msfp_response AS INT) AS 'Score',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = '328cbd42-0990-ee11-be36-000d3a794d5b'
--question 1 of survey
AND qr.msfp_questionid = '3c8cbd42-0990-ee11-be36-000d3a794d5b';

--How likely are you to recommend [Service Provider] to others based on the service provided?
SELECT
	CAST(qr.msfp_response AS INT) AS 'Score',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = '328cbd42-0990-ee11-be36-000d3a794d5b'
--question 1 of survey
AND qr.msfp_questionid = '08351cb1-dfd1-ed11-a7c7-000d3ae1eec6';

--How much has [Service Provider] service impacted your business operations or growth?
SELECT
	CAST(qr.msfp_response AS INT) AS 'Score',
	sr.msfp_respondent AS 'Respondent Name',
	sr.msfp_respondentemailaddress AS 'Respondent Email',
	FORMAT(si.createdon, 'yyyy-MM-dd') AS 'Response Date'
FROM dbo.msfp_questionresponse qr
LEFT JOIN dbo.msfp_surveyresponse sr ON qr.msfp_surveyresponseid = sr.activityid
LEFT JOIN dbo.msfp_surveyinvite si ON sr.msfp_surveyinviteid = si.activityid
LEFT JOIN dbo.msfp_question q ON qr.msfp_questionid = q.msfp_questionid
LEFT JOIN dbo.msfp_survey s ON q.msfp_survey = s.msfp_surveyid
--survey sent out within reporting period
WHERE si.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND si.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--hub client pulse survey
AND s.msfp_surveyid = '328cbd42-0990-ee11-be36-000d3a794d5b'
--question 1 of survey
AND qr.msfp_questionid = '3d8cbd42-0990-ee11-be36-000d3a794d5b';

/*
	5.3 Complaints
*/
--# of clients in caseload who engaged in complaints process
SELECT
	i.socoro_enquirytypename AS 'Equiry Type',
	a.name AS 'Account Name',
	a.createdon AS 'Account Created Date',
	FORMAT(i.createdon, 'yyyy-MM-dd') AS 'Complaints Date'
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
AND i.socoro_enquirytype = '324330001';