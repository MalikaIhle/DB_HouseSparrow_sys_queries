-- sys_FecundityAnnualFemales --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 04/12/2015 --



-- error message:
--cannot find the query
SELECT distinct tblBirdID.BirdID, usys_qRearingBrood.RearingBrood
FROM (tblBirdID 
INNER JOIN tblAllCodes ON tblBirdID.BirdID = tblAllCodes.BirdID) 
INNER JOIN usys_qRearingBrood ON tblBird.BirdID = usys_qRearingBrood.BirdID

-- resolution 1:
--copypaste the following SQL code into the corrupted query usys_qBroodNindividsRinged
SELECT z.RearingBrood, Count(*) AS Nring
FROM (SELECT distinct [tblBirdID].[BirdID], 
[usys_qRearingBrood].[RearingBrood]
FROM (tblBirdID INNER JOIN tblAllCodes ON [tblBirdID].[BirdID] = 
[tblAllCodes].[BirdID]) INNER JOIN usys_qRearingBrood ON 
[tblBirdID].[BirdID] = [usys_qRearingBrood].[BirdID])  AS z
GROUP BY z.RearingBrood;

--resolution 2:
-- create usys_qBirdsRinged
SELECT distinct [tblBirdID].[BirdID], 
[usys_qRearingBrood].[RearingBrood]

FROM (tblBirdID 
INNER JOIN tblAllCodes ON [tblBirdID].[BirdID] = [tblAllCodes].[BirdID]) 
INNER JOIN usys_qRearingBrood ON [tblBirdID].[BirdID] = [usys_qRearingBrood].[BirdID]

-- and copy paste this SQL code into usys_qBroodNindividsRinged
SELECT usys_qBirdsRinged.RearingBrood, 
Count(*) AS Nring

FROM usys_qBirdsRinged

GROUP BY z.RearingBrood;







-- usys_qFecundSummaryFemaleAnnual

SELECT usys_qFecundFemalesAnnualTotals.FemaleID, 
usys_qFecundFemalesAnnualTotals.BreedYear, 
usys_qFecundFemalesAnnualTotals.NumberOfBroods, 
usys_qFecundFemalesPartnerCount.Npartners AS NumberOfSocialPartners, 
usys_qFecundFemalesAnnualTotals.TotalSocialDadEggsInNest, 
usys_qFecundFemalesAnnualTotals.TotalExtraPairEggsInNest, 
usys_qFecundFemalesAnnualTotals.TotalChicksRingedInNest, 
usys_qFecundFemalesAnnualTotals.TotalSocialDadOffspringFledgedInNest, 
usys_qFecundFemalesAnnualTotals.TotalExtraPairOffspringFledgedInNest, 
usys_qFecundFemalesAnnualTotals.TotalFosterOffspringFledgedInNest, 
usys_qFecundFemalesAnnualTotals.TotalOwnOffspringFledgedByFosters, 
usys_qFecundFemalesAnnualTotals.TotalExtraPairSires AS TotalEPPpartners, 
usys_qFecundFemalesAnnualTotals.TotalEPPsGainedByMate

