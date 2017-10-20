#Create empty vector for each of the columns in the aggregated dataframe.
#These will be filled with the for loop based on how we want them aggregated (sum, mean, etc...).
np.country <- vector()
np.development <- vector()
np.region <- vector()
np.subregion <- vector()
np.LandArea <- vector()
np.gbifDiversity <- vector()
np.DI <- vector()
np.AI <- vector()
np.PlantsTotal <- vector()
np.PlantsEndemic <- vector()
np.authorRepresentation <- vector()
np.mismatch <- vector()
np.allMismatch <- vector()

#For loop that creates an index number for each country, 
#then aggregates the temporal data to country summaries based on how we want that data aggregated (sum,mean,factor).

for (i in seq(length(unique(pbdata$country)))) { 

  np.country[i] <- unique(pbdata$country)[i]
  np.development[i] <- unique(pbdata$development[pbdata$country==unique(pbdata$country)[i]])
  np.region[i] <- unique(pbdata$region[pbdata$country==unique(pbdata$country)[i]])
  np.subregion[i] <- unique(pbdata$subregion[pbdata$country==unique(pbdata$country)[i]])
  np.LandArea[i] <- mean(pbdata$`Land area (sq. km)`[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.gbifDiversity[i] <- mean(pbdata$gbifDiversity[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.DI[i] <- mean(pbdata$DI[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.AI[i] <- mean(pbdata$AI[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.PlantsTotal[i] <- mean(pbdata$PlantsTotal[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.PlantsEndemic[i] <- mean(pbdata$PlantsEndemic[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.authorRepresentation[i] <- sum(pbdata$authorRepresentation[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.mismatch[i] <- sum(pbdata$mismatch[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  np.allMismatch[i] <- sum(pbdata$allMismatch[pbdata$country==unique(pbdata$country)[i]],na.rm=TRUE)
  
}

#Data columns are then bound to a dataframe
np <- data.frame(country = np.country,
                 development = np.development,
                 region = np.region,
                 subregion = np.subregion,
                 LandArea = np.LandArea,
                 gbifDiversity = np.gbifDiversity,
                 DI = np.DI,
                 AI = np.AI,
                 PlantsTotal = np.PlantsTotal,
                 PlantsEndemic = np.PlantsEndemic,
                 authorRepresentation = np.authorRepresentation,
                 mismatch = np.mismatch,
                 allMismatch = np.allMismatch
  
)

#create column that shows collaboration by subtracting allMismatches from mismatches
np$collab <- np$mismatch - np$allMismatch

#Linear models of richness as a function of area are used to find the equation of a best fit line.
#We can use that best fit line to determine the expected richness based on the area of the country.
#If the variation from the expected biodiversity shows a relative richness normalizing for land area.

lm(log(np$gbifDiversity)~log(np$LandArea))
lm(log(np$PlantsTotal)~log(np$LandArea))

np$GBIFexpectedDiv <- exp(4.9644 + (0.2816*log(np$LandArea))) ##based on linear model with gbif data
np$GBIFdeviance <- log(np$gbifDiversity) - log(np$GBIFexpectedDiv)   ##gbif richness minus expected richness based on area

np$UNexpectedDiv <- exp(4.4798 + (0.3074*log(np$LandArea))) ##based on linear model with UN Data
np$UNdeviance <- log(np$PlantsTotal) - log(np$UNexpectedDiv)   ##Un plant species richness minus expected richness based on area
