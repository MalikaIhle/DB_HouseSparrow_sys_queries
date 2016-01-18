-- sys_BroodIntervals --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 07/12/2015 --


-- sys_BroodIntervals

SELECT usys_qBroodIntervalsComplete.*, 
[usys_qProvisioning7and11DayFVisitsPer Brood].FemaleVisitsPerOffspring7D, 
[usys_qProvisioning7and11DayMVisitsPer Brood].MaleVisitsPerOffspring7D, 
[usys_qProvisioning7and11DayOffspringPer Brood].OffspringNo7D, 
[usys_qProvisioning7and11DayAgePer Brood].Age7D, 
[usys_qProvisioning7and11DayFVisitsPer Brood].FemaleVisitsPerOffspring11D, 
[usys_qProvisioning7and11DayMVisitsPer Brood].MaleVisitsPerOffspring11D, 
[usys_qProvisioning7and11DayOffspringPer Brood].OffspringNo11D, 
[usys_qProvisioning7and11DayAgePer Brood].Age11D

FROM (((usys_qBroodIntervalsComplete 
LEFT JOIN [usys_qProvisioning7and11DayAgePer Brood] ON usys_qBroodIntervalsComplete.BroodRef = [usys_qProvisioning7and11DayAgePer Brood].BroodRef) 
LEFT JOIN [usys_qProvisioning7and11DayOffspringPer Brood] ON usys_qBroodIntervalsComplete.BroodRef = [usys_qProvisioning7and11DayOffspringPer Brood].BroodRef) 
LEFT JOIN [usys_qProvisioning7and11DayMVisitsPer Brood] ON usys_qBroodIntervalsComplete.BroodRef = [usys_qProvisioning7and11DayMVisitsPer Brood].BroodRef) 
LEFT JOIN [usys_qProvisioning7and11DayFVisitsPer Brood] ON usys_qBroodIntervalsComplete.BroodRef = [usys_qProvisioning7and11DayFVisitsPer Brood].BroodRef;


		-- BroodIntervalComplete

		SELECT DISTINCT tblBroods.BroodRef, 
		tblBroods.BroodName, 
		usys_qBroodDuration.BroodYear, 
		BirdID_male.BirdID AS MaleID, 
		BirdID_female.BirdID AS FemaleID, 
		[broodYear]-BirdID_male.Cohort AS MaleAge, 					-- from usys_qBroodDuration.BroodYear
		[BroodYear]-BirdID_female.Cohort AS FemaleAge, 
		BirdID_female.Cohort-BirdID_male.Cohort AS MaleFemAgeDiff, 
		IIf([Nhatched] Is Not Null,[Nhatched],0) AS HatchBroodSize, -- from usys_qBroodHatchNoCalculated
		IIf([NRinged] Is Not Null,[Nringed],0) AS RingBroodSize, 	-- from usys_qBroodRingNoCalculated
		IIf([Nfledged] Is Null,0,[Nfledged]) AS FledgeBroodSize, 	-- from usys_qBroodFledgeNoCalculated
		IB_Interval_male.Interval AS MaleInterval, 					-- gives interval from that brood Ref end date to the start date of the next brood of that same parent (whether or not this parent bred again with the same partner)
		IB_Interval_female.Interval AS FemaleInterval, 
		Int(Format([EndDate],"y")) AS EndDayOfYear					-- from usys_qBroodDuration, gives the end date as a 'day of the year'
		
		FROM (((((((tblBroods 
		LEFT JOIN usys_qBroodIntervals AS IB_Interval_male ON (tblBroods.SocialDadID = IB_Interval_male.Parent) 
		AND (tblBroods.BroodRef = IB_Interval_male.BroodRef)) 
		LEFT JOIN tblBirdID AS BirdID_male ON tblBroods.SocialDadID = BirdID_male.BirdID)
		LEFT JOIN tblBirdID AS BirdID_female ON tblBroods.SocialMumID = BirdID_female.BirdID) 
		LEFT JOIN usys_qBroodIntervals AS IB_Interval_female ON (tblBroods.SocialMumID = IB_Interval_female.Parent) 
		AND (tblBroods.BroodRef = IB_Interval_female.BroodRef)) 
		INNER JOIN usys_qBroodDuration ON tblBroods.BroodRef = usys_qBroodDuration.BroodRef) 
		LEFT JOIN usys_qBroodHatchNoCalculated ON tblBroods.BroodRef = usys_qBroodHatchNoCalculated.BroodRef) 
		LEFT JOIN usys_qBroodFledgeNoCalculated ON tblBroods.BroodRef = usys_qBroodFledgeNoCalculated.RearingBrood) 
		LEFT JOIN usys_qBroodRingNoCalculated ON tblBroods.BroodRef = usys_qBroodRingNoCalculated.RearingBrood
		ORDER BY tblBroods.BroodRef;
		
				
				-- usys_qBroodIntervals
				
				SELECT Brood1.Parent, 
				Year(First(Brood1.StartDate)) AS Yr, 
				Brood1.BroodRef, 
				Min((Brood2.StartDate-Brood1.enddate)) AS [Interval] -- take the minimum interval to get the one between this brood and the direct next one of that same parent
				
				FROM usys_qBroodDuration AS Brood1 
				INNER JOIN usys_qBroodDuration AS Brood2 ON Brood1.Parent = Brood2.Parent
				
				WHERE (((Brood1.EndDate)<[Brood2].[Startdate]) 
				AND ((Year([Brood1].[enddate]))=Year([brood2].[Startdate])))
				GROUP BY Brood1.Parent, Brood1.BroodRef;
				
				
				-- usys_qBroodDuration
				
				SELECT usys_qBroodsParentList.BroodRef, 
				usys_qBroodEggDate.LayDate AS StartDate, 
				
				IIf([RingDate] Is Not Null, -- ring date from tblBroodEvents (event = 3)
					IIf([RingDate]<[HatchDate]+getdboption("AvgHatchToFledgePeriod"),[HatchDate]+getdboption("AvgHatchToFledgePeriod"),[RingDate]), -- get the latest date
						IIf([LastOffsprCapture] Is Not Null, -- if no event = 3 (ringing) then consider LastOffsprCapture Date and Hatch Date
							IIf([HatchDate] Is Not Null,
								IIf([LastOffsprCapture]>[HatchDate]+getdboption("AvgHatchToFledgePeriod"),[HatchDate]+getdboption("AvgHatchToFledgePeriod"),[LastOffsprCapture]), -- get the earliest date
									IIf([LastOffsprCapture]<usys_qBroodEggDate.LayDate+getdboption("AvgLayToFledgePeriod"),[LastOffsprCapture],usys_qBroodEggDate.LayDate+getdboption("AvgLayToFledgePeriod"))), -- this line is for when LastOffsprCapture is not null but hatchdate is null (should not really happen)
										IIf([HatchDate] Is Not Null,[HatchDate],usys_qBroodEggDate.LayDate+getdboption("AvgIncPeriod")))) AS EndDate, -- if ring date and LastOffsprCapture are null
					
				usys_qBroodsParentList.ParentID AS Parent, 
				usys_qBroodsParentList.Sex, 
				Year([LayDate]) AS BroodYear
				
				FROM (((usys_qBroodsParentList 
				LEFT JOIN usys_qLastOffsprCapture ON usys_qBroodsParentList.BroodRef = usys_qLastOffsprCapture.RearingBrood) 
				INNER JOIN usys_qBroodEggDate ON usys_qBroodsParentList.BroodRef = usys_qBroodEggDate.BroodRef) 
				LEFT JOIN usys_qBroodHatchDate ON usys_qBroodsParentList.BroodRef = usys_qBroodHatchDate.BroodRef) 
				LEFT JOIN usys_qBroodRingDate ON usys_qBroodsParentList.BroodRef = usys_qBroodRingDate.BroodRef;



						-- usys_qBroodsParentList
						
						SELECT tblBroods.BroodRef, tblBroods.SocialDadID as ParentID, 1 as Sex
						
						FROM tblBroods where SocialDadID is not null
						
						UNION ALL 
						
						SELECT tblBroods.BroodRef, tblBroods.SocialMumID, 0 as Sex
						
						FROM tblBroods where SocialMumID is not null;


						-- usys_qLastOffsprCapture
						
						SELECT IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood, 
						Max(tblCaptures.CaptureDate) AS LastOffsprCapture
						
						FROM (tblBirdID 
						INNER JOIN tblCaptures ON tblBirdID.BirdID = tblCaptures.BirdID) 
						LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
						
						WHERE (((tblBirdID.BroodRef) Is Not Null) AND ((tblBirdID.DeathDate) Is Null Or (tblBirdID.DeathDate)<>[capturedate]))
						GROUP BY IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]);
						
						
						-- usys_qBroodRingDate
						
						SELECT tblBroodEvents.BroodRef, 
						tblBroodEvents.EventDate AS RingDate, 
						tblBroodEvents.OffspringNest
						
						FROM tblBroodEvents
						
						WHERE (((tblBroodEvents.OffspringNest)>0) AND ((tblBroodEvents.EventNumber)=3))
						ORDER BY tblBroodEvents.BroodRef;





				-- usys_qBroodHatchNoCalculated 
						
				SELECT tblBirdID.BroodRef, 
				Count(*) AS Nhatched
				
				FROM tblBirdID
				
				WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null))
				GROUP BY tblBirdID.BroodRef;

				
						
						-- usys_qUniqueRingedIDs
						
						SELECT DISTINCT tblAllCodes.BirdID
						FROM tblAllCodes
						WHERE (((tblAllCodes.CodeType)<>"T")); -- only those with transponders
						
						
						-- usys_qRearingBrood
						
						SELECT tblBirdID.BirdID, 
						IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood
						
						FROM tblBirdID 
						LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
						
						WHERE (((tblBirdID.BroodRef) Is Not Null));



				-- usys_qBroodFledgeNoCalculated

				SELECT usys_qRearingBrood.RearingBrood, 
				Count(*) AS Nfledged
				
				FROM tblBirdID INNER JOIN usys_qRearingBrood ON tblBirdID.BirdID = usys_qRearingBrood.BirdID
				
				WHERE (((tblBirdID.LastStage)=3))
				GROUP BY usys_qRearingBrood.RearingBrood;


				-- usys_qBroodRingNoCalculated
				
				SELECT usys_qRearingBrood.RearingBrood, 
				Count(*) AS Nringed
				
				FROM usys_qRearingBrood INNER JOIN usys_qUniqueRingedIDs AS a ON usys_qRearingBrood.BirdID = a.BirdID
				
				GROUP BY usys_qRearingBrood.RearingBrood;

				


		-- usys_qProvisioning7and11DayAgePer Brood

		TRANSFORM Avg(tblDVDInfo.Age) AS AvgOfAge											-- value
		
		SELECT tblDVDInfo.BroodRef
		
		FROM tblDVDInfo 
		INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
		
		WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9) 
		AND ((tblParentalCare.EffectTime)>0) 
		AND ((tblParentalCare.FVisit1) Is Not Null) 
		AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4)  -- with eggs & chicks or just with chicks
		AND ((tblDVDInfo.OffspringNo)>0))
			
		GROUP BY tblDVDInfo.BroodRef														-- row heading: per brood
		PIVOT IIf(tblDvdinfo.age Between 6 And 9,"Age7D","Age11D");							-- column heading: per Age class of recording
	

	
		-- usys_qProvisioning7and11DayFVisitsPer Brood

		TRANSFORM Avg([FVisit1])/((Avg([EffectTime])/60)*Avg([OffspringNo])) AS FreqVisitsPerOffspring			-- value
		
		SELECT tblDVDInfo.BroodRef
		
		FROM tblDVDInfo 
		INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
		
		WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9) 
		AND ((tblParentalCare.EffectTime)>0) 
		AND ((tblParentalCare.FVisit1) Is Not Null) 
		AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4) 
		AND ((tblDVDInfo.OffspringNo)>0))
		
		GROUP BY tblDVDInfo.BroodRef																			-- row heading: per brood
		PIVOT IIf(tblDvdinfo.age Between 6 And 9,"FemaleVisitsPerOffspring7D","FemaleVisitsPerOffspring11D");	-- column heading: per Age class of recording



		-- usys_qProvisioning7and11DayMVisitsPer Brood

		TRANSFORM Avg([MVisit1])/((Avg([EffectTime])/60)*Avg([OffspringNo])) AS FreqVisitsPerOffspring		-- value
		
		SELECT tblDVDInfo.BroodRef
		
		FROM tblDVDInfo 
		INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
		
		WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9) 
		AND ((tblParentalCare.EffectTime)>0) 
		AND ((tblParentalCare.MVisit1) Is Not Null) 
		AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4) 
		AND ((tblDVDInfo.OffspringNo)>0))
		
		GROUP BY tblDVDInfo.BroodRef																		-- row heading: per brood
		PIVOT IIf(tblDvdinfo.age Between 6 And 9,"MaleVisitsPerOffspring7D","MaleVisitsPerOffspring11D");	-- column heading: per Age class of recording


		-- usys_qProvisioning7and11DayOffspringPer

		TRANSFORM Avg(tblDVDInfo.OffspringNo) AS AvgOfOffspringNo						-- value
		
		SELECT tblDVDInfo.BroodRef
		
		FROM tblDVDInfo 
		INNER JOIN tblParentalCare ON tblDVDInfo.DVDRef = tblParentalCare.DVDRef
		
		WHERE (((tblDVDInfo.Age) Between 10 And 13 Or (tblDVDInfo.Age) Between 6 And 9) 
		AND ((tblParentalCare.EffectTime)>0) 
		AND ((tblParentalCare.FVisit1) Is Not Null) 
		AND ((tblDVDInfo.Situation)=3 Or (tblDVDInfo.Situation)=4) 
		AND ((tblDVDInfo.OffspringNo)>0))
		
		GROUP BY tblDVDInfo.BroodRef													-- row heading: per brood
		PIVOT IIf(tblDvdinfo.age Between 6 And 9,"OffspringNo7D","OffspringNo11D");		-- column heading: per Age class of recording


		
		
		