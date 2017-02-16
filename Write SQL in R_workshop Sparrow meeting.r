#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	 Malika IHLE (malika_ihle@hotmail.fr)
#	 Workshop SQL in R - sparro meeting 20170215
#	 Tutorial how to communicate between R and access
#	 Start : 11/02/2017
#	 last modif : 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm(list = ls(all = TRUE))

require(RODBC)
conDB= odbcConnectAccess("C:\\Users\\Malika\\Documents\\_Malika_Sheffield\\_CURRENT BACKUP\\db\\SparrowData.mdb")
sqlTables(conDB)

# read table and use them as.data.frame in R

tblBroodEvents = sqlFetch(conDB, "tblBroodEvents")
nrow (tblBroodEvents)
head (tblBroodEvents)
names (tblBroodEvents)


# write queries in SQL and use them as.data.frame, or when create a query in Creation Mode in Access, pass in SQL, copy paste within the strings
# R will read the tables in the DB even if they are not called in this script directly as the one above

usys_qBroodTrueEggDate = sqlQuery (conDB, 
"
SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
FROM tblBroodEvents
WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))									
")

usys_qBroodEggDateFromFirstSeen = sqlQuery (conDB,
"SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
FROM tblBroodEvents
WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=4))
")									# mistake in orginal sys_query: I replaced 0 by 4



# Query based on a previous query : copy paste in brackets () the previous query in the FROM part of the new query following by AS name of the previous query

usys_qBroodEggDate <- sqlQuery(conDB, 
"SELECT tblBroods.BroodRef, 
IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated
FROM (usys_qBroodTrueEggDate 
RIGHT JOIN tblBroods ON usys_qBroodTrueEggDate.BroodRef=tblBroods.BroodRef) 
LEFT JOIN usys_qBroodEggDateFromFirstSeen ON tblBroods.BroodRef=usys_qBroodEggDateFromFirstSeen.BroodRef
WHERE (((IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate)) Is Not Null))
")
# this isn't working in R because R can only call table and not queries from the database (R reads in the DATA part not the front end)


usys_qBroodEggDate <- sqlQuery(conDB, 
"
SELECT tblBroods.BroodRef, 
IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate) AS LayDate, 
IIf(usys_qBroodTrueEggDate.BroodRef,usys_qBroodTrueEggDate.DateEstimated,True) AS DateEstimated

FROM 	((SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
		FROM tblBroodEvents
		WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=0))) AS usys_qBroodTrueEggDate 


RIGHT JOIN tblBroods ON usys_qBroodTrueEggDate.BroodRef=tblBroods.BroodRef) 

LEFT JOIN 
		(SELECT tblBroodEvents.BroodRef, tblBroodEvents.EventDate AS LayDate, tblBroodEvents.DateEstimated
		FROM tblBroodEvents
		WHERE (((tblBroodEvents.EventDate) Is Not Null) AND ((tblBroodEvents.EventNumber)=4))) AS usys_qBroodEggDateFromFirstSeen 


ON tblBroods.BroodRef=usys_qBroodEggDateFromFirstSeen.BroodRef

WHERE (((IIf(usys_qBroodTrueEggDate.LayDate,usys_qBroodTrueEggDate.LayDate,usys_qBroodEggDateFromFirstSeen.LayDate)) Is Not Null))
")



	close(conDB) 	# close the connection to the database
	









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
