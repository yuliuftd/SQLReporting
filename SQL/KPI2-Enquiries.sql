/*
	2.1 Enquiry response time
*/

SELECT
	map.label AS 'Enquiry type',
	COUNT(DISTINCT(data.id)) AS 'Total enquiries',
	CASE
		WHEN AVG(lifetime) >= 1 THEN CAST(AVG(lifetime) AS varchar)
		WHEN AVG(lifetime) < 1 THEN 'Less than one day'
		ELSE '--'
	END AS 'Avg response time in days'
FROM
(
	SELECT 'Phone calls' AS label, 1 AS value UNION ALL
	SELECT 'Emails to Hub mailbox', 2 UNION ALL
	SELECT 'Website', 3 UNION ALL
	SELECT 'Social media', 4 UNION ALL
	SELECT 'Walk-in', 5
) map
LEFT JOIN
(
	SELECT
		i.incidentid AS id,
		i.caseorigincode,
		DATEDIFF(day, i.createdon, ISNULL(ir.actualend, (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE'))) AS lifetime
	FROM dbo.incident i
	LEFT JOIN dbo.incidentresolution ir ON i.incidentid = ir.incidentid
	--received within reporting period
	WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
) data
ON map.value = data.caseorigincode
GROUP BY map.label, map.value
ORDER BY map.value;



/*
	2.2 Number and nature of enquiries received
*/

/*
	Number and nature of enquiries received
*/

SELECT
	map.label AS 'Nature of enquiry',
	SUM(CASE WHEN u.socoro_location = 1 THEN 1 ELSE 0 END) AS 'Darwin',
	SUM(CASE WHEN u.socoro_location = 2 THEN 1 ELSE 0 END) AS 'Alice Springs',
	SUM(CASE WHEN u.socoro_location = 3 THEN 1 ELSE 0 END) AS 'Katherine'
FROM
(
	SELECT 'Membership enquiry' AS label, '324330000' AS value UNION ALL
	SELECT 'Complaint enquiry' AS label, '324330001' AS value UNION ALL
	SELECT 'Subscription enquiry', '324330002' UNION ALL
	SELECT 'Hub service enquiry', '324330003' UNION ALL
	SELECT 'Hub service provider enquiry', '324330004' UNION ALL
	SELECT 'Investor enquiry', '324330005' UNION ALL
	SELECT 'Partner enquiry', '324330007' UNION ALL
	SELECT 'Other enquiry', '324330008'
) map
LEFT JOIN
(
	SELECT
		incidentid AS id,
		socoro_enquirytype AS enquirytype,
		ownerid
	FROM dbo.incident
	--received within reporting period
	WHERE createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
) data
ON map.value = data.enquirytype
LEFT JOIN dbo.systemuser u ON data.ownerid = u.systemuserid
GROUP BY map.label, map.value
ORDER BY map.value;