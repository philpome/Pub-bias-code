setwd("C:/Users/Megan/Desktop/Python/pub-bias/Pub-bias-code-master")
library("jsonlite", lib.loc="~/R/win-library/3.3")
pbdata<-fromJSON("workingDataset.json",flatten=TRUE)
pbdata<-pbdata$data
library("ggplot2", lib.loc="~/R/win-library/3.3")
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

