-- sys_RearingAndNatalBroods --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --



-- sys_RearingAndNatalBroods

SELECT tblBirdID.BirdID, tblBirdID.BroodRef AS NataBrood, 
IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood, 
[XFosterRef] Is Not Null AS Fostered

FROM tblBirdID LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
WHERE (((tblBirdID.BroodRef) Is Not Null)); -- does not include birds from unknnown brood (a bit more than 1000), old cohort and from wild nest ?
