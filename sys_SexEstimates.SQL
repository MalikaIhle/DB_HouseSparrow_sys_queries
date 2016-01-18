-- sys_SexEstimates --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --


-- usys_qSexEstimates

SELECT tblBirdID.BirdID, 
IIf(Sum(([sex]=0)*[weighting])<>Sum(([sex]=1)*[weighting]),Int(Sum([sex]*[Weighting])/Sum([Weighting])+0.499999),Null) AS SexEstimate, -- 0=Female ; 1=Male
				---- the line above means: if the sum of the product of the occurences when sex = 0 times the weigth (depending on the sexing method)
				----- is different with the sum where sex = 1 (for a same bird)
				----- then take the integer (cut before the comma) of the (sum of (the product of sex (0 or 1) and the weigthing of this each estimation) 
				----- divided by the sum of all the weigthing for all those estimations) + 0.499999
				----- concretely, this means that if a bird only as females records: int(0.499) = 0 ; as a male: int(1.49) = 1
				----- if one bird: sex=0 molecular (weigth 4) and has 3 sightings as a male (weigth 1): sexEstimate = int((0*4+1*1+1*1+1*1)/7 + 0.49) = int(0.42+0.49) = 0.92 = female
				----- but if as likely to be female than a male, then do not give any value
Count(usys_qSexEstimatesUnion.Sex) AS N, 
IIf(Count([sex])>0,Min([sex])<>Max([sex]),0) AS Conflict
				---- the line above gives conflict as yes or no: 
				---- was the sex estimated several times?
				---- value if true = is min (sex) different of max (sex), yes or no ?,
				---- value if false = 0 (=No in access DB)

FROM zzz_tblSexingWeights 
RIGHT JOIN (tblBirdID 
LEFT JOIN usys_qSexEstimatesUnion ON tblBirdID.BirdID = usys_qSexEstimatesUnion.BirdID) 
ON zzz_tblSexingWeights.SexingMethod = usys_qSexEstimatesUnion.SexingMethod

WHERE (((tblBirdID.BirdID)>0))
GROUP BY tblBirdID.BirdID;


		-- zzz_tblSexingWeights
		SexingMethod	Weighting
			C				2
			G				4
			M				4
			S				1
			SP				2


		-- usys_qSexEstimatesUnion
	
		SELECT usys_qSexEstimatesCaptures.* 
		FROM usys_qSexEstimatesCaptures
		UNION ALL SELECT usys_qSexEstimatesMixed.* 
		FROM usys_qSexEstimatesMixed
		UNION ALL SELECT usys_qSexEstimatesFemaleSP.* 
		FROM usys_qSexEstimatesFemaleSP
		UNION ALL SELECT usys_qSexEstimatesMaleSP.* 
		FROM usys_qSexEstimatesMaleSP
		UNION ALL SELECT g.birdID,G.sex,G.sexingMethod 
		FROM usys_qSexEstimatesGenetic as G
		UNION ALL SELECT usys_qSexEstimatesSightings.* 
		FROM usys_qSexEstimatesSightings
		ORDER BY BirdID;

		
				-- usys_qSexEstimatesCaptures
				
				SELECT tblCaptures.BirdID, tblCapturesSexEst.Sex, "C" AS SexingMethod
				FROM tblCaptures 
				INNER JOIN tblCapturesSexEst 
				ON tblCaptures.CaptureRef = tblCapturesSexEst.CaptureRef;
				
				
				-- usys_qSexEstimatesMixed
	
				SELECT tblSexEstimatesMixed.BirdID, tblSexEstimatesMixed.Sex, "M" AS SexingMethod
				FROM tblSexEstimatesMixed;
					---- these are old records of old birds. back then, sex was identified with various methods and the consensus sex only was written down


				-- usys_qSexEstimatesFemaleSP
				
				SELECT tblBroods.SocialMumID AS BirdID, 0 AS Sex, "SP" AS SexingMethod
				FROM tblBroods INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef
				WHERE (((tblBroods.SocialMumID) Is Not Null) AND ((tblBroods.SocialMumCertain)=True));
					---- the inclusion of usys_qBroodEggDate remove 3 broods that do not have BroodEvent = 0 (but they have broodEvent = 4)
		
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


				-- usys_qSexEstimatesMaleSP

				SELECT tblBroods.SocialDadID AS BirdID, 1 AS Sex, "SP" AS SexingMethod
				
				FROM tblBroods INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef
				
				WHERE (((tblBroods.SocialDadID) Is Not Null) AND ((tblBroods.SocialDadCertain)=True));
				
				
				-- usys_qSexEstimatesGenetic
				
				SELECT DISTINCT tblGenotype.BirdID, tblGenotype.BloodSampleRef, IIf([AlleleB]="359",0,1) AS Sex, "G" AS SexingMethod
				FROM tblGenotype
				WHERE (((tblGenotype.Locus)="sex") AND ((tblGenotype.AlleleB) Is Not Null) AND ((tblGenotype.Exclude)=False)); -- exclude those lines where the column exclude is ticked
						--- this is not group per BirdID, this select distinc line: here distinct blood sample (several per bird possible, each having full weigth)
				
				
				-- usys_qSexEstimatesSightings
				
				SELECT tblSightings.BirdID, tblSightings.Sex, "S" AS SexingMethod
				FROM tblSightings
				WHERE (((tblSightings.Sex) Is Not Null) AND ((tblSightings.IDCertain)=True)); -- only sighting where ID was certain

				
				
				
				
				
				
-- combined version (1 BIG SQL code)

