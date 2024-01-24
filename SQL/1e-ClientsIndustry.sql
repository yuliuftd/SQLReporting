/*
	Breakdown of indigenous businesses supported by industry
*/

SELECT
	map.label AS industry,
	COUNT(DISTINCT(accounts.id)) AS total
FROM
(
	SELECT 10 AS sort, 'Agriculture, Forestry and Fishing' AS label, 977380000 AS value UNION ALL
	SELECT 20, 'Mining', 977380001 UNION ALL
	SELECT 30, 'Manufacturing', 977380002 UNION ALL
	SELECT 40, 'Electricity, Gas, Water and Waste Services', 977380003 UNION ALL
	SELECT 50, 'Construction', 977380004 UNION ALL
	SELECT 60, 'Wholesale Trade', 977380005 UNION ALL
	SELECT 70, 'Retail Trade', 977380006 UNION ALL
	SELECT 80, 'Accommodation and Food Services', 977380007 UNION ALL
	SELECT 90, 'Transport, Postal and Warehousing', 977380008 UNION ALL
	SELECT 100, 'Information Media and Telecommunications', 977380009 UNION ALL
	SELECT 110, 'Financial and Insurance Services', 977380010 UNION ALL
	SELECT 120, 'Rental Hiring and Real Estate Services', 977380011 UNION ALL
	SELECT 130, 'Professional, Scientific and Technical Services', 977380012 UNION ALL
	SELECT 140, 'Administrative and Support Services', 977380013 UNION ALL
	SELECT 150, 'Public Administration and Safety', 977380014 UNION ALL
	SELECT 160, 'Education and Training', 977380015 UNION ALL
	SELECT 170, 'Health Care and Social Assistance', 977380016 UNION ALL
	SELECT 180, 'Arts and Recreation Services', 977380017 UNION ALL
	SELECT 190, 'Consultancy', 977380019 UNION ALL
	SELECT 200, 'Native Aboriginal Bushfoods and Botanicals', 977380020 UNION ALL
	SELECT 210, 'Aviation', 977380021 
) map
LEFT JOIN
(
	SELECT
		a.accountid AS id,
		a.name,
		a.cr67a_industry AS industryid
	FROM dbo.account a
	LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
		ON a.accountid = a2.accountid
	LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
		ON a.accountid = a3.accountid
	LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
		ON a.accountid = a4.accountid
	LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
	LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
	LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
	LEFT JOIN lead l ON a.accountid = l.parentaccountid
	WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--indigenous business
	AND(
		--certified by NTIBN, certification level is 100% or majority
		(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
		--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
		OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
		--certified by is none, self identified is yes
		OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
	)
	--registered with the Hub
	AND (
		--hub asset / hub service client
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)
		OR (
			(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
			OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
		)
		--certified member
		OR (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))
		--event attendee
		OR (
			UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
		))
) accounts
ON map.value = accounts.industryid
GROUP BY map.sort, map.label, map.value
ORDER BY map.label ASC;



/*
	Number of indigenous community organisations being supported
*/

SELECT
	map.label,
	COUNT(DISTINCT(data.id)) AS total
