-- sys_IncubationTime --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --

--usys_qIncubationTime

SELECT tblBroods.SocialMumID AS BirdID, "Female" AS Sex, Year(tblDVDInfo.DVDdate) AS [Year], Avg(tblDVDInfo.OffspringNo) AS MeanEggNo, 
Avg((tblParentalCare.FTime/tblParentalCare.EffectTime)*60) AS MeanIncPerHour, Count(*) AS NoRecords
FROM (tblBroods INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef) INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
WHERE (((tblDVDInfo.DVDdate) Is Not Null) AND ((tblDVDInfo.Situation)=1 Or (tblDVDInfo.Situation)=2) AND ((tblDVDInfo.Age)>9 And (tblDVDInfo.Age)<14) AND ((tblDVDInfo.OffspringNo) Is Not Null) AND ((tblParentalCare.EffectTime) Is Not Null And (tblParentalCare.EffectTime)>0) AND ((tblParentalCare.FTime) Is Not Null) AND ((tblBroods.SocialMumCertain)=True))
GROUP BY tblBroods.SocialMumID, Year(tblDVDInfo.DVDdate)
HAVING (((tblBroods.SocialMumID) Is Not Null))

UNION ALL 

SELECT tblBroods.SocialDadID AS BirdID, "Male" AS Sex, Year(tblDVDInfo.DVDdate) AS [Year], Avg(tblDVDInfo.OffspringNo) AS MeanEggNo, Avg(([tblParentalCare].[MTime]/[tblParentalCare].[EffectTime])*60) AS MeanIncPerHour, Count(*) AS NoRecords
FROM (tblBroods INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef) INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
WHERE (((tblBroods.SocialDadCertain)=-1) AND ((tblDVDInfo.DVDdate) Is Not Null) AND ((tblDVDInfo.Situation)=1 Or (tblDVDInfo.Situation)=2) AND ((tblDVDInfo.Age)>9 And (tblDVDInfo.Age)<14) AND ((tblDVDInfo.OffspringNo) Is Not Null) AND ((tblParentalCare.EffectTime) Is Not Null And (tblParentalCare.EffectTime)>0) AND ((tblParentalCare.MTime) Is Not Null))
GROUP BY tblBroods.SocialDadID, Year(tblDVDInfo.DVDdate)
HAVING (((tblBroods.SocialDadID) Is Not Null));