np.country <- vector()
np.development <- vector()
np.LandArea <- vector()
np.gbifDiversity <- vector()
np.DI <- vector()
np.AI <- vector()
np.PlantsTotal <- vector()
np.PlantsEndemic <- vector()
np.authorRepresentation <- vector()
np.mismatch <- vector()
np.allMismatch <- vector()

for (i in seq(length(unique(pbdata$country)))) { 

  np.country[i] <- unique(pbdata$country)[i]
  np.development[i] <- unique(pbdata$development[pbdata$country==unique(pbdata$country)[i]])
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

np <- data.frame(country = np.country,
                 development = np.development,
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


lm(log(np$gbifDiversity)~log(np$LandArea))
lm(log(np$PlantsTotal)~log(np$LandArea))

np$GBIFexpectedDiv <- exp(4.9644 + (0.2816*log(np$LandArea))) ##based on linear model with gbif data
np$GBIFdeviance <- log(np$gbifDiversity) - log(np$GBIFexpectedDiv)   ##gbif richness minus expected richness based on area

np$UNexpectedDiv <- exp(4.4798 + (0.3074*log(np$LandArea))) ##based on linear model with UN Data
np$UNdeviance <- log(np$PlantsTotal) - log(np$UNexpectedDiv)   ##Un plant species richness minus expected richness based on area
