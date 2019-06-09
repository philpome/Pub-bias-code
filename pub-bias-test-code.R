#### Headspace ####
setwd("C:/Users/Megan/Desktop/Python/pub-bias/Pub-bias-code-master")
setwd("C:/Users/Ben/Documents/School Jazz/Lab Work/PubBias/RobsCode2019/Pub-bias-code/")

library("jsonlite") # need to pull from json
library("ggplot2") # who wouldn't
library("MASS") # for the negative-binom glm
library("ggrepel") # labeling points that don't overlap in ggplot
library("lme4")
library("pscl")
library("dplyr")
library("plyr")


#### Dataset prep ####
pbdata<-fromJSON("workingDataset.json",flatten=TRUE)
pbdata<-pbdata$data
pbdata$DI<-as.numeric(pbdata$DI)
pbdata$AI<-as.numeric(pbdata$AI)
pbdata$PlantsTotal<-as.numeric(pbdata$PlantsTotal)
pbdata$PlantsEndemic<-as.numeric(pbdata$PlantsEndemic)
View(pbdata)

test<-ggplot(pbdata, aes(`Plant species (higher), threatened`,mismatch,color=factor(subregion)))+geom_jitter()
test

# pulling WB economic data:
WBdata<-pbdata %>% group_by(country) %>% summarise_at(.vars = vars(
  "Population, total",                               
  "Agricultural land (% of land area)",                               
  "Human development index (HDI)",                               
  "Land area (sq. km)",                               
  "Educational attainment, at least Bachelor's or equivalent, population 25+, total (%) (cumulative)",
  "GINI index (World Bank estimate)",                               
  "Poverty headcount ratio at national poverty lines (% of population)",
  "GDP per capita, PPP (constant 2011 international $)",
  "Children in employment, total (% of children ages 7-14)",
  "Political Stability and Absence of Violence/Terrorism: Estimate",
  "Political Stability/No Violence (estimate)",
  "Research and development expenditure (% of GDP)",
  "Researchers in R&D (per million people)",
  "Total outbound internationally mobile tertiary students studying abroad, all countries, both sexes (number)",
  "Expenditure on tertiary as % of total government expenditure (%)",
  "Graduates from tertiary education, both sexes (number)",
  "Scientific and technical journal articles"),.funs=mean,na.rm=TRUE)

# Author representation:
authrep<-pbdata %>% group_by(country) %>% summarise_at(.vars = vars(
  "authorRepresentation",
  "allMismatch",
  "mismatch",
  "firstAuthorMismatch",
  "lastAuthorMismatch",
  "singleAuthorMismatch",
  "middleAuthorMismatch"),
  .funs=sum,na.rm=TRUE)

#Biodiversity indices
biodiv<-pbdata %>% group_by(country) %>% summarise_at(.vars = vars(
  "gbifDiversity",
  "Land area (sq. km)",
  "DI",
  "AI",
  "Animal species, threatened",
  "Mammal species, threatened",
  "Plant species (higher), threatened",
  "Fish species, threatened",
  "Bird species, threatened"),
  .funs=mean,na.rm=TRUE)

#Traditional diversity index addition and newer:
biodiv$spbyarea<-biodiv$gbifDiversity/biodiv$`Land area (sq. km)`
biodiv$aggdiv<-biodiv$`Plant species (higher), threatened`/biodiv$gbifDiversity
# add AvTD:
avtd<-read.csv("AvTD_by_country.csv", header=T)
avtd$country<-as.character(avtd$country)
biodivind<-full_join(biodiv,avtd,by="country") #bring them together

# Bring them all together:
dflist<-list(WBdata,authrep,biodivind)
View(dflist)
pubda<-join_all(dflist,by="country", type="full")
pubda<-pubda[-c(250),] # Macao is only in the AvTD dataset and need to be removed
pubda<-rename(pubda, avtd = `AvTD`)
View(pubda)

attach(pubda)