SELECT tblBirdID.BirdID, 
IIf(Sum((usys_qSexEstimatesUnion.Sex=0)*zzz_tblSexingWeights.Weighting)<>Sum((usys_qSexEstimatesUnion.Sex=1)*zzz_tblSexingWeights.Weighting),
Int(Sum(usys_qSexEstimatesUnion.Sex*zzz_tblSexingWeights.Weighting)/Sum(zzz_tblSexingWeights.Weighting)+0.499999),Null) AS SexEstimate, 
Count(usys_qSexEstimatesUnion.Sex) AS N, 
IIf(Count(usys_qSexEstimatesUnion.Sex)>0,Min(usys_qSexEstimatesUnion.Sex)<>Max(usys_qSexEstimatesUnion.Sex),0) AS Conflict

FROM zzz_tblSexingWeights 
RIGHT JOIN (tblBirdID 
LEFT JOIN 

		(SELECT usys_qSexEstimatesCaptures.* 
				
		FROM 
					(SELECT tblCaptures.BirdID, tblCapturesSexEst.Sex, 'C' AS SexingMethod
					FROM tblCaptures INNER JOIN tblCapturesSexEst ON tblCaptures.CaptureRef = tblCapturesSexEst.CaptureRef) AS usys_qSexEstimatesCaptures
					
		UNION ALL SELECT usys_qSexEstimatesMixed.* 
		FROM 
		
					(SELECT tblSexEstimatesMixed.BirdID, tblSexEstimatesMixed.Sex, 'M' AS SexingMethod
					FROM tblSexEstimatesMixed) AS usys_qSexEstimatesMixed
		
		UNION ALL SELECT usys_qSexEstimatesFemaleSP.* 
				
		FROM 
		
					(SELECT tblBroods.SocialMumID AS BirdID, 0 AS Sex, 'SP' AS SexingMethod
					FROM tblBroods INNER JOIN 
					
							(SELECT tblBroods.BroodRef, IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
							FROM (
							
									(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))) AS usys_qBroodTrueEggDate 
							
							RIGHT JOIN tblBroods ON usys_qBroodTrueEggDate.BroodRef = tblBroods.BroodRef) 
							
							LEFT JOIN 
							
									(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))) AS usys_qBroodEggDateFromFirstSeen 
									
							ON tblBroods.BroodRef = usys_qBroodEggDateFromFirstSeen.BroodRef
							
							WHERE (((IIf([usys_qBroodTrueEggDate].[LayDate],[usys_qBroodTrueEggDate].[LayDate],[usys_qBroodEggDateFromFirstSeen].[LayDate])) Is Not Null))) AS usys_qBroodEggDate 
					
					ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef
					WHERE (((tblBroods.SocialMumID) Is Not Null) AND ((tblBroods.SocialMumCertain)=True))) AS usys_qSexEstimatesFemaleSP
					
		UNION ALL SELECT usys_qSexEstimatesMaleSP.* 
		FROM 
		
							(SELECT tblBroods.SocialDadID AS BirdID, 0 AS Sex, 'SP' AS SexingMethod
					FROM tblBroods INNER JOIN 
					
							(SELECT tblBroods.BroodRef, IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
							FROM (
							
									(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))) AS usys_qBroodTrueEggDate 
							
							RIGHT JOIN tblBroods ON usys_qBroodTrueEggDate.BroodRef = tblBroods.BroodRef) 
							
							LEFT JOIN 
							
									(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
									FROM tblBroodEvents
									WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))) AS usys_qBroodEggDateFromFirstSeen 
									
							ON tblBroods.BroodRef = usys_qBroodEggDateFromFirstSeen.BroodRef
							
							WHERE (((IIf([usys_qBroodTrueEggDate].[LayDate],[usys_qBroodTrueEggDate].[LayDate],[usys_qBroodEggDateFromFirstSeen].[LayDate])) Is Not Null))) AS usys_qBroodEggDate 
					
					ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef
					WHERE (((tblBroods.SocialDadID) Is Not Null) AND ((tblBroods.SocialDadCertain)=True))) AS usys_qSexEstimatesMaleSP
					
					
		UNION ALL SELECT usys_qSexEstimatesGenetic.birdID,usys_qSexEstimatesGenetic.sex,usys_qSexEstimatesGenetic.sexingMethod 
		FROM 
		
				(SELECT DISTINCT tblGenotype.BirdID, tblGenotype.BloodSampleRef, IIf(tblGenotype.AlleleB='359',0,1) AS Sex, 'G' AS SexingMethod
				FROM tblGenotype
				WHERE (((tblGenotype.Locus)='sex') AND ((tblGenotype.AlleleB) Is Not Null) AND ((tblGenotype.Exclude)=False))) AS usys_qSexEstimatesGenetic
		
		UNION ALL SELECT usys_qSexEstimatesSightings.* 
		FROM 
		
				(SELECT tblSightings.BirdID, tblSightings.Sex, 'S' AS SexingMethod
				FROM tblSightings
				WHERE (((tblSightings.Sex) Is Not Null) AND ((tblSightings.IDCertain)=True))) AS usys_qSexEstimatesSightings
		
		ORDER BY BirdID) AS usys_qSexEstimatesUnion 

ON tblBirdID.BirdID = usys_qSexEstimatesUnion.BirdID) ON zzz_tblSexingWeights.SexingMethod = usys_qSexEstimatesUnion.SexingMethod

WHERE (((tblBirdID.BirdID)>0))

GROUP BY tblBirdID.BirdID;