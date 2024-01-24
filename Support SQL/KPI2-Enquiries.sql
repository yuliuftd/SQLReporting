/*
	2.1 Enquiry response time
*/

SELECT
	DISTINCT(i.ticketnumber) as 'Ticket Number',
	i.title as 'Case Title',
	CASE 
		WHEN DATEDIFF(day, i.createdon, ISNULL(ir.actualend, (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))) < 1 THEN 1
        ELSE DATEDIFF(day, i.createdon, ISNULL(ir.actualend, (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))) END AS 'Response days',
	i.createdon as 'Created ON',
	ir.actualend as 'Solved Date',
	i.statecodename as 'Status',
	ISNULL(c.fullname,'--') as 'Contact',
	ISNULL(a.name,'--') as 'Account',
	i.caseorigincodename as Origin,
	i.socoro_enquirytypename AS 'Enquiry type',
	u.fullname as 'Owner',
	u.socoro_locationname as 'Location'
FROM dbo.incident i
	LEFT JOIN dbo.incidentresolution ir ON i.incidentid = ir.incidentid
	LEFT JOIN dbo.systemuser u ON i.ownerid = u.systemuserid
	LEFT JOIN account a ON i.socoro_account = a.accountid
	LEFT JOIN contact c on i.contactid = c.contactid
	--received within reporting period
WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	AND (i.title IS NOT NULL OR i.ticketnumber IS NOT NULL)
ORDER BY 3 DESC;


