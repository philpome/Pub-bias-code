setwd("C:/Users/Megan/Desktop/Python/pub-bias/Pub-bias-code-master")
library("jsonlite", lib.loc="~/R/win-library/3.3")
pbdata<-fromJSON("workingDataset.json",flatten=TRUE)
pbdata<-pbdata$data
library("ggplot2", lib.loc="~/R/win-library/3.3")
test<-ggplot(pbdata, aes(`Plant species (higher), threatened`,mismatch,color=factor(subregion)))+geom_jitter()
test
#make a flat dataset for the first few tests:
#change NA's in the dataset to 0's
pbdata$`Plant species (higher), threatened`[is.na(pbdata$`Plant species (higher), threatened`)]<-0
pbdata$authorRepresentation[is.na(pbdata$authorRepresentation)]<-0
pbdata$`Scientific and technical journal articles`[is.na(pbdata$`Scientific and technical journal articles`)]<-0
#sum all the publications by for each country by year
nump<-aggregate(authorRepresentation~country, pbdata, sum)
#sum all the threatened plants by year
planty<-aggregate(`Plant species (higher), threatened`~country,pbdata,sum)
#sum all the gbif data by year
bify<-aggregate(gbifDiversity~country,pbdata,mean)
#merge all the datasets together
numplanty<-merge(nump,planty,by="country")
pubsbydiv<-merge(numplanty,bify,by="country")
#sum all the publications by for each country by year
nump.wb<-aggregate(`Scientific and technical journal articles`~country, pbdata, sum)
#merge this into the pubs by div dataset
pubsbydiv<-merge(pubsbydiv,nump.wb,by="country")
#create the biodiversity variable
pubsbydiv$aggDiversity<-pubsbydiv$`Plant species (higher), threatened`/pubsbydiv$gbifDiversity
#add in development to pubsbydiv
developy<-data.frame("country"=pbdata$country,"development"=pbdata$development)
developy<-unique(developy)
pubsbydiv<-merge(pubsbydiv,developy,by="country")
#look at it
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
#does development have an effect on productivity?
shapiro.test(pubsbydiv$authorRepresentation)
shapiro.test(pubsbydiv$`Scientific and technical journal articles`)
#neither dataset is normal, so let's use KW
kruskal.test(pubsbydiv$authorRepresentation,pubsbydiv$development)
kruskal.test(pubsbydiv$`Scientific and technical journal articles`,pubsbydiv$development)
#okay, let's make a model of author representation:
model1<-glm(authorRepresentation~subregion+development+`GDP per capita, PPP (constant 2011 international $)`+`Political Stability and Absence of Violence/Terrorism: Estimate`, data=pbdata, family="poisson")
summary(model1)
modelqp<-glm(authorRepresentation~subregion+development+`GDP per capita, PPP (constant 2011 international $)`+`Political Stability and Absence of Violence/Terrorism: Estimate`, data=pbdata, family="quasipoisson")
summary(modelqp)
modelnb<-glm.nb(authorRepresentation~subregion+development+`GDP per capita, PPP (constant 2011 international $)`+`Political Stability and Absence of Violence/Terrorism: Estimate`, data=pbdata)
summary(modelnb)
