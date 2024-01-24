SELECT
	Case 
		WHEN room.socoro_type = '977380001' THEN 'Hot Dest Booking' 
		WHEN room.socoro_type = '977380000' AND room.socoro_name LIKE '%Boardroom%' THEN 'Boardroom Booking' 
		WHEN room.socoro_type = '977380000' AND room.socoro_name NOT LIKE '%Boardroom%' THEN 'Meeting Room Booking(exclude Boardroom)'
		WHEN ast.socoro_bookwholehub = 1 THEN 'Whole Hub Booking'
	END AS 'Room Type',
	ISNULL(room.socoro_locationname, '') AS 'Location',
	ISNULL(a.name, '') AS Name,
	ISNULL(c.fullname, '') as ContactName,
	socoro_bookingstatusname AS Status,
	FORMAT(ast.cr67a_bookingdate, 'yyyy-MM-dd') AS 'Booking Date',
	ast.socoro_bookingstarttimename AS 'Start',
	ast.socoro_bookingendtimename AS 'End',
	FORMAT(DATEDIFF(minute, ast.socoro_bookingstarttimename, ast.socoro_bookingendtimename) / 60.0, 'N1') AS 'Hours'
FROM dbo.cr67a_asset ast
LEFT JOIN dbo.socoro_asset room ON room.socoro_assetid = ast.socoro_asset
LEFT JOIN dbo.account a ON a.accountid = ast.cr67a_account
LEFT JOIN dbo.contact c ON c.contactid = ast.cr67a_contact
--booked within reporting period
WHERE cr67a_bookingdate >= (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_START_DATE')
AND cr67a_bookingdate < (select cr67a_value from cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
--booking confirmed or completed
AND (socoro_bookingstatus <> 2)
AND (room.socoro_type = '977380001' OR room.socoro_type = '977380000' OR ast.socoro_bookwholehub = 1)
ORDER BY 'Room Type';


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
	COUNT(DISTINCT(ab.cr67a_assetid)) AS 'Number of bookings',
	FORMAT(SUM(DATEDIFF(minute, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)) / 60.0 , 'N1') AS 'Total hours',
	@HotDesk AS 'Number of Rooms',
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
	FORMAT(SUM(DATEDIFF(minute, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)) / 60.0 , 'N1') AS 'Total hours',
	@Boardroom,
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
	FORMAT(SUM(DATEDIFF(minute, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)) / 60.0 , 'N1') AS 'Total hours',
	@Meetingroom,
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
	FORMAT(SUM(DATEDIFF(minute, ab.socoro_bookingstarttimename, ab.socoro_bookingendtimename)) / 60.0 , 'N1') AS 'Total hours',
	(select COUNT(*) from socoro_asset),
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