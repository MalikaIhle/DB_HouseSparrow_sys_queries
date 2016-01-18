-- sys_Survival --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 24/11/2015 --


-- usys_qAdultSurvivalAndPopulation

SELECT usys_qAdultSurvivalByYear.BirdID, usys_qAdultSurvivalByYear.SparrowYear, usys_qAdultPopSize.AdultPopSize, 
[SparrowYear]-[Cohort] AS Age, 
usys_qSexEstimate.SexEstimate AS Sex

FROM (usys_qAdultSurvivalByYear 
INNER JOIN (tblBirdID INNER JOIN usys_qSexEstimate ON tblBirdID.BirdID = usys_qSexEstimate.BirdID) 
ON usys_qAdultSurvivalByYear.BirdID = tblBirdID.BirdID) 
INNER JOIN usys_qAdultPopSize ON usys_qAdultSurvivalByYear.SparrowYear = usys_qAdultPopSize.SparrowYear;


		-- usys_qSexEstimate: see query 'sys_SexEstimate'
		
		
		-- usys_qLastLiveRecord: see query 'sys_LastSeenAlive'
		
		
		-- usys_qAdultSurvivalByYear
		
		SELECT tblBirdID.BirdID, usys_qAdultSurvivalYears.SurvYear AS SparrowYear
		
		FROM usys_qAdultSurvivalYears, tblBirdID INNER JOIN usys_qLastLiveRecord ON tblBirdID.BirdID = usys_qLastLiveRecord.BirdID
		
		WHERE (((tblBirdID.LastStage)=3) -- post-fledgling
		AND ((tblBirdID.DeathDate)>DateSerial([SurvYear],getdboption("FirstDoDMonth"),getdboption("FirstDoDDay"))) -- dead after 1st of April of that year
		AND ((tblBirdID.Cohort)<=[SurvYear])) -- from a cohort past or current that year
		
		OR (((tblBirdID.LastStage)=3) -- post-fledgling
		AND ((tblBirdID.DeathDate) Is Null) -- no record of death yet
		AND ((tblBirdID.Cohort)<=[SurvYear]) -- from a cohort past or current that year
		AND ((usys_qLastLiveRecord.LastLiveRecord)>DateSerial([SurvYear]-getdboption("AWOLMax"),getdboption("FirstDoDMonth"),getdboption("FirstDoDDay"))))
											-- >>>>> was last seen alive after the 1st of April of the previous year <<<<<<<
											
		ORDER BY tblBirdID.BirdID, usys_qAdultSurvivalYears.SurvYear;


		---- in tblDataBaseSettings:
		----- AWOLMax: Maximum period allowed to elapse between Sightings. Resighting at intervals greater than this are flagged as worth checking. (years)
						-- set to be one year
		----- FirstDoDDay:Earliest date of death for inclusion in a population: Day of month
						-- set to be the 1st
		----- FirstDoDMonth: Earliest date of death for inclusion in a population: Month
						-- set to be April
						
						
		
					-- usys_qAdultSurvivalYears	
							
					SELECT Tens.digit*10+Units.Digit+2000 AS SurvYear
					FROM usys_tblDigits AS Units, 
					usys_tblDigits AS Tens
					WHERE ((([Tens].[digit]*10+[Units].[Digit]+2000) Between 2000 And IIf(Month(Date())>7,Year(Date()),Year(Date())-1)))	
																				---- Date() is the current system date
																				---- the above line means: keep the years that are in between 2000 and 
																				----- the current year if current date is after july
																				----- last year if before july
					ORDER BY Tens.digit*10+Units.Digit+2000;

								-- usys_tblDigit
								-- 1 column: Digit, cells from 0 to 9





		-- usys_qAdultPopSize

		SELECT usys_qAdultSurvivalByYear.SparrowYear, Count(*) AS AdultPopSize
		FROM tblBirdID INNER JOIN usys_qAdultSurvivalByYear ON tblBirdID.BirdID = usys_qAdultSurvivalByYear.BirdID
		WHERE ((([SparrowYear]-[Cohort])>0))
		GROUP BY usys_qAdultSurvivalByYear.SparrowYear;

