#### Plots ####
# Compare diversity indices
#AvTD by...
ggplot(data=pubda,aes(AvTD,aggdiv))+geom_point()+geom_smooth(method="lm")
cor.test(AvTD,aggdiv) # r = 0.33
ggplot(data=pubda,aes(AvTD,Richness))+geom_point()+geom_smooth(method="lm")
cor.test(AvTD,Richness) # r = 0.082
ggplot(data=pubda,aes(AvTD,log(spbyarea)))+geom_point()+geom_smooth(method="lm")
cor.test(AvTD,log(spbyarea)) # r = 0.36
#Richness by...
ggplot(data=pubda,aes(Richness,aggdiv))+geom_point()+geom_smooth(method="lm")
cor.test(Richness,aggdiv) # r = 0.17
ggplot(data=pubda,aes(log(Richness),log(spbyarea)))+geom_point()+geom_smooth(method="lm")
cor.test(Richness,log(spbyarea)) # r = -0.27 something weird about dividing richness (GBIF) by area and then plotting against (essentially) itself.
ggplot(data=pubda,aes(log(Richness),log(`Land area (sq. km)`)))+geom_point()+geom_smooth(method="lm")
ggplot(data=pubda,aes(log(Richness),log(gbifDiversity)))+geom_point()+geom_smooth(method="lm")
ggplot(data=pubda,aes(spbyarea,log(gbifDiversity)))+geom_point()+geom_smooth(method="lm")
# spbyarea by...
ggplot(data=pubda,aes(log(spbyarea),aggdiv))+geom_point()+geom_smooth(method="lm")
cor.test(log(spbyarea),aggdiv) # r = 0.17
ggplot(data=pubda,aes(log(spbyarea),log(Richness/`Land area (sq. km)`)))+geom_point()+geom_smooth(method="lm")
cor.test(log(spbyarea),log(Richness/`Land area (sq. km)`))



ggplot(data=pubda,aes(log(spbyarea),log(authorRepresentation)))+geom_point()+geom_smooth(method="lm")
cor.test((spbyarea),(authorRepresentation))
ggplot(data=pubda,aes(log(aggdiv),log(authorRepresentation)))+geom_point()+geom_smooth(method="lm")
cor.test(aggdiv,authorRepresentation)



plot(pubsbydiv$authorRepresentation~pubsbydiv$aggDiversity)
plot(pubsbydiv$authorRepresentation~pubsbydiv$gbifarea)
plot(log10(pubsbydiv$authorRepresentation)~log10(pubsbydiv$aggDiversity))
plot(pubsbydiv$authorRepresentation~pubsbydiv$AvTD)
plot(pubsbydiv$authorRepresentation~pubsbydiv$Richness) #not meaningful since area

ggplot(data=pubsbydiv, aes(aggDiversity, authorRepresentation))+geom_point()+geom_text(aes(label=country),check_overlap = T)
ggplot(data=pubsbydiv, aes(AvTD, authorRepresentation))+geom_point()+geom_text(aes(label=country),check_overlap = T)


#checking to see how AvTD works as diversity index w/ author representation
ggplot(data=pubsbydiv, aes(AvTD, log10(authorRepresentation)))+geom_point()+geom_label_repel(aes(label=country))

#putting labels on aggregated biodiv
ggplot(data=pubsbydiv, aes(aggDiversity, authorRepresentation))+geom_point()+geom_label_repel(aes(label=country))

#### Data analysis ####
#test for correlation
cor.test(pubsbydiv$authorRepresentation, pubsbydiv$aggDiversity, method="spearman")
cor.test(pubsbydiv$authorRepresentation, pubsbydiv$aggDiversity, method="kendall")
#that was dumb, try it with a linear model instead
model1<-glm(authorRepresentation~aggDiversity, data=pubsbydiv, family="poisson")
summary(model1)

#that's overdispersed, try a quasi-poisson or negative binomial model
model2<-glm(authorRepresentation~aggDiversity, data=pubsbydiv, family="quasipoisson")
summary(model2)
plot(model2)

model3<-glm.nb(authorRepresentation~, data=pubsbydiv)
summary(model3)
#let's go with the nb model


#following Megan's heart:
x1<-glm.nb(pubsbydiv$authorRepresentation~pubsbydiv$Richness+pubsbydiv$AvTD)
summary(x1)
plot(pubsbydiv$Richness~pubsbydiv$AvTD)
plot(log(pubsbydiv$authorRepresentation)~log(pubsbydiv$Richness))

