pbdata$mismatch[is.na(pbdata$mismatch)] <- 0
pbdata$allMismatch[is.na(pbdata$allMismatch)] <- 0
pbdata$DI[is.na(pbdata$DI)] <- 0
pbdata$AI[is.na(pbdata$AI)] <- 0
pbdata$PlantsTotal[is.na(pbdata$PlantsTotal)] <- 0
pbdata$PlantsEndemic[is.na(pbdata$PlantsEndemic)] <- 0


np<- aggregate(cbind(`Plant species (higher), threatened` , gbifDiversity, DI, AI, PlantsTotal, PlantsEndemic , authorRepresentation , mismatch , allMismatch , `Land area (sq. km)`) ~ country + development,pbdata,sum)
np$gbifDiversity <- np$gbifDiversity/37
np$`Land area (sq. km)` <- np$`Land area (sq. km)`/37
np$AI <- np$AI/37
np$DI <- np$DI/37
np$PlantsTotal <- np$PlantsTotal/37
np$PlantsEndemic <- np$PlantsEndemic/37

np$PlantsTotal[np$PlantsTotal == 0] <- NA
np$AI[np$AI == 0] <- NA

lm(log(np$gbifDiversity)~log(np$`Land area (sq. km)`))
lm(log(np$PlantsTotal)~log(np$`Land area (sq. km)`))

np$GBIFexpectedDiv <- exp(4.918 + (0.285*log(np$`Land area (sq. km)`))) ##based on linear model with gbif data
np$GBIFdeviance <- log(np$gbifDiversity) - log(np$GBIFexpectedDiv)   ##gbif richness minus expected richness based on area

np$UNexpectedDiv <- exp(4.415 + (0.3124*log(np$`Land area (sq. km)`))) ##based on linear model with UN Data
np$UNdeviance <- log(np$PlantsTotal) - log(np$UNexpectedDiv)   ##Un plant species richness minus expected richness based on area

