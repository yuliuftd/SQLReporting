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



/*
	Complaints
*/

SELECT
	i.title AS Complaint,
	ir.subject AS Outcome
FROM dbo.incident i
LEFT JOIN dbo.incidentresolution ir ON i.incidentid = ir.incidentid
--received within reporting period
WHERE i.createdon >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND i.createdon < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--complaint enquiry
AND i.socoro_enquirytype = '324330001';