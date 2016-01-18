-- sys_RelativeChickMass --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 25/11/2015 --

-- IMPORTANT REMARKS
-- this query gives an output above 2GB so it cannot be ran from Access.
-- R only fetch the output of queries computed by Access or call table which store data. R cannot call subqueries from the database as they do not store data
-- to ease Access computing:
-- I copied manually usys_tblRelativeChickMass from the front end interface to the DB SaprrowData to be used as a table
-- I transform the output of the query 'sys_EggAndHatchDates' into a table 'usys_tblBirdEggHatchDates' and copied it from the front end interface to the DB SaprrowData to be used as a table
-- I modified the sys_RelativeChickMass query to be calling the 'usys_tblBirdEggHatchDates' table instead of the 'usys_qBirdEggHatchDates' subquery.
-- beware: this query (and table) EggAndHatchDates potentially have two mistakes mentionned in 'sys_lastSeenAlive'
--
-- this is query a trying to get the mass of chicks relative to the average mass of a chick in this social/rearing brood.



-- slightly modified -- usys_qRelativeChickMass


SELECT tblCaptures.BirdID, 
usys_qRearingBrood.RearingBrood, 
usys_qChickMassMeanSdMeasureDay.ClassName, 
tblCaptures.CaptureDate-[HatchDate]+1 AS Age, 
usys_qRelativeChickMassAvgMeasuresByCapture.Mass, 
[Mass]-[AvgMass] AS MassDev, 												-- AvgMass is the average chick mass for that rearing brood
usys_qChickMassMeanSdMeasureDay.n, 											-- the number of chicks in this social brood (~between 1 and 10)
usys_qChickGrowthExptTreatment.HatchPosition, 
usys_qChickGrowthExptTreatment.TreatmentName AS Treatment, 
usys_qChickMassMeanSdMeasureDay.AvgClassAge

FROM (((tblCaptures 
INNER JOIN (usys_qRearingBrood 
INNER JOIN usys_qChickMassMeanSdMeasureDay ON usys_qRearingBrood.RearingBrood = usys_qChickMassMeanSdMeasureDay.RearingBrood) 
ON tblCaptures.BirdID = usys_qRearingBrood.BirdID) 
INNER JOIN usys_tblBirdEggHatchDates ON tblCaptures.BirdID = usys_tblBirdEggHatchDates.BirdID) 
LEFT JOIN usys_qChickGrowthExptTreatment ON tblCaptures.BirdID = usys_qChickGrowthExptTreatment.BirdID) 
INNER JOIN usys_qRelativeChickMassAvgMeasuresByCapture ON (usys_qChickMassMeanSdMeasureDay.MeasureDay = usys_qRelativeChickMassAvgMeasuresByCapture.MeasureDay) 
AND (tblCaptures.CaptureRef = usys_qRelativeChickMassAvgMeasuresByCapture.CaptureRef)

