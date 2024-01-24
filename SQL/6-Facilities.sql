SELECT
	map.label AS Location,
	COUNT(DISTINCT(data.account)) AS 'Number of businesses using facilities',
	COUNT(DISTINCT(data.booking)) AS 'Total bookings'
FROM
(
	SELECT 'Darwin' AS label, 1 AS value UNION ALL
	SELECT 'Alice Springs', 2 UNION ALL
	SELECT 'Katherine', 3
) map
LEFT JOIN dbo.socoro_asset ast ON map.value = ast.socoro_location
LEFT JOIN
(
	SELECT
		socoro_asset AS id,
		cr67a_account AS account,
		cr67a_assetid AS booking,
		socoro_bookingstatus AS status
	FROM dbo.cr67a_asset ab
	--booked within reporting period
	WHERE cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
	AND cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--exclude book whole hub
	AND ab.socoro_bookwholehub = 0
	--booking confirmed or completed
	AND ab.socoro_bookingstatus <> 2
) data
ON data.id = ast.socoro_assetid

GROUP BY map.label, map.value
ORDER BY map.value;



/*
	Breakdown by number of bookings and utilisation rate
*/
-- store variables : total working hours of current quarter, number of rooms for each type
DECLARE @TotalWorkingHours INT, @HotDesk INT , @Boardroom INT, @Meetingroom INT;
SELECT @TotalWorkingHours = cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_ASSET_UTILIZATION';
SELECT @HotDesk = Count(socoro_type) FROM dbo.socoro_asset WHERE socoro_type = '977380001';
SELECT @Boardroom = Count(socoro_type) FROM dbo.socoro_asset WHERE socoro_type = '977380000' AND socoro_name LIKE '%Boardroom%';
SELECT @Meetingroom = Count(socoro_type) FROM dbo.socoro_asset WHERE socoro_type = '977380000' AND socoro_name NOT LIKE '%Boardroom%';

SELECT
	'Number of hot desk bookings and utilisation %' AS Measurement,
	COUNT(DISTINCT(ab.cr67a_assetid)) AS '# of bookings',
	FORMAT(
		SUM(
			DATEDIFF(second, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)
		/ 3600.0)
	/ @TotalWorkingHours / @HotDesk, 'P') AS 'Utilisation Rate %'
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
--exclude book whole hub
AND ab.socoro_bookwholehub = 0
--hot desk
AND ast.socoro_type = '977380001'

UNION ALL

SELECT
	'Number of boardroom bookings and utilisation %',
	COUNT(DISTINCT(ab.cr67a_assetid)),
	FORMAT(
		SUM(
			DATEDIFF(second, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)
		/ 3600.0)
	/ @TotalWorkingHours / @Boardroom, 'P')
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
--exclude book whole hub
AND ab.socoro_bookwholehub = 0
--boardroom
AND ast.socoro_type = '977380000' AND ast.socoro_name LIKE '%Boardroom%'

UNION ALL

SELECT
	'Number of meeting room bookings and utilisation %',
	COUNT(DISTINCT(ab.cr67a_assetid)),
	FORMAT(
		SUM(
			DATEDIFF(second, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)
		/ 3600.0)
	/ @TotalWorkingHours / @Meetingroom , 'P')
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
--exclude book whole hub
AND ab.socoro_bookwholehub = 0
--meeting room
AND ast.socoro_type = '977380000' AND ast.socoro_name NOT LIKE '%Boardroom%'

UNION ALL

SELECT
	'Number of whole hub bookings and utilisation %',
	COUNT(DISTINCT(ab.cr67a_assetid)),
	FORMAT(
		SUM(
			DATEDIFF(second, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)
		/ 3600.0)
		--Do not need to divide by room numbers for whole hub booking
	/ @TotalWorkingHours, 'P')
FROM dbo.cr67a_asset ab
LEFT JOIN dbo.socoro_asset ast ON ab.socoro_asset = ast.socoro_assetid
--booked within reporting period
WHERE ab.cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND ab.cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND ab.socoro_bookingstatus <> 2
--whole hub
AND ab.socoro_bookwholehub = 1;