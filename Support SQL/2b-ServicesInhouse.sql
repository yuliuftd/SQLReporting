---- in-house client
SELECT
	DISTINCT(COALESCE(c.contactid,a.accountid, l.leadid)) AS id,
	COALESCE(c.fullname,a.name,l.fullname) AS 'Client',
	ISNULL(COALESCE(c.socoro_northernterritoryregionname, s.socoro_northterritoryregionname, a.socoro_northernterritoryregionname),'None') AS 'Client Region',
	u.socoro_locationname AS 'Hub and satellite location'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN lead l ON o.originatingleadid = l.leadid
LEFT JOIN contact c ON hs.socoro_contact = c.contactid
LEFT JOIN account a ON hs.socoro_account  = a.accountid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN dbo.socoro_shareholder s ON c.emailaddress1 = s.socoro_email
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
--in-house
AND hs.socoro_serviceprovidertype = 1
ORDER BY Client


----in-house Activities
SELECT
	hs.cr67a_hubserviceid AS 'Hub ID',
	hs.socoro_servicetypename as 'Service Type',
	hs.createdon as 'Service Created on',
	o.statecodename as 'Opportunity Status',
	u.socoro_locationname as 'Hub and satellite location'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN dbo.systemuser u ON hs.ownerid = u.systemuserid
LEFT JOIN account a ON hs.socoro_serviceprovider = a.accountid
WHERE (
	--service created within reporting period
	(hs.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))
	--service created prior to reporting period, opportunity open
	OR (hs.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
		AND o.statecode = 0)
)
--in-house
AND hs.socoro_serviceprovidertype = 1
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
ORDER BY u.socoro_locationname, hs.createdon DESC 


---appoingtment
SELECT
socoro_locationname AS Location,
appt.subject,
appt.scheduledstart as Time

FROM dbo.appointment appt
LEFT JOIN dbo.systemuser u ON appt.createdby = u.systemuserid

--appointment falls within reporting period
WHERE appt.scheduledstart >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND appt.scheduledstart < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	AND appt.statecode != 2;

/*
	Breakdown of procure connect activity
*/


SELECT
	r.cr67a_rfqid AS 'RFQ id',
	r.cr67a_projectname as 'Project Name',
	r.cr67a_statusname AS 'Project Status',
	ISNULL(r.cr67a_eoicount,0) AS '# EOIs',
	r.socoro_projectsizename AS 'Project Size'
FROM dbo.cr67a_rfq r
--created within reporting period
WHERE r.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND r.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
AND r.cr67a_status!= 977380002
ORDER BY 'Project Status' DESC,'Project Size' DESC



SELECT 
eoi.cr67a_statusname AS 'EOI Status', eoi.socoro_firstname+' '+eoi.socoro_lastname as 'Full Name', 
eoi.socoro_businessname as 'Business Name',r.cr67a_projectname as 'Project Name'

FROM cr67a_eoi eoi LEFT JOIN dbo.cr67a_rfq r ON eoi.cr67a_rfq = r.cr67a_rfqid
--created within reporting period
WHERE r.createdon >= (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') 
AND r.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
AND r.cr67a_status!= 977380002
AND eoi.cr67a_status !=977380003