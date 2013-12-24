## Downloading geo-located data about Pakistan relates do CAMEO's violent events codes. 

#setwd("~/Documents/Programming/ocha-gdelt-pakistan")

library(GDELTtools)
library(lubridate) 
library(ggplot2)
library(ggmap)
library(countrycode)

# downloading and subsetting data, using the tutorial from http://gdeltblog.wordpress.com/2013/10/03/gdelttools-r-package-to-download-subset-and-normalize-gdelt-data/
gdelt.subset <- GetGDELT(start.date="2010-01-01", end.date="2013-12-22",
                         filter=list(EventCode="19*", ActionGeo_CountryCode="PK"), 
                         allow.wildcards=TRUE) 

gdelt.normed <- NormEventCounts(gdelt.subset, 
                                unit.analysis="country.month",
                                var.name="attacks")

# normalizing the dates with lubridate (on the normalized dataset)
pak.attacks <- gdelt.subset
pak.attacks$SQLDATE <- ymd(pak.attacks$SQLDATE)
pak.attacks.2013 <- subset(pak.attacks, pak.attacks$Year == '2013') # subsetting only for events in 2013 

# creating workable subsets. 
pak.attacks.sample <- pak.attacks[1:100,]

# saving CSV files -- avoid lossing data. 
write.csv(pak.attacks, file = "GDELT_Pak_attacks.csv", row.names = F)
write.csv(pak.attacks.2013, file = "GDELT_Pak_attacks_2013.csv", row.names = F)
write.csv(pak.attacks.sample, file = "GDELT_Pak_attacks_sample.csv", row.names = F)

# plotting the total events count with normalzed data. 
ggplot(pak, aes(month, attacks.count)) + 
  geom_bar(stat='identity') +
  # geom_line(stat='identity') +
  # geom_point() +
  theme_bw()

# creating a simple map with ggmap for all events and a plot counting events per month. 
pak.map <- get_map("Pakistan", maptype = "terrain", color = "bw", zoom = 6)

# map
ggplot(pak.attacks, aes(month(c(pak.attacks$SQLDATE)))) + 
  geom_bar(aes(fill = AvgTone), stat='bin') +
  # geom_line(stat='bin') +
  theme_bw() + 
  scale_x_continuous(breaks=1:12) + 
  facet_grid(. ~ Year)

# plot
ggmap(pak.map) + 
  geom_point(data = pak.attacks, aes(ActionGeo_Long, ActionGeo_Lat, color = "red"), alpha = 0.3)
