#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	 Malika IHLE (mihle@orn.mpg.de)
#	 Breeding 2011
#	 Tutorial how to communicate between R and access
#	 Start : 11/01/2012 
#	 last modif : 11/01/2012
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

require(RODBC)
# con = odbcConnectAccess("T:\\Malika\\_CURRENT BACK UP\\ZebraFinchDBBielefeld.mdb")	# Update the path
# sqlTables(con)

#when DB is in the file where this script is and when R run on 32 bits
con = odbcConnectAccess("ZebraFinchDBBielefeld.mdb")	# make a connection to the database (the database look opened)
sqlTables(con)	# list all the tables in the DB



# read table and use them as.data.frame in R

Basic_Individuals = sqlFetch(con, "Basic_Individuals")
length (Basic_Individuals$Ind_ID)
head (Basic_Individuals)
names (Basic_Individuals)


# write queries in SQL and use them as.data.frame, or when create a query in Creation Mode in Access, pass in SQL, copy paste within the strings
# R will read the tables in the DB even if they are not called in this script directly as the one above

Eggs = sqlQuery (con, 
"
SELECT Breed_EggsLaid.EggID,
Breed_EggsLaid.Pair_ID, 
Breed_EggsLaid.ClutchID, 
Breed_EggsLaid.Treatments, 
Breed_EggsLaid.EggNoClutch, 
Breed_EggsLaid.EggVolume, 
Breed_EggsLaid.FertileYN, 
Breed_EggsLaid.EggFate, 
Breed_Clutches.EPT
FROM Breed_Clutches 
INNER JOIN Breed_EggsLaid 
ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID
ORDER BY Breed_EggsLaid.Pair_ID, Breed_EggsLaid.ClutchID;
"
)



##  PUT THE STRINGS ' ' AROUND 'A' FOR AVIARY INSTEAD OF " " (access read both, R just one) !!

Pairs = sqlQuery(con, 
"
SELECT Breed_Clutches.ClutchID, 
Breed_Clutches.Aviary, 
Breed_Clutches.F_ID, 
Breed_Clutches.Treatments, 
Breed_Clutches.ClutchNo, 
Breed_Clutches.EPT, 
Breed_Clutches.Pair_ID, 
Breed_Clutches.ClutchStart, 
Breed_Clutches.ClutchEnd, 
Breed_Clutches.StartIncubation, 
Breed_Clutches.ClutchSize
FROM (Breed_Clutches)
WHERE (((Breed_Clutches.CageAviary)='A') AND ((Breed_Clutches.ClutchSize)<>0))
ORDER BY (Breed_Clutches.Pair_ID);
"
)



# Query based on a previous query : copy paste in brackets () the previous query in the FROM part of the new query following by AS name of the previous query


Clutch1 <- sqlQuery(con, 
"SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.F_ID, Breed_Clutches.Pair_ID, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.LayingDate, [LayingDate]-[ClutchStart] AS Delay, Breed_EggsLaid.Treatments
FROM Breed_Clutches INNER JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID
WHERE (((Breed_Clutches.ClutchNo)=1) AND ((Breed_Clutches.EPT)=1) AND ((Breed_Clutches.ClutchSize)<>0) AND ((Breed_EggsLaid.EggNoClutch)=1) AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_Clutches.Pair_ID;
")


Pairs <- sqlQuery(con, 
"SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.ClutchNo, Breed_Clutches.EPT, Breed_Clutches.Pair_ID, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Clutch1.ClutchStart AS Pairing_date

FROM Breed_Clutches INNER JOIN 

	(  SELECT Breed_Clutches.ClutchID, Breed_Clutches.Aviary, Breed_Clutches.F_ID, Breed_Clutches.Treatments, Breed_Clutches.ClutchNo, Breed_Clutches.EPT, Breed_Clutches.Pair_ID, Breed_Clutches.ClutchStart, Breed_Clutches.ClutchEnd, Breed_Clutches.StartIncubation, Breed_Clutches.ClutchSize, Breed_EggsLaid.LayingDate, Breed_EggsLaid.EggNoClutch
	FROM Breed_Clutches INNER JOIN Breed_EggsLaid ON Breed_Clutches.ClutchID = Breed_EggsLaid.ClutchID
	WHERE (((Breed_Clutches.ClutchNo)=1) AND ((Breed_Clutches.ClutchSize)<>0) AND ((Breed_Clutches.CageAviary)='A') AND ((Breed_EggsLaid.EggNoClutch)=1))
	) as  Clutch1 

ON Breed_Clutches.Pair_ID = Clutch1.Pair_ID
WHERE (((Breed_Clutches.ClutchSize)<>0) AND ((Breed_Clutches.CageAviary)='A'))
ORDER BY Breed_Clutches.Pair_ID;
")



	close(con) 	# close the connection to the database
	