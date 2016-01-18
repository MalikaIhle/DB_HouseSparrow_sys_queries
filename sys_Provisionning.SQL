-- sys_Provisionning --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 07/12/2015 --


-- sys_Provisionning

SELECT usys_qProvisioningFemales.* 
FROM usys_qProvisioningFemales

UNION ALL 

SELECT usys_qProvisioningMales.* 
FROM usys_qProvisioningMales

ORDER BY BirdID, [Year], [Stage];


-- usys_qProvisioningFemales

SELECT tblBroods.SocialMumID AS BirdID, 
"Female" AS Sex, 
Year(usys_qBroodEggDate.LayDate) AS [Year], 
IIf(tblDvdinfo.age Between 6 And 9,"7D","11D") AS Stage, 			-- if age tlDVDinfo is not between 6 and 9, then automatically categorized as d11
Avg([FVisit1]/(([EffectTime]/60)*[OffspringNo])) AS FreqVisits, 	-- avg(# visit female when female enter the NB / (hours elapsed between the first visit of the female to the end of tape * #offsrping) 				
Count(*) AS N -- nb of video tapes for that Female/year/chick age	-- why is the FreqVisits calculation depends on the # of offsrping ? is it freqVisit per offsrping and parents can only provision one chick at a time ??

FROM ((tblBroods 
INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef) 
INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef

WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9) -- select only age up to 13 (and not above), to be them categorized to d11
AND ((tblDVDInfo.OffspringNo)>0) -- video when there was chick
AND ((tblParentalCare.EffectTime)>0) 
AND ((tblParentalCare.FVisit1) Is Not Null) 
AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4) -- with eggs and chicks, or just chicks
AND ((usys_qBroodEggDate.LayDate) Is Not Null) 
AND ((tblBroods.SocialMumID) Is Not Null) 
AND ((tblBroods.SocialMumCertain)=True)) -- with certain social mum ID

GROUP BY tblBroods.SocialMumID, Year(usys_qBroodEggDate.LayDate), IIf(tblDvdinfo.age Between 6 And 9,"7D","11D");


-- usys_qProvisioningMales

SELECT tblBroods.SocialDadID AS BirdID, 
"Male" AS Sex, 
Year(usys_qBroodEggDate.LayDate) AS [Year], 
IIf(tblDvdInfo.age Between 6 And 9,"7D","11D") AS Stage, 
Avg([MVisit1]/(([EffectTime]/60)*[OffspringNo])) AS FreqVisits, Count(*) AS N

FROM ((tblBroods 
INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef)
INNER JOIN tblDVDInfo ON tblBroods.BroodRef = tblDVDInfo.BroodRef) 
INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef

WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9)
AND ((tblDVDInfo.OffspringNo)>0) 
AND ((tblParentalCare.EffectTime)>0) 
AND ((tblParentalCare.MVisit1) Is Not Null) 
AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4) 
AND ((usys_qBroodEggDate.LayDate) Is Not Null) 
AND ((tblBroods.SocialDadID) Is Not Null) 
AND ((tblBroods.SocialDadCertain)=True))

GROUP BY tblBroods.SocialDadID, Year(usys_qBroodEggDate.LayDate), IIf(tblDvdInfo.age Between 6 And 9,"7D","11D");




