zeroinfl(pubsbydiv$authorRepresentation~pubsbydiv$Richness)




#Playing with models using AvTD
amodel1<-glm(authorRepresentation~AvTD, data=pubsbydiv)
summary(amodel1) #yikes
plot(amodel1)

#now with quasi
amodel2<-glm(authorRepresentation~AvTD, data=pubsbydiv, family="quasipoisson")
summary(amodel2)

#and then negative binomial
amodel3<-glm.nb(authorRepresentation~AvTD, data=pubsbydiv)
summary(amodel3)
plot(amodel3)



#### Plots ####
plot(pubsbydiv$allMismatch~pubsbydiv$aggDiversity)
plot(log10(pubsbydiv$authorRepresentation)~log10(pubsbydiv$aggDiversity))
plot(pubsbydiv$allMismatch~pubsbydiv$AvTD)

a2model1<-glm(allMismatch~AvTD, data=pubsbydiv,family="quasipoisson")
summary(a2model1) #yikes
plot(amodel1)

a2model2<-glm(allMismatch~aggDiversity,data=pubsbydiv,family="quasipoisson")
summary(a2model2)

write.csv(pubsbydiv,file="TEMPpubsbydiv.csv")

#### plots for Theresa ####
#top countries:
library("dplyr")
require(dplyr)
count(pubsbydiv,country) %>% arrange(pubsbydiv$country, pubsbydiv$authorRepresentation)

ctryarr<-arrange(pubsbydiv$country, desc(pubsbydiv$authorRepresentation))

ggplot(data=pubsbydiv, aes(country, authorRepresentation))

ggplot(data=pubsbydiv, aes(x=reorder(country, authorRepresentation),y=authorRepresentation))+geom_bar(stat="identity")

#### older data compilations code (now done in dplyr) ####
#change NA's in the dataset to 0's (may need to do for authorRep too)
###DON'T NEED TO DO THIS IF YOU IGNORE NAs
pbdata$`Plant species (higher), threatened`[is.na(pbdata$`Plant species (higher), threatened`)]<-0

#sum all the publications by for each country by year
nump<-aggregate(authorRepresentation~country, pbdata, sum)

#sum all the threatened plants by year
planty<-aggregate(`Plant species (higher), threatened`~country,pbdata,sum)

#take mean of all gbif data by year
bify<-aggregate(gbifDiversity~country,pbdata,mean)

#add AvTD to available data (then merge below)
avtd<-read.csv("AvTD_by_country.csv", header=T)

#get WB/economic data together (need to take mean for these):
WBdata<-aggregate(cbind(pbdata$`Land area (sq. km)`, pbdata$`GDP per capita, PPP (constant 2011 international $)`,pbdata$`GINI index (World Bank estimate)`)~country, data=pbdata, FUN=mean("mean"))
names(WBdata)<-c("country","area","GDP","GINI") #apply col names

###get additional author representation 
##add mismatches
#sum all mismatchs
#need to do something about NA's. using na.action=na.pass just makes everything NA. Not doing anything about it results in only 16 obs.
pbdata$authorRepresentation[is.na(pbdata$authorRepresentation)]<-0

author_mm<-aggregate(cbind(pbdata$allMismatch, pbdata$mismatch, pbdata$singleAuthorMismatch)~country, data=pbdata, FUN="sum", na.action=na.pass, na.rm=TRUE)
sapply(author_mm, function(y) sum(is.na(y)))


names(author_mm)<-c("country","allmm","mm","onemm")

#it seems like we have a lot of NAs and that will limit our dataset considerably. To get a sense of what vars may actually be useful, let's see NA counts for each var:
na_count<-sapply(pbdata, function(y) sum(is.na(y)))
na_count<-data.frame(na_count)

#merge all the datasets together
numpavtd<-merge(nump,avtd,by="country") #137obs
numplanty<-merge(planty,numpavtd,by="country") #137obs
bifyplanty<-merge(numplanty,bify,by="country") #137
authbifplanty<-merge(bifyplanty,author_mm,by="country") 
pubsbydiv<-merge(authbifplanty,WBdata,by="country")

### BRING IN AI
### AvTD 
plot(pubsbydiv$authorRepresentation~pubsbydiv$AvTD)

