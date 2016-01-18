-- sys_FledglingCounts --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 23/11/2015 --


-- sys_FledglingCounts		-- counts per brood

SELECT tblBroods.BroodRef, tblBroods.BroodName, 
IIf(usys_qFledgeNoPerOriginalClutch.FledgeNperOriginalClutch Is Not Null,usys_qFledgeNoPerOriginalClutch.FledgeNperOriginalClutch,0) AS FledgeNperOriginalClutch, 
IIf(usys_qFledgeNoPerRearingNest.FledgeNperRearingNest Is Not Null,usys_qFledgeNoPerRearingNest.FledgeNperRearingNest,0) AS FledgeNperRearingNest
FROM (tblBroods LEFT JOIN usys_qFledgeNoPerRearingNest ON tblBroods.BroodRef = usys_qFledgeNoPerRearingNest.RearingBrood) 
LEFT JOIN usys_qFledgeNoPerOriginalClutch ON tblBroods.BroodRef = usys_qFledgeNoPerOriginalClutch.BroodRef;


											-- count(*) : counts the number of lines per grouping factor

-- usys_qFledgeNoPerOriginalClutch

SELECT tblBirdID.BroodRef, Count(*) AS FledgeNperOriginalClutch
FROM tblBirdID
WHERE (((tblBirdID.LastStage)>2) AND ((tblBirdID.BroodRef) Is Not Null))
GROUP BY tblBirdID.BroodRef;


-- usys_qFledgeNoPerRearingNest

SELECT IIf([Fosterbrood] Is Null,[BroodRef],[Fosterbrood]) AS RearingBrood,
		Count(*) AS FledgeNperRearingNest
FROM tblBirdID LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
WHERE (((tblBirdID.LastStage)>2) AND ((tblBirdID.BroodRef) Is Not Null))
GROUP BY IIf([Fosterbrood] Is Null,[BroodRef],[Fosterbrood]);