WHERE (((tblCaptures.Stage)<3))
ORDER BY tblCaptures.BirdID, usys_qChickMassMeanSdMeasureDay.MeasureDay;




		-- usys_qRearingBrood

		SELECT tblBirdID.BirdID, 
		IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood

		FROM tblBirdID LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID

		WHERE (((tblBirdID.BroodRef) Is Not Null));




		-- usys_qChickMassMeanSdMeasureDay

		SELECT usys_qRearingBrood.RearingBrood, 									-- this will calculate things for social brood
		usys_qRelativeChickMassClassesForCaptures.MassClass AS MeasureDay, 			-- the day of measurement 'd3, d7, d10, d14' even if their age was a bit different
		First(usys_tblRelativeChickMassClasses.Class) AS ClassName, 				-- give the actual age range for that type of measurement e.g.:'d14'=11-14
		Avg(tblMeasurements.Mass) AS AvgMass, 										-- the avg mass of a chick in this social brood at this age class
		StDev(tblMeasurements.Mass) AS SdMass, 
		Min(tblMeasurements.Mass) AS MinMass, 
		Max(tblMeasurements.Mass) AS MaxMass, 
		Count(tblMeasurements.Mass) AS n, 											-- the number of chicks in this social brood (~between 1 and 10)
		Avg(usys_qRelativeChickMassClassesForCaptures.Age) AS AvgClassAge			-- the avg age of the chicks of this social brood when measured at 'd3', 'd7'...

		FROM (((usys_qRearingBrood 
		INNER JOIN tblCaptures ON usys_qRearingBrood.BirdID = tblCaptures.BirdID) 
		INNER JOIN usys_qRelativeChickMassClassesForCaptures ON tblCaptures.CaptureRef = usys_qRelativeChickMassClassesForCaptures.CaptureRef) 
		INNER JOIN usys_tblRelativeChickMassClasses ON usys_qRelativeChickMassClassesForCaptures.MassClass = usys_tblRelativeChickMassClasses.MassDay) 
		INNER JOIN tblMeasurements ON tblCaptures.CaptureRef = tblMeasurements.CaptureRef

		WHERE (((usys_qRearingBrood.RearingBrood) Is Not Null) AND ((usys_tblRelativeChickMassClasses.Display)=True))
		GROUP BY usys_qRearingBrood.RearingBrood, usys_qRelativeChickMassClassesForCaptures.MassClass
		HAVING (((Count(tblMeasurements.Mass))>0));




				-- usys_qRelativeChickMassClassesForCaptures

				SELECT tblCaptures.CaptureRef, 
				Min(usys_tblRelativeChickMassClasses.MassDay) AS MassClass, 
				First(tblCaptures.CaptureDate-[HatchDate])+1 AS Age            -- true as query grouped per CaptureRef only for chick captures

				FROM usys_tblRelativeChickMassClasses, tblCaptures 
				INNER JOIN usys_qBirdEggHatchDates ON tblCaptures.BirdID = usys_qBirdEggHatchDates.BirdID

				WHERE (((([tblCaptures].[CaptureDate]-[HatchDate])+1)<=[MassDay]) AND ((tblCaptures.Stage)<3)) -- select chick captures per age class
				GROUP BY tblCaptures.CaptureRef;
				
				
						-- usys_tblRelativeChickMassClasses
						MassDay		Class	Display
						1			<=1			No 			-- Only those display = yes, will be shown in the subquery  'usys_qRelativeChickMassAvgMasuresByCapture' below
						3			2 - 3		Yes
						7			4 - 7		Yes
						10			8 - 10		No
						14			11 - 14		Yes



		-- usys_qChickGrowthExptTreatment

		SELECT tblExptTreatmentsApplied.BirdID, 
		tblExptTreatmentsApplied.TreatmentRef, 
		tblChickGrowthExpt.HatchPosition, 
		usys_qCodesTreatment.TreatmentName
		
		FROM (tblExptTreatments 
		LEFT JOIN usys_qCodesTreatment ON tblExptTreatments.TreatmentRef = usys_qCodesTreatment.TreatmentRef) 
		INNER JOIN (tblExptTreatmentsApplied 
		LEFT JOIN tblChickGrowthExpt ON tblExptTreatmentsApplied.BirdID = tblChickGrowthExpt.BirdID) 
		ON tblExptTreatments.TreatmentRef = tblExptTreatmentsApplied.TreatmentRef
		
		WHERE (((tblExptTreatments.ExperimentRef)=1));


				-- usys_qCodesTreatment

				SELECT tblExptTreatments.TreatmentRef, tblExptTreatments.TreatmentName, tblExperiments.ExperimentName
				FROM tblExperiments INNER JOIN tblExptTreatments ON tblExperiments.ExptRef = tblExptTreatments.ExperimentRef;
				
				
									-- tblExperiments	
									ExptRef	ExperimentName
									1		Chick Growth	
									2		Badge	

									
									-- tblExpttreatments			
									TreatmentRef	ExperimentRef	TreatmentName	
									1					1				Control	
									2					1				Fed	Fed
									3					2				Control	
									4					2				Experiment				


		-- usys_qRelativeChickMassAvgMasuresByCapture								-- weird, normally, one individual measured per capture Ref (but there is 23 occurence where there are two entires in tabl Measurement for a same capture ref)

		SELECT tblMeasurements.CaptureRef, 
		Avg(tblMeasurements.Tarsus) AS Tarsus, 										-- mostly empty
		Avg(tblMeasurements.BillLength) AS BillLength, 								-- empty
		Avg(tblMeasurements.BillWidth) AS BillWidth, 								-- empty
		Avg(tblMeasurements.TailLength) AS TailLength, 								-- empty
		Avg(tblMeasurements.WingLength) AS WingLength, 								-- mostly empty
		Avg(tblMeasurements.Mass) AS Mass, 
		Avg(tblMeasurements.MeasureTime) AS MeasureTime,							 -- likely useless, it is making an average of a time e.g.: 21:00 which have rarely been entered
		First(usys_qRelativeChickMassClassesForCaptures.MassClass) AS MeasureDay	 -- age class for measurement
		
		FROM (tblMeasurements 
		INNER JOIN usys_qRelativeChickMassClassesForCaptures ON tblMeasurements.CaptureRef = usys_qRelativeChickMassClassesForCaptures.CaptureRef) 
		INNER JOIN usys_tblRelativeChickMassClasses ON usys_qRelativeChickMassClassesForCaptures.MassClass = usys_tblRelativeChickMassClasses.MassDay
		
		WHERE (((usys_tblRelativeChickMassClasses.Display)=True)) -- only those 'display = yes' in 'usys_tblRelativeChickMassClasses' above are displayed
		GROUP BY tblMeasurements.CaptureRef;






















