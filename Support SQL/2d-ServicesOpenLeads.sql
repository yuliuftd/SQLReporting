SELECT
	DISTINCT(l.leadid) as LeadID,
	l.createdon as 'Lead Created On',
	l.socoro_leadtypename as 'Lead Type',
	ISNULL(c.fullname ,'--') as 'Contact',
	ISNULL(a.name,'--') as 'Account'

FROM dbo.lead l
LEFT JOIN account a ON l.parentaccountid = a.accountid
LEFT JOIN contact c ON l.parentcontactid = c.contactid
--lead created prior to reporting period and lead open
WHERE l.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND l.statecode = 0
--referral
AND (l.socoro_leadtype = 3 or l.socoro_leadtype = 5 or l.socoro_leadtype = 6)
ORDER BY l.createdon DESC
