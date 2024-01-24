---- referral specialist client
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
--referred specialist
AND hs.socoro_serviceprovidertype = 2


----Referral services Activities
SELECT
	hs.cr67a_hubserviceid AS 'Hub ID',
	hs.socoro_servicetypename as 'Service Type',
	ISNULL(a.name ,'--') as 'Service Provider',
	ISNULL(hs.socoro_modeofdeliveryname,'--') as 'delivery mode',
	ISNULL(hs.socoro_locationofdeliveryname,'--') as 'location of delivery',
	ISNULL(hs.socoro_fundingtypename,'--') as 'Fund Type',
	FORMAT(ISNULL(hs.socoro_costofservice,0),'N1') as 'Cost',
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
--referred specialist
AND hs.socoro_serviceprovidertype = 2
--Active service
AND hs.statecode = 0
AND hs.socoro_opportunity IS NOT NULL
ORDER BY u.socoro_locationname, hs.createdon DESC 


