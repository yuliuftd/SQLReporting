SELECT
	'Number of Open Referred Specialist Leads' as Measurement,
	COUNT(l.leadid) as Result
FROM dbo.lead l
--lead created prior to reporting period and lead open
WHERE l.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND l.statecode = 0
--referral
AND l.socoro_leadtype = 3

UNION ALL

SELECT
	'Number of Free Service Leads',
	COUNT(l.leadid)
FROM dbo.lead l
--lead created prior to reporting period and lead open
WHERE l.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND l.statecode = 0
--in-house and gov
AND l.socoro_leadtype = 5

UNION ALL

SELECT
	'Number of Employment Service Leads',
	COUNT(l.leadid)
FROM dbo.lead l
--lead created prior to reporting period and lead open
WHERE l.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE') AND l.statecode = 0
--Employment
AND l.socoro_leadtype = 6;