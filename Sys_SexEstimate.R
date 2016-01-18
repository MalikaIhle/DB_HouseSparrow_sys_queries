## sys_SexEstimates --
##  House sparrow DB --
##  Ian Stevensson -- 

##  Notes from Malika --
##  25/11/2015 --


rm(list = ls(all = TRUE))
require(RODBC)
conDB= odbcConnectAccess('C:\\Users\\mihle\\Documents\\_Malika_Sheffield\\_CURRENT BACKUP\\db\\SparrowDatabase0.74_Malika.mdb')

sqlTables(conDB)

{usys_qSexEstimate = sqlQuery (conDB, "

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
		
							(SELECT tblBroods.SocialDadID AS BirdID, 1 AS Sex, 'SP' AS SexingMethod
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

")
}

head(usys_qSexEstimate)





{usys_qSexEstimateByCallingSubqueryFromAcess = sqlQuery (conDB, "
SELECT tblBirdID.BirdID, 
IIf(Sum((usys_qSexEstimatesUnion.Sex=0)*zzz_tblSexingWeights.Weighting)<>Sum((usys_qSexEstimatesUnion.Sex=1)*zzz_tblSexingWeights.Weighting),
Int(Sum(usys_qSexEstimatesUnion.Sex*zzz_tblSexingWeights.Weighting)/Sum(zzz_tblSexingWeights.Weighting)+0.499999),Null) AS SexEstimate, 
Count(usys_qSexEstimatesUnion.Sex) AS N, 
IIf(Count(usys_qSexEstimatesUnion.Sex)>0,Min(usys_qSexEstimatesUnion.Sex)<>Max(usys_qSexEstimatesUnion.Sex),0) AS Conflict

FROM zzz_tblSexingWeights 
RIGHT JOIN (tblBirdID 
LEFT JOIN 

usys_qSexEstimatesUnion 

ON tblBirdID.BirdID = usys_qSexEstimatesUnion.BirdID) ON zzz_tblSexingWeights.SexingMethod = usys_qSexEstimatesUnion.SexingMethod

WHERE (((tblBirdID.BirdID)>0))

GROUP BY tblBirdID.BirdID;
")
}


head(usys_qSexEstimateByCallingSubqueryFromAcess)




close(conDB)