FROM usys_qFecundFemalesAnnualTotals 
INNER JOIN usys_qFecundFemalesPartnerCount ON (usys_qFecundFemalesAnnualTotals.BreedYear=usys_qFecundFemalesPartnerCount.BreedYear) 
AND (usys_qFecundFemalesAnnualTotals.FemaleID=usys_qFecundFemalesPartnerCount.SocialMumID);


			-- usys_qFecundFemalesAnnualTotals

			SELECT usys_qFecundSummaryByNatalNest.SocialMumID AS FemaleID, 
			usys_qFecundSummaryByNatalNest.BreedYear, 
			Count(*) AS NumberOfBroods, 
			Sum(usys_qFecundSummaryByNatalNest.SocialDadEggs) AS TotalSocialDadEggsInNest, 
			Sum(usys_qFecundSummaryByNatalNest.ExtraPairEggs) AS TotalExtraPairEggsInNest, 
			Sum(usys_qFecundSummaryByNatalNest.SocialDadOffspringFledgedInNest) AS TotalSocialDadOffspringFledgedInNest, 
			Sum(usys_qFecundSummaryByNatalNest.ExtraPairOffspringFledgedInNest) AS TotalExtraPairOffspringFledgedInNest, 
			Sum(usys_qFecundSummaryByNatalNest.FosterOffspringFledgedInNest) AS TotalFosterOffspringFledgedInNest, 
			Sum(usys_qFecundSummaryByNatalNest.SocialMumOffspringFledgedByFosters) AS TotalOwnOffspringFledgedByFosters, 
			Int(nz(Sum([SimultaneousEPPsGainedByMate]),0)) AS TotalEPPsGainedByMate, 
			Sum(usys_qFecundSummaryByNatalNest.ExtraPairSireCount) AS TotalExtraPairSires, 
			Sum(usys_qFecundSummaryByNatalNest.NchicksRingedInNest) AS TotalChicksRingedInNest

			FROM usys_qFecundSummaryByNatalNest 
			LEFT JOIN usys_qFecundEPPsGainedBySocialDads ON usys_qFecundSummaryByNatalNest.NatalBrood=usys_qFecundEPPsGainedBySocialDads.BroodRef

			WHERE (((usys_qFecundSummaryByNatalNest.SocialMumID) Is Not Null))
			GROUP BY usys_qFecundSummaryByNatalNest.SocialMumID, usys_qFecundSummaryByNatalNest.BreedYear;


							-- usys_qFecundSummaryByNatalNest
							
							SELECT First(usys_qFecundEPPstatus.Cohort) AS BreedYear, 
							usys_qFecundEPPstatus.NatalBrood, 
							First(tblBroods.SocialMumID) AS SocialMumID, 
							First(tblBroods.SocialDadID) AS SocialDadID, 
							Abs(Sum(Not [EPPstatusIsGenetic] And Not [EPPstatus])) AS NumberSocialDadEggsUnconfirmed, 
							Abs(Sum(Not [EPPstatus])) AS SocialDadEggs, 		-- EPPStatus = -1 if yes, 0 if no ; 'Not [EPPStatus]' = -1 when WPP, 0 when EPP
							Abs(Sum(Not [EppStatus] And [LastStage]>1)) AS SocialDadOffspringHatched, 
							First(usys_qBroodNringedWithZeros.Nringed) AS NchicksRingedInNest, 
							Abs(Sum(IIf([Fostered],0,Not [EppStatus] And [LastStage]=3))) AS SocialDadOffspringFledgedInNest, 
							Abs(Sum(Not [EppStatus] And [Fostered])) AS SocialDadOffspringFostered, 
							Abs(Sum(IIf(Not [Fostered],0,Not [EppStatus] And [LastStage]=3))) AS SocialDadOffspringFledgedByFosters, 
							Abs(Sum([Fostered])) AS SocialMumOffspringFostered, 
							Abs(Sum(IIf(Not [Fostered],0,[LastStage]=3))) AS SocialMumOffspringFledgedByFosters, 
							Abs(Sum([Eppstatus])) AS ExtraPairEggs,				 -- EPPStatus = -1 if yes, 0 if no, abs(sum(EPPStatus)) counts the number of yes.
							Abs(Sum([LastStage]>1 And [EPPstatus])) AS ExtraPairOffspringHatched, 
							Abs(Sum([EppStatus] And [Fostered])) AS ExtraPairOffspringFostered, 
							Abs(Sum(IIf([Fostered],0,[LastStage]=3 And [EPPstatus]))) AS ExtraPairOffspringFledgedInNest, 
							IIf(First(usys_qFecundFosters.FosterOffspringAdded) Is Null,0,First(usys_qFecundFosters.FosterOffspringAdded)) AS FosterOffspringAddedToNest, 
							IIf(First(usys_qFecundFosters.FosterOffspringFledged) Is Null,0,First(usys_qFecundFosters.FosterOffspringFledged)) AS FosterOffspringFledgedInNest, 
							Int(nz(First([NExtraPairSires]),0)) AS ExtraPairSireCount
							
							FROM (((tblBroods 
							INNER JOIN usys_qFecundEPPstatus ON tblBroods.BroodRef=usys_qFecundEPPstatus.NatalBrood) 
							LEFT JOIN usys_qFecundFosters ON usys_qFecundEPPstatus.NatalBrood=usys_qFecundFosters.RearingBrood) 
							LEFT JOIN usys_qFecundExtraPairSireCountByBrood ON usys_qFecundEPPstatus.NatalBrood=usys_qFecundExtraPairSireCountByBrood.NatalBrood) 
							INNER JOIN usys_qBroodNringedWithZeros ON usys_qFecundEPPstatus.NatalBrood=usys_qBroodNringedWithZeros.RearingBrood
							
							GROUP BY usys_qFecundEPPstatus.NatalBrood;
							
							
									-- usys_qFecundEPPstatus
									
									SELECT tblBirdID.BirdID, 
									tblBirdID.Cohort, 
									tblBirdID.BroodRef AS NatalBrood, 
									usys_qRearingBrood.RearingBrood, 
									tblBirdID.broodref<>[RearingBrood] AS Fostered, -- give yes -1 ; No 0
																												-- HARD TO GO THROUGH THIS IF STATEMENT  !!! 
									IIf([UnidentifiedEPP]=False,												-- if UnidentifiedEPP = False = No = 0		
												IIf([dadid] Is Null Or [dadID]=[SocialDadid],False,True),		-- value if true: if no genetic dad or if genetic dad = social dad, then EPPStatus = False = No = 0, otherwise EPPStatus = True = -1
												IIf([UnidentifiedEPP],True,										-- value if false: if UnidentifiedEPP = True = yes = -1, then EPPStatus = True = -1 
												IIf(tblBirdID.BirdID Is Not Null,False,Null))) AS EPPstatus,	--                 otherwise if birdID is not null, then EPPStatus = False, otherwise EPPStatus = Null
																																		
												
									IIf([DadID] Is Not Null,True,														-- if genetic dad is not null, then EPPstatusIsGenetic = True = -1,
												IIf(usys_qGeneticParents.BirdID Is Not Null,[UnidentifiedEPP],			-- otherwise, if BirdID is not null, then EPPstatusIsGenetic = UnidentifiedEPP (i.e. True if unidentifiedEPP = yes, though without knowing genetic dad)
												IIf(tblBirdID.BirdID Is Not Null,False,Null))) AS EPPstatusIsGenetic,	--									otherwise, i.e. BirdID not in the query usys_qGeneticparents (which shouldn't be the case as even birds without genetic parents are selected in)
																														--									if BirdID is not null, EPPstatusIsGenetic = False, otherwise,  EPPstatusIsGenetic = Null
									
									tblBirdID.LastStage
									
									FROM tblBroods 
									INNER JOIN ((tblBirdID 
									INNER JOIN usys_qRearingBrood ON tblBirdID.BirdID = usys_qRearingBrood.BirdID) 
									LEFT JOIN usys_qGeneticParents ON tblBirdID.BirdID = usys_qGeneticParents.BirdID) ON tblBroods.BroodRef = tblBirdID.BroodRef
									
									WHERE (((tblBirdID.BroodRef) Is Not Null));
										
										
												-- usys_qRearingBrood
												
												SELECT tblBirdID.BirdID, 
												IIf([FosterBrood] Is Null,[BroodRef],[FosterBrood]) AS RearingBrood
												
												FROM tblBirdID 
												LEFT JOIN tblFosterBroods ON tblBirdID.BirdID = tblFosterBroods.BirdID
												
												WHERE (((tblBirdID.BroodRef) Is Not Null));
												
												
												-- usys_qGeneticParents
												
												SELECT tblBirdID.BirdID, 											-- this gets all BirdIDs even those who do not have any genetic parent
												tblGenPedigree.FatherID AS DadID, 
												IIf([tblGenPedigree].[UnidentifiedEPP] Is Null,0,[tblGenPedigree].[UnidentifiedEPP]) AS UnidentifiedEPP, 
												IIf([tblGenPedigree].[MotherID] Is Not Null,[tblGenPedigree].[MotherID],IIf([SocialMumCertain]=True,[SocialMumID],Null)) AS MumID -- assume genetic mum is always always social mum
												
												FROM tblBroods 
												RIGHT JOIN (tblBirdID 
												LEFT JOIN tblGenPedigree ON tblBirdID.BirdID = tblGenPedigree.BirdID) 
												ON tblBroods.BroodRef = tblBirdID.BroodRef;



									-- usys_qFecundFosters
									
									SELECT usys_qFecundEPPstatus.RearingBrood, 
									Count(*) AS FosterOffspringAdded, 
									Abs(Sum([LastStage]=3)) AS FosterOffspringFledged
									
									FROM usys_qFecundEPPstatus
									
									WHERE (((usys_qFecundEPPstatus.Fostered)=True))
									GROUP BY usys_qFecundEPPstatus.RearingBrood;
									
									

														
									-- usys_qFecundExtraPairSireCountByBrood	

									SELECT usys_qFecundExtraPairSires.NatalBrood, 
									Count(*) AS NExtraPairSires
									
									FROM usys_qFecundExtraPairSires
									GROUP BY usys_qFecundExtraPairSires.NatalBrood;
									
											
											-- usys_qFecundExtraPairSires
											
											SELECT usys_qGeneticParents.DadID AS ExtraPairSire, 
											First(usys_qFecundEPPstatus.Cohort) AS BreedYear, 
											usys_qFecundEPPstatus.NatalBrood, 
											First(usys_qBroodEggDate.LayDate) AS LayDate, 
											Count(*) AS EPPeggs, Abs(Sum([LastStage]>1)) AS EPPsHatched, -- does not included chiggs
											Abs(Sum([LastStage]=3)) AS EPPsFledged
											
											FROM (usys_qGeneticParents 
											INNER JOIN usys_qFecundEPPstatus ON usys_qGeneticParents.BirdID = usys_qFecundEPPstatus.BirdID) 
											INNER JOIN usys_qBroodEggDate ON usys_qFecundEPPstatus.NatalBrood = usys_qBroodEggDate.BroodRef

											WHERE (((usys_qFecundEPPstatus.EPPstatus)=True) AND ((usys_qGeneticParents.DadID) Is Not Null))	-- select only EPP genetically known
											GROUP BY usys_qGeneticParents.DadID, usys_qFecundEPPstatus.NatalBrood;

									

									-- usys_qBroodNringedWithZeros
									
									SELECT tblBroods.BroodRef AS RearingBrood, 
									Int(Switch(usys_qBroodNindividsRinged.RearingBrood Is Null And [OffspringNest] Is Null,0,		-- switch (expression1 is true, value1, otherwise, expression2 is true, value2...)
												[Nring]>=[OffspringNest],[Nring],
												[Nring]<[OffspringNest],[OffspringNest],
												[Nring] Is Null,[OffspringNest],
												True,[Nring])) AS Nringed

									FROM (usys_qBroodRingDate 
									RIGHT JOIN tblBroods ON usys_qBroodRingDate.BroodRef=tblBroods.BroodRef) 
									LEFT JOIN usys_qBroodNindividsRinged ON tblBroods.BroodRef=usys_qBroodNindividsRinged.RearingBrood;
									
									
											-- usys_qBroodNindividsRinged (resolution 1 above)

											SELECT z.RearingBrood, Count(*) AS Nring
											
											FROM 
											
													(SELECT distinct [tblBirdID].[BirdID], 
													[usys_qRearingBrood].[RearingBrood]
													FROM (tblBirdID INNER JOIN tblAllCodes ON [tblBirdID].[BirdID] = 
													[tblAllCodes].[BirdID]) INNER JOIN usys_qRearingBrood ON 
													[tblBirdID].[BirdID] = [usys_qRearingBrood].[BirdID])  AS z
											
											GROUP BY z.RearingBrood;




	
											-- usys_qBroodRingDate
											
											SELECT tblBroodEvents.BroodRef, 
											tblBroodEvents.EventDate AS RingDate, 
											tblBroodEvents.OffspringNest			-- brood size not estimated froun count in tbl.BirdID, but stated in the BroodEvent - subject to more errors ?
											
											FROM tblBroodEvents
											
											WHERE (((tblBroodEvents.OffspringNest)>0) AND ((tblBroodEvents.EventNumber)=3))	-- ringing visit
											ORDER BY tblBroodEvents.BroodRef;
		

			
							-- usys_qFecundEPPsGainedBySocialDads
			
							SELECT tblBroods.BroodRef, 
							Sum(usys_qFecundExtraPairSires.EPPeggs) AS SimultaneousEPPsGainedByMate
							
							FROM (tblBroods 
							INNER JOIN usys_qFecundExtraPairSires ON tblBroods.SocialDadID = usys_qFecundExtraPairSires.ExtraPairSire) 
							INNER JOIN usys_qFecundBroodDates ON (usys_qFecundExtraPairSires.BreedYear = usys_qFecundBroodDates.BreedYear) 
							AND (tblBroods.BroodRef = usys_qFecundBroodDates.BroodRef)
							
							WHERE ((([LayDate]-GetDBOption("OffsetDays")) Between [usys_qFecundBroodDates].[Startdate] And [usys_qFecundBroodDates].[Enddate]) 
							AND ((tblBroods.SocialMumID) Is Not Null))
							GROUP BY tblBroods.BroodRef;
							
							
									-- usys_qFecundBroodDates
									
									SELECT tblBroods.BroodRef, 
									usys_qBroodEggDate.LayDate AS StartDate, 
									[LayDate]+getdboption("AvgLayToFledgePeriod") AS EndDate, 
									Year([LayDate]) AS BreedYear
									
									FROM tblBroods 
									INNER JOIN usys_qBroodEggDate ON tblBroods.BroodRef = usys_qBroodEggDate.BroodRef;


			
			
			
			
			
			
			
			-- usys_qFecundFemalesPartnerCount
			
			SELECT usys_qFecundUniquePairsByYear.BreedYear, 
			usys_qFecundUniquePairsByYear.SocialMumID, 
			Count(*) AS Npartners 	-- nb lines  = nb of partner as usys_qFecundUniquePairsByYear has one line per PAIR even if they had several brood
			
			FROM usys_qFecundUniquePairsByYear
			
			WHERE (((usys_qFecundUniquePairsByYear.SocialMumID) Is Not Null))
			GROUP BY usys_qFecundUniquePairsByYear.BreedYear, usys_qFecundUniquePairsByYear.SocialMumID;


							-- usys_qFecundUniquePairsByYear
							
							SELECT Year([EventDate]) AS BreedYear, 
							tblBroods.SocialMumID, 
							tblBroods.SocialDadID
							
							FROM (tblBroods 
							INNER JOIN tblBirdID ON tblBroods.BroodRef = tblBirdID.BroodRef) 
							INNER JOIN tblBroodEvents ON tblBroods.BroodRef = tblBroodEvents.BroodRef
							
							WHERE (((tblBroodEvents.EventNumber)=0))	-- only brood seen at first egg, not those seen later (event = 4)
							GROUP BY Year([EventDate]), tblBroods.SocialMumID, tblBroods.SocialDadID; -- one line per PAIR even if they had several brood

























