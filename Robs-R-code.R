require(jsonlite)
require(ggplot2)
require(lme4)

wd <- fromJSON('~/Documents/PubBiasJazz/Pub-bias-code/workingDataset.json')
wd <- wd$data
attach(wd)

wd$authorRepresentation[is.na(wd$authorRepresentation)] <- 0
wd$`Plant species (higher), threatened`[is.na(wd$`Plant species (higher), threatened`)] <- 0
numpubs <- aggregate(cbind(`Plant species (higher), threatened`,gbifDiversity,authorRepresentation) ~ country + development,wd,sum)

numpubs$gbifDiversity <- numpubs$gbifDiversity/38

numpubs$tOd <- numpubs$`Plant species (higher), threatened`/numpubs$gbifDiversity

