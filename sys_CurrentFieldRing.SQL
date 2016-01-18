-- sys_CurrentFieldRing --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 23/11/2015 --


-- usys_qLastFieldRing

			------------------------this is finally a smart code for selecting IDs that do not appear in another table !!
			-- select all birds that have last colour rings and indicate their colours
			-- add those birds that only have a last BTO ring but no colour ring
			-- for this: LastBTO left join to LastColourRing with BirdID in LastcolourRing IS NULL

SELECT usys_qLastColourRing.BirdID, usys_qLastColourRing.LastColRing as FieldRing
FROM usys_qLastColourRing

UNION ALL 

SELECT usys_qLastBTORing.BirdID, usys_qLastBTORing.BTO
FROM usys_qLastBTORing LEFT JOIN usys_qLastColourRing ON usys_qLastBTORing.BirdID = usys_qLastColourRing.BirdID
WHERE (((usys_qLastColourRing.BirdID) Is Null));




-- usys_qLastColourRing

SELECT tblAllCodes.BirdID, tblAllCodes.Code AS LastColRing
FROM (tblCaptures INNER JOIN usys_qLastColourRingDate ON (tblCaptures.BirdID = usys_qLastColourRingDate.BirdID) 
AND (tblCaptures.CaptureDate = usys_qLastColourRingDate.MaxOfDate)) INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.CodeType)="R"))
ORDER BY tblAllCodes.BirdID;


-- usys_qLastColourRingDate
SELECT tblCaptures.BirdID, Max(tblCaptures.CaptureDate) AS MaxOfDate
FROM tblCaptures INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.CodeType)="B"))
GROUP BY tblCaptures.BirdID;