FROM
(
	SELECT 'Ranger Groups' AS label, 1193 AS subvalue UNION ALL --Rangers and Aboriginal Trade
	SELECT 'Prescribed Body Corporates', 1232 UNION ALL --Traditional Owners & Land Councils
	SELECT 'Prescribed Body Corporates', 1158 UNION ALL --State Government Administration
	SELECT 'Prescribed Body Corporates', 1159 UNION ALL --Local Government Administration
	SELECT 'Prescribed Body Corporates', 1161 UNION ALL --Government Representation
	SELECT 'Prescribed Body Corporates', 1163 UNION ALL --Public Order and Safety Services
	SELECT 'Prescribed Body Corporates', 1157 UNION ALL --Central Government Administration
	SELECT 'Prescribed Body Corporates', 1160 UNION ALL --Justice
	SELECT 'Prescribed Body Corporates', 1162 UNION ALL --Defence
	SELECT 'Prescribed Body Corporates', 1164 UNION ALL --Regulatory Services
	SELECT 'Remote Broadcasters', 1124 UNION ALL --Radio Broadcasting
	SELECT 'Remote Broadcasters', 1125 UNION ALL --Television Broadcasting
	SELECT 'Remote Broadcasters', 1126 UNION ALL --Internet Publishing and Broadcasting
	SELECT 'Creative Industries', 1279 UNION ALL --Aboriginal Arts & craft
	SELECT 'Creative Industries', 1276 UNION ALL --Aboriginal cultural immersion tours
	SELECT 'Creative Industries', 1178 UNION ALL --Creative and Performing Arts Activities
	SELECT 'Creative Industries', 1123 UNION ALL --Sound Recording and Music Publishing
	SELECT 'Creative Industries', 1122 UNION ALL --Motion Picture and Video Activities
	SELECT 'Creative Industries', 1120 UNION ALL --Newspaper, Periodical, Book and Directory Publishing
	SELECT 'Creative Industries', 1282 UNION ALL --Aboriginal homeware product manufacturing
	SELECT 'Creative Industries', 1271 UNION ALL --Arts & craft
	--SELECT 'Art Centres', 0 UNION ALL --Art Centre
	SELECT 'Tourism', 1104 UNION ALL --Accommodation
	SELECT 'Tourism', 1261 UNION ALL --Aboriginal Bush Foods and Botanicals
	SELECT 'Tourism', 1153 UNION ALL --Travel Agency and Tour Arrangement Services
	SELECT 'Tourism', 1279 UNION ALL --Aboriginal Arts & craft
	SELECT 'Tourism', 1276 UNION ALL --Aboriginal cultural immersion tours
	SELECT 'Tourism', 1178 UNION ALL --Creative and Performing Arts Activities
	SELECT 'Tourism', 1182 UNION ALL --Amusement and Other Recreation Activities
	SELECT 'Tourism', 1179 UNION ALL --Sports and Physical Recreation Activities
	SELECT 'Tourism', 1177 UNION ALL --Parks and Gardens Operations
	SELECT 'Tourism', 1176 UNION ALL --Museum Operation
	SELECT 'Tourism', 1194 UNION ALL --Tourism - recreational activities
	SELECT 'Tourism', 1269 UNION ALL --Cultural immersion tours
	SELECT 'Tourism', 1288 UNION ALL --Aboriginal beauty product retailing
	SELECT 'Tourism', 1286 UNION ALL --Aboriginal wellness product retailing
	SELECT 'Tourism', 1283 --Native Aboriginal bushfood and botanicals retailing
	--SELECT 'Community Cooperatives', 0 UNION ALL --Community-Owned retail
	--SELECT 'Community Cooperatives', 0 UNION ALL --Credit Union
	--SELECT 'Community Cooperatives', 0 --Housing Cooperative
) map
LEFT JOIN
(
	SELECT
		a.accountid AS id,
		a.socoro_subindustry AS subindustryid
	FROM dbo.account a
	LEFT JOIN (SELECT accountid, value AS certifiedby FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_certifiedby, ',')) a2
		ON a.accountid = a2.accountid
	LEFT JOIN (SELECT accountid, value AS relationshiptype FROM dbo.account OUTER APPLY STRING_SPLIT(socoro_ntibnrelationshiptype, ',')) a3
		ON a.accountid = a3.accountid
	LEFT JOIN (SELECT accountid, value AS nonmembersubcategory FROM dbo.account OUTER APPLY STRING_SPLIT(cr67a_nonmembersubcategory, ',')) a4
		ON a.accountid = a4.accountid
	LEFT JOIN dbo.contact c ON a.accountid = c.parentcustomerid
	LEFT JOIN dbo.cr67a_eventregistration er ON c.contactid = er.cr67a_contact
	LEFT JOIN dbo.cr67a_event e ON er.cr67a_event = e.cr67a_eventid
	LEFT JOIN lead l ON a.accountid = l.parentaccountid
	WHERE a.createdon < (SELECT cr67a_value FROM cr67a_configuration WHERE cr67a_variable = 'QUARTER_END_DATE')
	--indigenous community organisations
	AND (
		a.businesstypecode = '977380002'
		OR a.businesstypecode = '977380004' AND (
			--certified by NTIBN, certification level is 100% or majority
			(a2.certifiedby = '977380000' AND a.cr67a_certificationlevel IN ('977380000', '977380001'))
			--certified by Supply Nation or other body, certification level is 100%, majority or 50/50
			OR (a2.certifiedby IN ('977380001', '977380002') AND a.cr67a_certificationlevel <> '977380002')
			--certified by is none, self identified is yes
			OR (a2.certifiedby = '977380003' AND a.socoro_selfidentified = 1)
		)
	)
	--registered with the Hub
	AND (
		--hub asset / hub service client
		(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 1)
		OR (
			(a3.relationshiptype = 3 AND a4.nonmembersubcategory = 3)
			OR (l.socoro_leadtype IN (3,5) AND l.statecode = 0)
		)
		--certified member
		OR (a3.relationshiptype = 1 and a.cr67a_accountstatus IN (4, 5, 9, 11, 12))
		--event attendee
		OR (
			UPPER(e.cr67a_eventname) NOT LIKE '%BBA%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%Blak Business Awards%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%AEDF%'
			AND UPPER(e.cr67a_eventname) NOT LIKE '%Aboriginal Economic Development Forum%'
		))
) data
ON ',' + data.subindustryid + ',' LIKE '%,' + CAST(map.subvalue AS NVARCHAR(50)) + ',%'
GROUP BY map.label
ORDER BY total DESC;