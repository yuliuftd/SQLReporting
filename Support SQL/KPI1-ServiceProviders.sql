

/*
	1.2 Minimum of 20 referrals in and out of the hub
*/

SELECT
	distinct(hs.cr67a_hubserviceid) AS 'HUb Service ID',
	a.name AS 'Service Provider',  socoro_servicetypename AS 'Services', 
	hs.createdon as 'Created Date',o.statecodename as 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN account a ON hs.socoro_serviceprovider =a.accountid
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
AND socoro_opportunity IS NOT NULL
--referred specialist
AND hs.socoro_serviceprovidertype = 2
ORDER BY 4 DESC;



/*
	1.2 Minimum of 20 referrals in and out of the hub
*/

SELECT
	distinct(hs.cr67a_hubserviceid) AS 'HUb Service ID',
	a.name AS 'Service Provider',  socoro_servicetypename AS 'Services', 
	hs.createdon as 'Created Date',o.statecodename as 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN account a ON hs.socoro_serviceprovider =a.accountid
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
AND socoro_opportunity IS NOT NULL
--Commonwealth 
AND hs.socoro_serviceprovidertype = 3
ORDER BY 4 DESC;




/*
	1.2 Minimum of 20 referrals in and out of the hub
*/

SELECT
	distinct(hs.cr67a_hubserviceid) AS 'HUb Service ID',
	a.name AS 'Service Provider',  socoro_servicetypename AS 'Services', 
	hs.createdon as 'Created Date',o.statecodename as 'Opportunity Status'
FROM dbo.cr67a_hubservice hs
LEFT JOIN dbo.opportunity o ON hs.socoro_opportunity = o.opportunityid
LEFT JOIN account a ON hs.socoro_serviceprovider =a.accountid
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
AND socoro_opportunity IS NOT NULL
--NTG
AND hs.socoro_serviceprovidertype = 4
ORDER BY 4 DESC;
