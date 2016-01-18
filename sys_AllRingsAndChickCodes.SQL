-- sys_AllRingsAndChickCodes --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 23/11/2015 --


-- usys_AllCodes

-- select all captures for which a new bird code was generated

SELECT tblCaptures.BirdID, tblAllCodes.Code, tblAllCodes.CodeType, tblCaptures.CaptureDate AS CodeDate
FROM tblCaptures INNER JOIN tblAllCodes ON tblCaptures.CaptureRef = tblAllCodes.CaptureRef
WHERE (((tblAllCodes.Code) Is Not Null))

UNION ALL 

SELECT tblChickCodes.BirdID, tblChickCodes.ChickCode, "C" AS CodeType, 

CDate(Switch([usys_qBroodHatchDate].[HatchDate] Is Not Null,[usys_qBroodHatchDate].[HatchDate],
				[usys_qBroodEggDate].[LayDate] Is Not Null,[usys_qBroodEggDate].[LayDate]+14,
				True,DateSerial(Nz([tblBirdID].[cohort],1900),1,1))) AS CodeDate

-- explanations for the functions used to determine the date at which the chick code was likely given to an individual
-- switch: evaluates a list of expressions and returns the corresponding value for the first expression in the list that is TRUE.
-- here, if not hatching date nor laying date (+14 days), then the third expression is 'true' and the code date is:
-- Nz: if cohort is null > indicate 01/01/1900 as a code date
-- cdate converts a value to a date
				
FROM ((tblBirdID 
INNER JOIN tblChickCodes ON (tblBirdID.BirdID = tblChickCodes.BirdID) 
AND (tblBirdID.BirdID = tblChickCodes.BirdID)) 
LEFT JOIN usys_qBroodHatchDate ON tblBirdID.BroodRef = usys_qBroodHatchDate.BroodRef) 
LEFT JOIN usys_qBroodEggDate ON tblBirdID.BroodRef = usys_qBroodEggDate.BroodRef;