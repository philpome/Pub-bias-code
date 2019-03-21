#### Headspace ####
setwd("C:/Users/Megan/Desktop/Python/pub-bias/Pub-bias-code-master")
setwd("C:/Users/Ben/Documents/School Jazz/Lab Work/PubBias/RobsCode2019/Pub-bias-code/")

library("jsonlite") # need to pull from json
library("ggplot2") # who wouldn't
library("MASS") # for the negative-binom glm
library("ggrepel") # labeling points that don't overlap in ggplot

#### Dataset prep ####
pbdata<-fromJSON("workingDataset.json",flatten=TRUE)
pbdata<-pbdata$data

test<-ggplot(pbdata, aes(`Plant species (higher), threatened`,mismatch,color=factor(subregion)))+geom_jitter()
test

#change NA's in the dataset to 0's (may need to do for authorRep too)
pbdata$`Plant species (higher), threatened`[is.na(pbdata$`Plant species (higher), threatened`)]<-0
#sum all the publications by for each country by year
nump<-aggregate(authorRepresentation~country, pbdata, sum)
#sum all the threatened plants by year
planty<-aggregate(`Plant species (higher), threatened`~country,pbdata,sum)
#take mean of all gbif data by year
bify<-aggregate(gbifDiversity~country,pbdata,mean)
#add AvTD to available data (then merge below)
avtd<-read.csv("AvTD_by_country.csv", header=T)
#merge all the datasets together
numpavtd<-merge(nump,avtd,by="country")
numplanty<-merge(planty,numpavtd,by="country")
pubsbydiv<-merge(numplanty,bify,by="country")

#create the biodiversity variable
pubsbydiv$aggDiversity<-pubsbydiv$`Plant species (higher), threatened`/pubsbydiv$gbifDiversity

#### Plots ####
plot(pubsbydiv$authorRepresentation~pubsbydiv$aggDiversity)
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

model3<-glm.nb(authorRepresentation~aggDiversity, data=pubsbydiv)
summary(model3)
#let's go with the nb model



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

#### building more features into pubsbydiv dataset####
head(pbdata,2)

##add mismatches
#sum all mismatchs
allmm<-aggregate(allMismatch~country, pbdata,sum)
#sum mismatches
mm<-aggregate(mismatch~country,pbdata,sum)

#sum first author mismatches
firstmm<-aggregate(firstAuthorMismatch~country,pbdata,sum)
allandmm<-merge(allmm,mm,by="country")
allandmmandfirst<-merge(allandmm,firstmm,by="country")
pubsbydiv<-merge(pubsbydiv,allandmmandfirst,by="country")


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