-- not working if temporary space for Access not big enough (the case for my computer)

-- call the Access DB from R --

rm(list = ls(all = TRUE))
require(RODBC)
conDB= odbcConnectAccess("C:\\Users\\mihle\\Documents\\_Malika_Sheffield\\_CURRENT BACKUP\\db\\SparrowData.mdb")

sqlTables(conDB)


-- usys_qRelativeChickMass -- original code: 
-- this cannot work, as this is based on subqueries which cannot be called from R as their a not tables with stored data

usys_qRelativeChickMass = sqlQuery (conDB, "
SELECT tblCaptures.BirdID, 
usys_qRearingBrood.RearingBrood, 
usys_qChickMassMeanSdMeasureDay.ClassName, 
tblCaptures.CaptureDate-[HatchDate]+1 AS Age, 
usys_qRelativeChickMassAvgMeasuresByCapture.Mass, 
[Mass]-[AvgMass] AS MassDev, 
usys_qChickMassMeanSdMeasureDay.n, 
usys_qChickGrowthExptTreatment.HatchPosition, 
usys_qChickGrowthExptTreatment.TreatmentName AS Treatment, 
usys_qChickMassMeanSdMeasureDay.AvgClassAge

FROM (((tblCaptures 
INNER JOIN (usys_qRearingBrood 
INNER JOIN usys_qChickMassMeanSdMeasureDay ON usys_qRearingBrood.RearingBrood = usys_qChickMassMeanSdMeasureDay.RearingBrood) 
ON tblCaptures.BirdID = usys_qRearingBrood.BirdID) 
INNER JOIN usys_qBirdEggHatchDates ON tblCaptures.BirdID = usys_qBirdEggHatchDates.BirdID) 
LEFT JOIN usys_qChickGrowthExptTreatment ON tblCaptures.BirdID = usys_qChickGrowthExptTreatment.BirdID) 
INNER JOIN usys_qRelativeChickMassAvgMeasuresByCapture ON (usys_qChickMassMeanSdMeasureDay.MeasureDay = usys_qRelativeChickMassAvgMeasuresByCapture.MeasureDay) 
AND (tblCaptures.CaptureRef = usys_qRelativeChickMassAvgMeasuresByCapture.CaptureRef)

WHERE (((tblCaptures.Stage)<3))
ORDER BY tblCaptures.BirdID, usys_qChickMassMeanSdMeasureDay.MeasureDay;
")





-- usys_qRelativeChickMass -- One big SQL code that could run in R: 
-- replace all the subquery called (in the section 'FROM') by their actual SQL codes in braquets followed by AS subquery.name
-- this also need to be repeated in the section 'FROM of the subsubqueries...
-- (just remove the first quotation mark to see the SQL code formatted ; but put it back to run the query)
-- I think the SQL code is correct below, but anyway, doesn't run because access can't get over that 2GB limit
-- R is simply calling the output of Access work, does not do the computation itself. good to know...

usys_qRelativeChickMass = sqlQuery (conDB, "

SELECT tblCaptures.BirdID, 
usys_qRearingBrood.RearingBrood, 
usys_qChickMassMeanSdMeasureDay.ClassName, 
tblCaptures.CaptureDate-[HatchDate]+1 AS Age, 
usys_qRelativeChickMassAvgMeasuresByCapture.Mass, 
[Mass]-[AvgMass] AS MassDev, usys_qChickMassMeanSdMeasureDay.n, 
usys_qChickGrowthExptTreatment.HatchPosition, 
usys_qChickGrowthExptTreatment.TreatmentName AS Treatment, 
usys_qChickMassMeanSdMeasureDay.AvgClassAge

FROM (((tblCaptures 
INNER JOIN (
				(SELECT tblBirdID.BirdID, IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood
				FROM tblBirdID LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
				WHERE (((tblBirdID.BroodRef) Is Not Null))) AS usys_qRearingBrood 

INNER JOIN 
				(SELECT usys_qRearingBrood.RearingBrood, usys_qRelativeChickMassClassesForCaptures.MassClass AS MeasureDay, 
				First(usys_tblRelativeChickMassClasses.Class) AS ClassName, 
				Avg(tblMeasurements.Mass) AS AvgMass, 
				StDev(tblMeasurements.Mass) AS SdMass, 
				Min(tblMeasurements.Mass) AS MinMass, 
				Max(tblMeasurements.Mass) AS MaxMass, 
				Count(tblMeasurements.Mass) AS n, 
				Avg(usys_qRelativeChickMassClassesForCaptures.Age) AS AvgClassAge
				
				FROM (((
				
						(SELECT tblBirdID.BirdID, IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood
						FROM tblBirdID LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
						WHERE (((tblBirdID.BroodRef) Is Not Null))) AS usys_qRearingBrood
				
				INNER JOIN tblCaptures ON usys_qRearingBrood.BirdID = tblCaptures.BirdID) 
				INNER JOIN 
				
				
						(SELECT tblCaptures.CaptureRef, 
						Min(usys_tblRelativeChickMassClasses.MassDay) AS MassClass, 
						First(tblCaptures.CaptureDate-[HatchDate])+1 AS Age
						
						FROM usys_tblRelativeChickMassClasses, tblCaptures 
						INNER JOIN 
						
								(SELECT tblBirdID.BirdID, usys_qBroodEggDate.LayDate AS EggDate, 
								usys_qBroodHatchDate.HatchDate, 
								usys_qBroodEggDate.DateEstimated AS EggDateEst, 
								IIf(usys_qBroodHatchDate.BroodRef Is Not Null,usys_qBroodHatchDate.DateEstimated,0) AS HatchDateEst
								
								FROM ((tblBroods LEFT JOIN 
								
										(SELECT tblBroods.BroodRef, 
										IIf(usys_qBroodTrueEggDate.LayDate,
										usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
										IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
										
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
										
								ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
								LEFT JOIN 
								
										(SELECT usys_qBroodsWithHatchlings.BroodRef, 
										IIf(usys_qBroodHatchDatesFromTable.HatchDate Is Not Null,usys_qBroodHatchDatesFromTable.HatchDate,usys_qBroodEggDate.LayDate+14) AS HatchDate, 
										usys_qBroodHatchDatesFromTable.HatchDate Is Null Or usys_qBroodHatchDatesFromTable.DateEstimated AS DateEstimated
										FROM (
										
												(SELECT DISTINCT tblBirdID.BroodRef, Count(*) AS NoHatchlings
												FROM tblBirdID
												WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null))
												GROUP BY tblBirdID.BroodRef) AS usys_qBroodsWithHatchlings 
										
										LEFT JOIN 
										
												(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS HatchDate, tblBroodEvents.DateEstimated
												FROM tblBroodEvents
												WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=1))) AS usys_qBroodHatchDatesFromTable 
										
										ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodHatchDatesFromTable.BroodRef) 
										
										LEFT JOIN 
										
												(SELECT tblBroods.BroodRef, 
												IIf(usys_qBroodTrueEggDate.LayDate,
												usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
												IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
												
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
										
										ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodEggDate.BroodRef) AS usys_qBroodHatchDate 
								
								ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
								INNER JOIN tblBirdID ON tblBroods.BroodRef = tblBirdID.BroodRef
								
								WHERE (((tblBirdID.BroodRef) Is Not Null))) AS usys_qBirdEggHatchDates 
						
						ON tblCaptures.BirdID = usys_qBirdEggHatchDates.BirdID
						
						WHERE (((([tblCaptures].[CaptureDate]-[HatchDate])+1)<=[MassDay]) AND ((tblCaptures.Stage)<3))
						GROUP BY tblCaptures.CaptureRef) AS usys_qRelativeChickMassClassesForCaptures 
				
				
				ON tblCaptures.CaptureRef = usys_qRelativeChickMassClassesForCaptures.CaptureRef) 
				
				INNER JOIN usys_tblRelativeChickMassClasses ON usys_qRelativeChickMassClassesForCaptures.MassClass = usys_tblRelativeChickMassClasses.MassDay) 
				INNER JOIN tblMeasurements ON tblCaptures.CaptureRef = tblMeasurements.CaptureRef
				
				WHERE (((usys_qRearingBrood.RearingBrood) Is Not Null) AND ((usys_tblRelativeChickMassClasses.Display)=True))
				GROUP BY usys_qRearingBrood.RearingBrood, usys_qRelativeChickMassClassesForCaptures.MassClass
				HAVING (((Count(tblMeasurements.Mass))>0))) AS usys_qChickMassMeanSdMeasureDay 

ON usys_qRearingBrood.RearingBrood = usys_qChickMassMeanSdMeasureDay.RearingBrood) 
ON tblCaptures.BirdID = usys_qRearingBrood.BirdID) 

INNER JOIN 

				(SELECT tblBirdID.BirdID, 
				usys_qBroodEggDate.LayDate AS EggDate, 
				usys_qBroodHatchDate.HatchDate, 
				usys_qBroodEggDate.DateEstimated AS EggDateEst, 
				IIf(usys_qBroodHatchDate.BroodRef Is Not Null,usys_qBroodHatchDate.DateEstimated,0) AS HatchDateEst
				
				FROM ((tblBroods 
				LEFT JOIN 
				
						(SELECT tblBroods.BroodRef, 
						IIf(usys_qBroodTrueEggDate.LayDate,
						usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
						IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
						
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
				
				ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
				
				LEFT JOIN 
				
								(SELECT usys_qBroodsWithHatchlings.BroodRef, 
								IIf(usys_qBroodHatchDatesFromTable.HatchDate Is Not Null,usys_qBroodHatchDatesFromTable.HatchDate,usys_qBroodEggDate.LayDate+14) AS HatchDate, 
								usys_qBroodHatchDatesFromTable.HatchDate Is Null Or usys_qBroodHatchDatesFromTable.DateEstimated AS DateEstimated
								FROM (
								
										(SELECT DISTINCT tblBirdID.BroodRef, Count(*) AS NoHatchlings
										FROM tblBirdID
										WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null))
										GROUP BY tblBirdID.BroodRef) AS usys_qBroodsWithHatchlings 
								
								LEFT JOIN 
								
										(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS HatchDate, tblBroodEvents.DateEstimated
										FROM tblBroodEvents
										WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=1))) AS usys_qBroodHatchDatesFromTable 
								
								ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodHatchDatesFromTable.BroodRef) 
								
								LEFT JOIN 
								
										(SELECT tblBroods.BroodRef, 
										IIf(usys_qBroodTrueEggDate.LayDate,
										usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
										IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
										
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
								
								ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodEggDate.BroodRef) AS usys_qBroodHatchDate 
				
				ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
				
				INNER JOIN tblBirdID ON tblBroods.BroodRef = tblBirdID.BroodRef
				
				WHERE (((tblBirdID.BroodRef) Is Not Null))) AS usys_qBirdEggHatchDates 

ON tblCaptures.BirdID = usys_qBirdEggHatchDates.BirdID) 

LEFT JOIN 

			(SELECT tblExptTreatmentsApplied.BirdID, 
			tblExptTreatmentsApplied.TreatmentRef, 
			tblChickGrowthExpt.HatchPosition, 
			usys_qCodesTreatment.TreatmentName
			
			FROM (tblExptTreatments 
			LEFT JOIN 
			
					(SELECT tblExptTreatments.TreatmentRef, tblExptTreatments.TreatmentName, tblExperiments.ExperimentName
					FROM tblExperiments INNER JOIN tblExptTreatments ON tblExperiments.ExptRef = tblExptTreatments.ExperimentRef) AS usys_qCodesTreatment 
			
			ON tblExptTreatments.TreatmentRef = usys_qCodesTreatment.TreatmentRef) 
			INNER JOIN (tblExptTreatmentsApplied 
			LEFT JOIN tblChickGrowthExpt ON tblExptTreatmentsApplied.BirdID = tblChickGrowthExpt.BirdID) 
			ON tblExptTreatments.TreatmentRef = tblExptTreatmentsApplied.TreatmentRef
			
			WHERE (((tblExptTreatments.ExperimentRef)=1))) AS usys_qChickGrowthExptTreatment 

ON tblCaptures.BirdID = usys_qChickGrowthExptTreatment.BirdID) 

INNER JOIN 

			(SELECT tblMeasurements.CaptureRef, 
			Avg(tblMeasurements.Tarsus) AS Tarsus,
			Avg(tblMeasurements.BillLength) AS BillLength, 
			Avg(tblMeasurements.BillWidth) AS BillWidth, 
			Avg(tblMeasurements.TailLength) AS TailLength, 
			Avg(tblMeasurements.WingLength) AS WingLength, 
			Avg(tblMeasurements.Mass) AS Mass, 
			Avg(tblMeasurements.MeasureTime) AS MeasureTime, 
			First(usys_qRelativeChickMassClassesForCaptures.MassClass) AS MeasureDay
			
			FROM (tblMeasurements 
			INNER JOIN 
			
						(SELECT tblCaptures.CaptureRef, 
						Min(usys_tblRelativeChickMassClasses.MassDay) AS MassClass, 
						First(tblCaptures.CaptureDate-[HatchDate])+1 AS Age
						
						FROM usys_tblRelativeChickMassClasses, tblCaptures 
						INNER JOIN 
						
								(SELECT tblBirdID.BirdID, usys_qBroodEggDate.LayDate AS EggDate, 
								usys_qBroodHatchDate.HatchDate, 
								usys_qBroodEggDate.DateEstimated AS EggDateEst, 
								IIf(usys_qBroodHatchDate.BroodRef Is Not Null,usys_qBroodHatchDate.DateEstimated,0) AS HatchDateEst
								
								FROM ((tblBroods LEFT JOIN 
								
										(SELECT tblBroods.BroodRef, 
										IIf(usys_qBroodTrueEggDate.LayDate,
										usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
										IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
										
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
										
								ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef) 
								LEFT JOIN 
								
										(SELECT usys_qBroodsWithHatchlings.BroodRef, 
										IIf(usys_qBroodHatchDatesFromTable.HatchDate Is Not Null,usys_qBroodHatchDatesFromTable.HatchDate,usys_qBroodEggDate.LayDate+14) AS HatchDate, 
										usys_qBroodHatchDatesFromTable.HatchDate Is Null Or usys_qBroodHatchDatesFromTable.DateEstimated AS DateEstimated
										FROM (
										
												(SELECT DISTINCT tblBirdID.BroodRef, Count(*) AS NoHatchlings
												FROM tblBirdID
												WHERE (((tblBirdID.LastStage)>1) AND ((tblBirdID.BroodRef) Is Not Null))
												GROUP BY tblBirdID.BroodRef) AS usys_qBroodsWithHatchlings 
										
										LEFT JOIN 
										
												(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS HatchDate, tblBroodEvents.DateEstimated
												FROM tblBroodEvents
												WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=1))) AS usys_qBroodHatchDatesFromTable 
										
										ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodHatchDatesFromTable.BroodRef) 
										
										LEFT JOIN 
										
												(SELECT tblBroods.BroodRef, 
												IIf(usys_qBroodTrueEggDate.LayDate,
												usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
												IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
												
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
										
										ON usys_qBroodsWithHatchlings.BroodRef = usys_qBroodEggDate.BroodRef) AS usys_qBroodHatchDate 
								
								ON tblBroods.BroodRef = usys_qBroodHatchDate.BroodRef) 
								INNER JOIN tblBirdID ON tblBroods.BroodRef = tblBirdID.BroodRef
								
								WHERE (((tblBirdID.BroodRef) Is Not Null))) AS usys_qBirdEggHatchDates 
						
						ON tblCaptures.BirdID = usys_qBirdEggHatchDates.BirdID
						
						WHERE (((([tblCaptures].[CaptureDate]-[HatchDate])+1)<=[MassDay]) AND ((tblCaptures.Stage)<3))
						GROUP BY tblCaptures.CaptureRef) AS usys_qRelativeChickMassClassesForCaptures 
			
			ON tblMeasurements.CaptureRef = usys_qRelativeChickMassClassesForCaptures.CaptureRef) 
			INNER JOIN usys_tblRelativeChickMassClasses ON usys_qRelativeChickMassClassesForCaptures.MassClass = usys_tblRelativeChickMassClasses.MassDay
			
			WHERE (((usys_tblRelativeChickMassClasses.Display)=True))
			
			GROUP BY tblMeasurements.CaptureRef) AS usys_qRelativeChickMassAvgMeasuresByCapture 

ON (usys_qChickMassMeanSdMeasureDay.MeasureDay = usys_qRelativeChickMassAvgMeasuresByCapture.MeasureDay) 
AND (tblCaptures.CaptureRef = usys_qRelativeChickMassAvgMeasuresByCapture.CaptureRef)

WHERE (((tblCaptures.Stage)<3))

ORDER BY tblCaptures.BirdID, usys_qChickMassMeanSdMeasureDay.MeasureDay;
")



