pbdata$mismatch[is.na(pbdata$mismatch)] <- 0
pbdata$allMismatch[is.na(pbdata$allMismatch)] <- 0
pbdata$DI[is.na(pbdata$DI)] <- 0
pbdata$AI[is.na(pbdata$AI)] <- 0
pbdata$PlantsTotal[is.na(pbdata$PlantsTotal)] <- 0
pbdata$PlantsEndemic[is.na(pbdata$PlantsEndemic)] <- 0


numpubs <- aggregate(cbind(`Plant species (higher), threatened` , gbifDiversity, DI, AI, PlantsTotal, PlantsEndemic , authorRepresentation , mismatch , allMismatch , `Land area (sq. km)`) ~ country + development,pbdata,sum)
numpubs$gbifDiversity <- numpubs$gbifDiversity/37
numpubs$`Land area (sq. km)` <- numpubs$`Land area (sq. km)`/37
numpubs$AI <- numpubs$AI/37
numpubs$DI <- numpubs$DI/37
numpubs$PlantsTotal <- numpubs$PlantsTotal/37
numpubs$PlantsEndemic <- numpubs$PlantsEndemic/37

#linear model to determine slope and intercept of log diversity relative to log land area
lm(log(np$gbifDiversity)~log(np$`Land area (sq. km)`))

numpubs$expectedDiv <- exp(4.918 + (0.285*log(numpubs$`Land area (sq. km)`))) ##based on linear model
numpubs$deviance <- log(numpubs$gbifDiversity) - log(numpubs$expectedDiv)   ##gbif richness minus expected richness based on area
