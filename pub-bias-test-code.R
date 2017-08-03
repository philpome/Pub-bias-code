setwd("C:/Users/Megan/Desktop/Python/pub-bias/Pub-bias-code-master")
library("jsonlite", lib.loc="~/R/win-library/3.3")
pbdata<-fromJSON("workingDataset.json",flatten=TRUE)
pbdata<-pbdata$data
library("ggplot2", lib.loc="~/R/win-library/3.3")
test<-ggplot(pbdata, aes(`Plant species (higher), threatened`,mismatch,color=factor(subregion)))+geom_jitter()
test
