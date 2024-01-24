/*
	Number and nature of enquiries received
*/

SELECT DISTINCT
i.socoro_enquirytypename AS 'Nature of enquiry',
u.socoro_locationname AS 'Location',
i.ticketnumber AS 'Ticket Number',
i.title AS 'Title',
caseorigincodename AS 'Case Origin',
FORMAT(i.createdon, 'yyyy-MM-dd') AS 'Created On'
FROM dbo.incident i
LEFT JOIN dbo.systemuser u ON i.ownerid = u.systemuserid
--received within reporting period
WHERE (i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
AND (i.title IS NOT NULL OR i.ticketnumber IS NOT NULL)
ORDER BY 'Nature of enquiry' ASC, 'Location' ASC;

/*
	Complaints
*/

SELECT
	i.title AS Complaint,
	i.ticketnumber AS CaseNumber,
--	i.incidentid AS id,
	i.title AS Title,
	ir.subject AS Outcome,
--	ir.activityid AS rid
	i.createdon AS Createdon
FROM dbo.incident i
LEFT JOIN dbo.incidentresolution ir ON i.incidentid = ir.incidentid
--received within reporting period
WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--complaint enquiry
AND i.socoro_enquirytype = '324330001';