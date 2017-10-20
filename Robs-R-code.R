require(jsonlite)
require(ggplot2)
require(lme4)
require(MASS)

pbdata <- fromJSON('~/Documents/PubBiasJazz/Pub-bias-code/workingDataset.json')
pbdata <- pbdata$data
attach(pbdata)

pbdata$authorRepresentation[is.na(pbdata$authorRepresentation)] <- 0
pbdata$`Plant species (higher), threatened`[is.na(pbdata$`Plant species (higher), threatened`)] <- 0
pbdata$DI <- as.numeric(pbdata$DI)
pbdata$AI <- as.numeric(pbdata$AI)
pbdata$PlantsTotal <- as.numeric(pbdata$PlantsTotal)
pbdata$PlantsEndemic <- as.numeric(pbdata$PlantsEndemic)


numpubs <- aggregate(cbind(`Plant species (higher), threatened`,gbifDiversity,authorRepresentation) ~ country + development,pbdata,sum)

numpubs$gbifDiversity <- numpubs$gbifDiversity/38

numpubs$tOd <- numpubs$`Plant species (higher), threatened`/numpubs$gbifDiversity

test<-ggplot(pbdata, aes(`Plant species (higher), threatened`,mismatch,color=factor(subregion)))+geom_jitter()
test

#change NA's in the dataset to 0's (may need to do for authorRep too)
pbdata$`Plant species (higher), threatened`[is.na(pbdata$`Plant species (higher), threatened`)]<-0

#sum all the publications by for each country by year
nump<-aggregate(authorRepresentation~country, pbdata, sum)

#sum all the threatened plants by year
planty<-aggregate(`Plant species (higher), threatened`~country,pbdata,sum)

#sum all the gbif data by year
bify<-aggregate(gbifDiversity~country,pbdata,mean)

#merge all the datasets together
numplanty<-merge(nump,planty,by="country")
pubsbydiv<-merge(numplanty,bify,by="country")

#create the biodiversity variable

pubsbydiv$aggDiversity<-pubsbydiv$`Plant species (higher), threatened`/pubsbydiv$gbifDiversity
plot(pubsbydiv$authorRepresentation~pubsbydiv$aggDiversity)

#test for correlation

cor.test(pubsbydiv$authorRepresentation, pubsbydiv$aggDiversity, method="spearman")
cor.test(pubsbydiv$authorRepresentation, pubsbydiv$aggDiversity, method="kendall")

#that was dumb, try it with a linear model instead

model1<-glm(authorRepresentation~aggDiversity, data=pubsbydiv, family="poisson")
summary(model1)

#that's overdispersed, try a quasi-poisson or negative binomial model

model2<-glm(authorRepresentation~aggDiversity, data=pubsbydiv, family="quasipoisson")
summary(model2)

model3<-glm.nb(authorRepresentation~aggDiversity, data=pubsbydiv)
summary(model3)

#let's go with the nb model

#Negative binomial model for author representation as a function of UN's diversity index
model.nb.ar <- glm.nb(np$authorRepresentation ~ np$AI)
summary(model.nb.ar)

#Negative binomial model for all mismatches as a function of UN's biodiversity index
model.nb.amm <- glm.nb(np$allMismatch ~ np$AI)
summary(model.nb.amm)

#Negative binomial model for collaborations as a function of UN's biodiversity index
model.nb.collab <- glm.nb(np$collab ~ np$AI)
summary(model.nb.collab)

