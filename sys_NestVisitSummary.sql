-- sys_NestVisitSummary --
-- House sparrow DB --
-- Ian Stevensson -- 

-- Notes from Malika --
-- 25/04/2016 --


-- usys_qNestVisitsFinal

SELECT 
usys_qNestVisitsCountSummary.DVDRef, 
tblDVDInfo.TapeLength, 
[TapeLength]-[MinofStartTime] AS EffectiveLength, 
IIf([VisitOverlap] Is Null,0,[VisitOverlap]) AS MaleFemaleOverlap, 
usys_qNestVisitsCountSummary.FemaleFeedCount,
 usys_qNestVisitsCountSummary.FemaleNonFeedCount, 
 usys_qNestVisitsCountSummary.MaleFeedCount, 
 usys_qNestVisitsCountSummary.MaleNonFeedCount, 
 usys_qNestVisitsTimeSummary.FemaleFeedTime, 
 usys_qNestVisitsTimeSummary.FemaleNonFeedTime, 
 usys_qNestVisitsTimeSummary.MaleFeedTime, 
 usys_qNestVisitsTimeSummary.MaleNonFeedTime
 
FROM (((tblDVDInfo 
INNER JOIN usys_qNestVisitsFirstVisit 
ON (tblDVDInfo.DVDRef = usys_qNestVisitsFirstVisit.DVDRef) 
AND (tblDVDInfo.DVDRef = usys_qNestVisitsFirstVisit.DVDRef) 
AND (tblDVDInfo.DVDRef = usys_qNestVisitsFirstVisit.DVDRef)) 

INNER JOIN usys_qNestVisitsCountSummary 
ON tblDVDInfo.DVDRef = usys_qNestVisitsCountSummary.DVDRef) 

INNER JOIN usys_qNestVisitsTimeSummary 
ON tblDVDInfo.DVDRef = usys_qNestVisitsTimeSummary.DVDRef) 

LEFT JOIN usys_qNestVisitsOverlap ON usys_qNestVisitsFirstVisit.DVDRef = usys_qNestVisitsOverlap.DVDRef;



	-- NestVisitsFirstVisits
	
	SELECT tblNestVisits.DVDRef, 
	Min(tblNestVisits.StartTime) AS MinOfStartTime
	FROM tblNestVisits
	GROUP BY tblNestVisits.DVDRef;



	-- NestVisitCountSummary
	
	TRANSFORM Count(*) AS NVisits
	SELECT tblNestVisits.DVDRef
	FROM tblNestVisits LEFT JOIN usys_qCodesSex ON tblNestVisits.Sex = usys_qCodesSex.Sex
	WHERE (((tblNestVisits.Sex) Is Not Null))
	GROUP BY tblNestVisits.DVDRef
	PIVOT [SexLabel] & IIf([State]='A','NonFeedCount','FeedCount') In ("FemaleNonFeedCount","FemaleFeedCount","MaleNonFeedCount","MaleFeedCount");

			-- CodeSex
			Sex	SexLabel
			0	Female
			1	Male
			
			
	-- NestVisitsTimeSUmmary

	TRANSFORM Sum([EndTime]-[StartTime]) AS TotalLength
	SELECT tblNestVisits.DVDRef
	FROM tblNestVisits LEFT JOIN usys_qCodesSex ON tblNestVisits.Sex = usys_qCodesSex.Sex
	WHERE (((tblNestVisits.Sex) Is Not Null))
	GROUP BY tblNestVisits.DVDRef
	PIVOT [SexLabel] & IIf([State]='A','NonFeedTime','FeedTime') In ("FemaleNonFeedTime","FemaleFeedTime","MaleNonFeedTime","MaleFeedTime");

	
	
	-- NestVisitsOverlap
	
	SELECT 
	usys_qNestVisitsFemale.DVDRef, 
	Sum(CalculateNestVisitOverlap([Mstart],[Mend],[FStart],[Fend])) AS VisitOverlap
	
	FROM usys_qNestVisitsFemale 
	
	INNER JOIN 
	
	usys_qNestVisitsMale ON usys_qNestVisitsFemale.DVDRef = usys_qNestVisitsMale.DVDRef -- only when feeding
	
	WHERE (((usys_qNestVisitsMale.MStart)<[FEnd]) AND ((usys_qNestVisitsMale.MEnd)>[FStart]))
	
	GROUP BY usys_qNestVisitsFemale.DVDRef;

	
			-- NestVisitFemale
			
			SELECT tblNestVisits.DVDRef, tblNestVisits.Sex, tblNestVisits.StartTime AS FStart, tblNestVisits.EndTime AS FEnd
			FROM tblNestVisits
			WHERE (((tblNestVisits.Sex)=0) AND ((tblNestVisits.State)<>'A')); -- only when feeding

				
			-- NestVisitMale
			
			SELECT tblNestVisits.DVDRef, tblNestVisits.Sex, tblNestVisits.StartTime AS MStart, tblNestVisits.EndTime AS MEnd
			FROM tblNestVisits
			WHERE (((tblNestVisits.Sex)=1) AND ((tblNestVisits.State)<>'A')); -- only when feeding
