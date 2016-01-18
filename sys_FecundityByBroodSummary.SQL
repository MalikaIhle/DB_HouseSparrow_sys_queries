-- sys_FecundityByBroodSummary --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 04/12/2015 --


-- sys_FecundityByBroodSummary

SELECT tblBroods.BroodRef, 
tblBroods.BroodName, 
tblBroods.NestboxRef, 
tblBroods.SocialDadID, 
tblBroods.SocialDadCertain, 
tblBroods.SocialMumID, 
tblBroods.SocialMumCertain, 
Year([EventDate]) AS BroodYear, 
tblBroodEvents.OffspringNest AS Eggs, 		-- I'm not sure I would trust this value 
usys_qBroodsWithHatchlings.NoHatchlings AS Hatchlings, -- this does not include laststage = 1 "chigg"
usys_qFledgeNoPerOriginalClutch.FledgeNperOriginalClutch, 
usys_qFledgeNoPerRearingNest.FledgeNperRearingNest, 
Int(Format(tblBroodEvents.EventDate,"y")) AS StartDay

FROM ((((tblBroods 
LEFT JOIN usys_qFledgeNoPerOriginalClutch ON tblBroods.BroodRef = usys_qFledgeNoPerOriginalClutch.BroodRef) 
LEFT JOIN usys_qFledgeNoPerRearingNest ON tblBroods.BroodRef = usys_qFledgeNoPerRearingNest.RearingBrood) 
LEFT JOIN usys_qBroodsWithHatchlings ON tblBroods.BroodRef = usys_qBroodsWithHatchlings.BroodRef) 
INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
INNER JOIN tblBroodEvents ON tblBroods.BroodRef = tblBroodEvents.BroodRef

WHERE (((tblBroodEvents.EventNumber)=0))	-- does not include those clutches where first time seen later than first egg (brood event = 0), i.e. for which brood event = 4
ORDER BY Year([EventDate]);



		-- usys_qBroodEggDate
		-- see sys_LastSeenAlive for potential mistakes		
		
		-- usys_qBroodsWithHatchlings
		
		SELECT DISTINCT tblBirdID.BroodRef, 
		Count(*) AS NoHatchlings
		
		FROM tblBirdID
		
		WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null))	-- could maybe include 'chigg' laststage = 1
		GROUP BY tblBirdID.BroodRef;

				
		-- usys_qFledgeNoPerOriginalClutch
		
		SELECT tblBirdID.BroodRef, 
		Count(*) AS FledgeNperOriginalClutch
		
		FROM tblBirdID
		
		WHERE (((tblBirdID.LastStage)>2) AND ((tblBirdID.BroodRef) Is Not Null))
		GROUP BY tblBirdID.BroodRef;
		
		
		-- usys_qFledgeNoPerRearingNest
		
		SELECT IIf([Fosterbrood] Is Null,[BroodRef],[Fosterbrood]) AS RearingBrood, 
		Count(*) AS FledgeNperRearingNest
		
		FROM tblBirdID 
		LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID

		WHERE (((tblBirdID.LastStage)>2) AND ((tblBirdID.BroodRef) Is Not Null))
		GROUP BY IIf([Fosterbrood] Is Null,[BroodRef],[Fosterbrood]);

































