-- sys_EggAndHatchDates --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --


-- usys_qBirdEggHatchDates

SELECT tblBirdID.BirdID, usys_qBroodEggDate.LayDate AS EggDate, 
usys_qBroodHatchDate.HatchDate, 
usys_qBroodEggDate.DateEstimated AS EggDateEst, 
IIf(usys_qBroodHatchDate.BroodRef Is Not Null,usys_qBroodHatchDate.DateEstimated,0) AS HatchDateEst 
	---- reminder, in access: 0 = FALSE; -1 = TRUE
	---- the above line would mean:
	---- is there is a brood ref, indicate whether the hatch date is estimated or not (estimated = -1 or not estimated = 0)
	---- if there is not brood ref, hatch date estimated = 0 (not estimated ??)
	---- anyway: usys_qBroodHatchDate.BroodRef is from usys_qBroodsWithHatchlings.BroodRef which is set to be not null

FROM ((tblBroods LEFT JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
LEFT JOIN usys_qBroodHatchDate ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
INNER JOIN tblBirdID ON tblBroods.BroodRef = tblBirdID.BroodRef
WHERE (((tblBirdID.BroodRef) Is Not Null));


					-- usys_qBroodEggDate
					
					SELECT tblBroods.BroodRef, 
					IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
					IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
					FROM (usys_qBroodTrueEggDate 
					RIGHT JOIN tblBroods ON usys_qBroodTrueEggDate.BroodRef=tblBroods.BroodRef) 
					LEFT JOIN usys_qBroodEggDateFromFirstSeen ON tblBroods.BroodRef=usys_qBroodEggDateFromFirstSeen.BroodRef
					WHERE (((IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate)) Is Not Null));

									-- usys_qBroodTrueEggDate
									
									SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0)); -- nest check at first egg
									
									
									-- usys_qBroodEggDateFromFirstSeen
									
									SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0)); 
									------------------------------------------- I think there is a mistake here, event first seen = 4 !!!!

									
					-- usys_qBroodHatchDate

					SELECT usys_qBroodsWithHatchlings.BroodRef, 
					IIf(usys_qBroodHatchDatesFromTable.HatchDate Is Not Null,usys_qBroodHatchDatesFromTable.HatchDate,usys_qBroodEggDate.LayDate+GetDBOption("AvgIncPeriod")) AS HatchDate, 
								---- the above line means, that if there is not HatchDate give hatch date = LayDate + 14 days (i.e. the AvgIncPeriod indicated in tblDataBaseSettings)
					usys_qBroodHatchDatesFromTable.HatchDate Is Null Or usys_qBroodHatchDatesFromTable.DateEstimated AS DateEstimated
								----- Or function returns TRUE ('-1' in access databases) if any of the conditions are TRUE. Otherwise, it returns FALSE (0 in access DB)
					FROM (usys_qBroodsWithHatchlings 
					LEFT JOIN usys_qBroodHatchDatesFromTable ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodHatchDatesFromTable.BroodRef) 
					LEFT JOIN usys_qBroodEggDate ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodEggDate.BroodRef;

					
									-- usys_qBroodWithHatchling
									
									SELECT DISTINCT tblBirdID.BroodRef, 
									Count(*) AS NoHatchlings -- count(*) : counts the number of lines per grouping factor (here: BroodRef)
									FROM tblBirdID
									WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null)) ----- >>>> should be Last Stage > = 1 as it hatched ???
									GROUP BY tblBirdID.BroodRef;

									
									-- usys_qBroodHatchDateFromTable								

									SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS HatchDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=1)); -- Event#1 is first hatchling










