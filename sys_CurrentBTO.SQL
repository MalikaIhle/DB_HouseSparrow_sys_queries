-- sys_Current BTO --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 23/11/2015 --


-- usys_qLastBTORing --

SELECT tblCaptures.BirdID, tblAllCodes.Code AS BTO
FROM (tblCaptures 
INNER JOIN usys_qLastBtoRingDate ON (tblCaptures.CaptureDate = usys_qLastBtoRingDate.MaxOfDate) 
AND (tblCaptures.BirdID = usys_qLastBtoRingDate.BirdID)) 
INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.CodeType)="B"));

-- usys_qLastBtoRingDate
SELECT tblCaptures.BirdID, Max(tblCaptures.CaptureDate) AS MaxOfDate
FROM tblCaptures INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.CodeType)="B"))
GROUP BY tblCaptures.BirdID;






-- usys_qLastBTORing is equivalent to:


SELECT tblCaptures.BirdID, tblAllCodes.Code AS BTO
FROM (tblCaptures 
INNER JOIN 
	
	(SELECT tblCaptures.BirdID, Max(tblCaptures.CaptureDate) AS MaxOfDate
	FROM tblCaptures INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
	WHERE (((tblAllCodes.CodeType)="B"))
	GROUP BY tblCaptures.BirdID) AS usys_qLastBtoRingDate 

ON (tblCaptures.CaptureDate = usys_qLastBtoRingDate.MaxOfDate) 
AND (tblCaptures.BirdID = usys_qLastBtoRingDate.BirdID)) 
INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.CodeType)="B"));











