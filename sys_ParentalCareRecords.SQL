-- sys_parentalCareRecords --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --


-- sys_ParentalCareRecords --

SELECT FocalBTOrings.BTO AS FocalBTO, PartnerBTOrings.BTO AS PartnerBTO, usys_qParentalCareRecords.*
FROM (usys_qParentalCareRecords 
INNER JOIN usys_qLastBTORing AS FocalBTOrings 
ON usys_qParentalCareRecords.FocalID = FocalBTOrings.BirdID) 
LEFT JOIN usys_qLastBTORing AS PartnerBTOrings 
ON usys_qParentalCareRecords.PartnerID = PartnerBTOrings.BirdID;

--usys_qParentalCareRecords

SELECT tblBroods.SocialMumID AS FocalID, tblBroods.SocialDadID AS PartnerID, "Female" AS FocalSex, 
Year(tblDVDInfo.DVDdate) AS [Year], -- select the year of a formatted date
Int(Format(tblDVDInfo.DVDdate,"y")) AS DayOfYear, -- format (Date, "formatting"): here "y" give the day of the year
IIf([tblDVDInfo].[Situation]<3,"Inc","Prov") AS TypeOfCare, -- situation 1 or 2 is with just egges, 3 mixture, four with only chicks
Year(tblDVDInfo.DVDdate)-[tblBirdID].[Cohort] AS Age, -- age in year 
tblDVDInfo.DVDNumber, tblBroods.BroodName, tblDVDInfo.DVDRef

FROM (tblBroods INNER JOIN tblBirdID ON tblBroods.SocialMumID = tblBirdID.BirdID) INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef
WHERE (((tblBroods.SocialMumID) Is Not Null) AND ((tblDVDInfo.DVDdate) Is Not Null) AND ((tblDVDInfo.Situation)<>0))

UNION ALL 

SELECT tblBroods.SocialDadID AS FocalID, tblBroods.SocialMumID AS PartnerID, "Male" AS FocalSex, 
Year(tblDVDInfo.DVDdate) AS [Year], 
Int(Format(tblDVDInfo.DVDdate,"y")) AS DayOfYear, 
IIf([tblDVDInfo].[Situation]<3,"Inc","Prov") AS TypeOfCare, 
Year(tblDVDInfo.DVDdate)-[tblBirdID].[Cohort] AS Age, 
tblDVDInfo.DVDNumber, tblBroods.BroodName, tblDVDInfo.DVDRef

FROM (tblBroods INNER JOIN tblBirdID ON tblBroods.SocialDadID = tblBirdID.BirdID) INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef
WHERE (((tblBroods.SocialDadID) Is Not Null) AND ((tblDVDInfo.DVDdate) Is Not Null) AND ((tblDVDInfo.Situation)<>0));

