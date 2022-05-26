
######################################################################################
# Plot distance between two sets of GPS coordinates - dummy data
#
# Hallie Eilerts, hallieeilerts@gmail.com
######################################################################################

# Example data for individual 1

individual1.data <- read.csv("./data/Individual1/dummydata-individual1.csv")

df.individual1 <- individual1.data[,c("date","lat","long")]
df.individual1$date <- as.Date(as.character(df.individual1$date), format="%m/%d/%Y")
# sequence from min to max date
df.alldays <- data.frame(date = seq(min(df.individual1$date), max(df.individual1$date), by = "day"))
# merge with original data
df.individual1 <- merge(df.individual1, df.alldays, by = "date", all = TRUE)
# fill lat/long values down
df.individual1 <- df.individual1 %>% fill(lat, long, .direction = "down")

# Example data for individual 2

individual2.data <- read.csv("./data/Individual2/dummydata-individual2.csv")

df.individual2 <- individual2.data[,c("date","lat","long")]
df.individual2$date <- as.Date(as.character(df.individual2$date), format="%m/%d/%Y")
# sequence from min to max date
df.alldays <- data.frame(date = seq(min(df.individual2$date), max(df.individual2$date), by = "day"))
# merge with original data
df.individual2 <- merge(df.individual2, df.alldays, by = "date", all = TRUE)
# fill lat/long values down
df.individual2 <- df.individual2 %>% fill(lat, long, .direction = "down")

# Merge individual 1 and 2 location data
df.distance <- merge(df.individual1, df.individual2, by = "date", suffixes = c(".individual1",".individual2"))
df.distance$date <- as.Date(df.distance$date, "%Y-%m-%d")

# Calculate Haversine distance between lat/long coordinates
for(i in 1:nrow(df.distance)){
  df.distance$dist[i] <- c(distm(x = c(df.distance$long.individual1[i], df.distance$lat.individual1[i]), 
                                 y = c(df.distance$long.individual2[i], df.distance$lat.individual2[i]), 
                                 fun = distHaversine))
}

# plot --------------------------------------------------------------------

df.distance %>%
  mutate(day = as.Date(date, "%Y-%m-%d"), negdist = -dist, datemax = max(day)) %>%
  mutate(daysremaining = as.numeric(as.Date(datemax, "%Y-%m-%d") - as.Date(date, "%Y-%m-%d"))) %>%
  ggplot() +
  geom_step(aes(x=date, y = dist, group =1), col = "black", size=.2) +
  geom_step(aes(x=date, y = negdist, group =1), col = "black", size=.2) +
  geom_col(aes(x=date, y= dist, fill=daysremaining), col = NA ) +
  geom_col(aes(x=date, y= negdist, fill=daysremaining), col = NA ) +
  labs(x="",y="")  + 
  scale_fill_gradient(low = "#cce5ff", high = "#487fb8") +
  scale_x_date(date_breaks= "1 year", labels = scales::date_format("%Y"))  +
  theme_minimal() +
  theme(text=element_text( family="Gill Sans MT"), axis.text.y=element_blank(), axis.ticks.y=element_blank(), 
        axis.text.x = element_text(color = "#07284a"), panel.grid=element_blank(),
        legend.position = "none")
