
######################################################################################
# Plot distance between two sets of GPS coordinates from Google location history data
#
# Hallie Eilerts, hallieeilerts@gmail.com
######################################################################################


# individual 1 ------------------------------------------------------------

# Load kml for individual 1
filename <- list.files("./data/Individual1", pattern="*.kml", full.names=TRUE)
kml <- xmlToList(filename)

# Track list
l.tr <- kml$Document$Placemark$Track
# Identify list elements that have coordinates
v.cc <- which(names(l.tr) == "coord")
# Matrix of lat/long
m.coord <- t(sapply(l.tr[v.cc], function(x) scan(text = x, quiet = TRUE)))[,1:2]
# Identify list elements that have date/times
v.when <- which(names(l.tr) == "when")
# Convert the "-07:00" into " -0700"
v.time <- strptime(sub("([+\\-])(\\d\\d):(\\d\\d)$", " \\1\\2\\3",
                     unlist(l.tr[v.when])), "%Y-%m-%dT%H:%M:%OSZ")
# Save individual 1 date/times and locations into data.frame
df.individual1 <- data.frame(time = v.time,
                             lat = m.coord[,2],
                             long = m.coord[,1])
# Remove time from date
df.individual1$date <- format(df.individual1$time,"%Y-%m-%d")
# Take median lat/long for date
setDT(df.individual1)[,`:=`(lat.individual1 = median(lat), long.individual1 = median(long)),by=date]
# Only keep one row per date
df.individual1 <- df.individual1[,c("date","lat.individual1","long.individual1")]
df.individual1 <- df.individual1[!duplicated(df.individual1),]
df.individual1 <- subset(df.individual1, !is.na(date))

# individual 2 ------------------------------------------------------------

# Load kml file for individual 2
filename <- list.files("./data/Individual2", pattern="*.kml", full.names=TRUE)
kml <- xmlToList(filename)

# Track list
l.tr <- kml$Document$Placemark$Track
# Identify list elements that have coordinates
v.cc <- which(names(l.tr) == "coord")
# Matrix of lat/long
m.coord <- t(sapply(l.tr[v.cc], function(x) scan(text = x, quiet = TRUE)))[,1:2]
# Identify list elements that have date/times
v.when <- which(names(l.tr) == "when")
# Convert the "-07:00" into " -0700"
v.time <- strptime(sub("([+\\-])(\\d\\d):(\\d\\d)$", " \\1\\2\\3",
                       unlist(l.tr[v.when])), "%Y-%m-%dT%H:%M:%OSZ")
# Save individual 1 date/times and locations into data.frame
df.individual2 <- data.frame(time = v.time,
                             lat = m.coord[,2],
                             long = m.coord[,1])
# Remove time from date
df.individual2$date <- format(df.individual2$time,"%Y-%m-%d")
# Take median lat/long for date
setDT(df.individual2)[,`:=`(lat.individual2 = median(lat), long.individual2 = median(long)),by=date]
# Only keep one row per date
df.individual2 <- df.individual2[,c("date","lat.individual2","long.individual2")]
df.individual2 <- df.individual2[!duplicated(df.individual2),]
df.individual2 <- subset(df.individual2, !is.na(date))

# Merge location data for both individuals
df.distance <- merge(df.individual1, df.individual2, by = "date")
df.distance$date <- as.Date(df.distance$date, "%Y-%m-%d")

# Calculate Haversine distance between lat/long coordinates
for(i in 1:nrow(df.distance)){
  df.distance$dist[i] <- c(distm(x = c(df.distance$long.individual1[i], df.distance$lat.individual1[i]), 
                                 y = c(df.distance$long.individual2[i], df.distance$lat.individual2[i]), 
                                 fun = distHaversine))
}


# plot --------------------------------------------------------------------

p1 <- df.distance %>%
  mutate(date = as.Date(date, "%Y-%m-%d"), negdist = -dist, datemax = max(date)) %>%
  mutate(daysremaining = as.numeric(as.Date(datemax, "%Y-%m-%d") - as.Date(date, "%Y-%m-%d"))) %>%
  ggplot() +
  geom_step(aes(x=date, y = dist, group =1), col = "black", size=.2) +
  geom_step(aes(x=date, y = negdist, group =1), col = "black", size=.2) +
  geom_col(aes(x=date, y= dist, fill=daysremaining) ) +
  geom_col(aes(x=date, y= negdist, fill=daysremaining) ) +
  labs(x="",y="")  + 
  scale_fill_gradient(low = "#cce5ff", high = "#487fb8") +
  scale_x_date(date_breaks= "1 year", labels = scales::date_format("%Y"))  +
  theme_minimal() +
  theme(text=element_text( family="Gill Sans MT"), axis.text.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.x = element_text(color = "#07284a"), panel.grid=element_blank(),
        legend.position = "none") 

ggsave("soundwavefigure.jpeg", p1, dpi=500, width = 10, height = 6)

