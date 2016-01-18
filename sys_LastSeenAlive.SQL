-- sys_LastSeenAlive --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --


-- usys_qLastLiveRecord

SELECT usys_qLastLiveRecordCollection.BirdID, 
First(usys_qLastLiveRecordCollection.Date) AS LastLiveRecord, 
First(usys_qLastLiveRecordCollection.Source) AS Source
-- select the 'first' occurence, but there should be actually just one:
-- group bybBirdID and in usys_qLastLiveRecordDate, there is only the last (max) date per BirdID

FROM usys_qLastLiveRecordCollection 
INNER JOIN usys_qLastLiveRecordDate ON (usys_qLastLiveRecordCollection.Date = usys_qLastLiveRecordDate.LastLiveRecordDate) 
AND (usys_qLastLiveRecordCollection.BirdID = usys_qLastLiveRecordDate.BirdID)

GROUP BY usys_qLastLiveRecordCollection.BirdID
ORDER BY usys_qLastLiveRecordCollection.BirdID;


	-- usys_qLastLiveRecordCollection

	SELECT * from usys_qLastSightingDate
	UNION ALL Select * from usys_qLastLiveCapture
	UNION ALL Select * from usys_qLastSocialMumDate
	UNION ALL Select * from usys_qLastSocialDadDate
	UNION ALL Select * from usys_qLastEPPaternity;

	-- usys_qLastLiveRecordDate

	SELECT usys_qLastLiveRecordCollection.BirdID, Max(usys_qLastLiveRecordCollection.Date) AS LastLiveRecordDate
	FROM usys_qLastLiveRecordCollection
	GROUP BY usys_qLastLiveRecordCollection.BirdID;



			-- usys_qLastSightingDate
			
			SELECT tblSightings.BirdID, Max(tblSightings.SightingDate) AS [Date], "S" AS Source
			FROM tblSightings
			WHERE (((tblSightings.IDCertain)=True))
			GROUP BY tblSightings.BirdID;


			-- usys_qLastLiveCapture

			SELECT tblCaptures.BirdID, Max(tblCaptures.CaptureDate) AS [Date], "C" AS Source
			FROM tblBirdID INNER JOIN tblCaptures ON tblBirdID.BirdID = tblCaptures.BirdID
			WHERE (((tblBirdID.DeathDate) Is Null Or (tblBirdID.DeathDate)<>[Capturedate])  -- remove captures of dead birds
			AND ((tblCaptures.BirdID) Is Not Null)) 
			GROUP BY tblCaptures.BirdID;

			
			-- usys_qLastSocialMumDate

			SELECT tblBroods.SocialMumID AS BirdID, 
			Max(IIf([RingDate] Is Not Null,[Ringdate],IIf([HatchDate] Is Not Null,[Hatchdate],usys_qBroodEggDate.LayDate))) AS [Date], 
			"SP" AS Source
			FROM ((tblBroods INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
			LEFT JOIN usys_qBroodHatchDate ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
			LEFT JOIN usys_qBroodRingDate ON tblBroods.BroodRef = usys_qBroodRingDate.BroodRef
			WHERE (((tblBroods.SocialMumID) Is Not Null) AND ((tblBroods.SocialMumCertain)=True))
			GROUP BY tblBroods.SocialMumID;

			-- usys_qLastSocialDadDate

			SELECT tblBroods.SocialDadID AS BirdID, 
			Max(IIf([RingDate] Is Not Null,[Ringdate],IIf([HatchDate] Is Not Null,[Hatchdate],usys_qBroodEggDate.LayDate))) AS [Date], 
			"SP" AS Source
			FROM ((tblBroods INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
			LEFT JOIN usys_qBroodHatchDate ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
			LEFT JOIN usys_qBroodRingDate ON tblBroods.BroodRef = usys_qBroodRingDate.BroodRef
			WHERE (((tblBroods.SocialDadID) Is Not Null) AND ((tblBroods.SocialDadCertain)=True))
			GROUP BY tblBroods.SocialDadID;
	
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

				
				
					-- usys_qBroodRingDate
					
					SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS RingDate, tblBroodEvents.OffspringNest
					FROM tblBroodEvents
					WHERE (((tblBroodEvents.OffspringNest)>0) AND ((tblBroodEvents.EventNumber)=3)) -- -- Event#3 is ringing
					ORDER BY tblBroodEvents.BroodRef;

					
					
				
			-- usys_qLastEPPaternity
			
			SELECT usys_qGeneticParents.DadID AS BirdID, 
			Max(usys_qBroodEggDate.LayDate) AS [Date], 
			"EP" AS Source
			FROM (tblBroods INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
			INNER JOIN (tblBirdID AS tblBirdID_Offspring 
			INNER JOIN usys_qGeneticParents ON tblBirdID_Offspring.BirdID = usys_qGeneticParents.BirdID) ON tblBroods.BroodRef = tblBirdID_Offspring.BroodRef
			WHERE (((usys_qGeneticParents.DadID)<>[tblBroods].[SocialDadID])) -- this removes all lines where the genetic dad is also the social dad
			GROUP BY usys_qGeneticParents.DadID;
			
					-- usys_qGeneticParents
					
					SELECT tblBirdID.BirdID, tblGenPedigree.FatherID AS DadID, 
					IIf([tblGenPedigree].[UnidentifiedEPP] Is Null,0,[tblGenPedigree].[UnidentifiedEPP]) AS UnidentifiedEPP, 
					IIf([tblGenPedigree].[MotherID] Is Not Null,[tblGenPedigree].[MotherID],IIf([SocialMumCertain]=True,[SocialMumID],Null)) AS MumID
					FROM tblBroods RIGHT JOIN (tblBirdID LEFT JOIN tblGenPedigree ON tblBirdID.BirdID = tblGenPedigree.BirdID) 
					ON tblBroods.BroodRef = tblBirdID.BroodRef;
								----- this query relies on tblGenPedigree being updated in the DB and having a consensus on what is an unidentified EPP
