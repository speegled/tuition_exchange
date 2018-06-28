library(rvest)
library(dplyr)
pgsession <- html_session("https://www.collegedata.com")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[1]], collegeName = paste("saint louis university"))
out <- submit_form(session = pgsession, filled_form)

cast <- html_nodes(out, ".right:nth-child(7)")
html_text(cast)
out

cl <- read.csv("CollegeScorecard_Raw_Data/all_colleges.csv", stringsAsFactors = FALSE)
cl <- cl$x[stringr::str_detect(cl$x, "[A-Z]{2}")]
cl <- cl[1:656]
library(stringr)
cl <- str_remove(cl, " - [A-Z]{2}")
costs <- rep(0, 656)
for(i in 17:656) {
  filled_form <- set_values(pgform[[1]], collegeName = cl[i])
  out <- submit_form(session = pgsession, filled_form)
  
  cast <- html_nodes(out, ".right:nth-child(7)")
  if(length(html_text(cast)) > 0)
    costs[i] <- html_text(cast)
}
costs
df <- data.frame(college = cl, cost = costs, stringsAsFactors = FALSE)
#write.csv(df, "data/scraped_total_cost.csv", row.names = FALSE)
df <- read.csv("data/scraped_total_cost.csv", stringsAsFactors = FALSE)
df$college <- str_remove_all(df$college, " ")
df2 <- left_join(df, select(pp, INSTNM, COSTT4_A), by = c("college" = "INSTNM"))
df2[500:656,]
df2[str_detect(df2$college, "Lawr"),]
df2$cost <- as.integer(str_remove_all(df2$cost, "[$,]"))
df2$COSTT4_A <- as.integer(df2$COSTT4_A)
for(i in 1:691) {
  if(df2$cost[i] == 0) df2$cost[i] <- df2$COSTT4_A[i]
}
df2$cost_estimate <- pmax(df2$cost, df2$COSTT4_A, na.rm = T)
for(i in 1:691) {
  if(!is.na(df2$COSTT4_A[i]) && !is.na(df2$cost_estimate[i]))
  if(df2$cost_estimate[i] == df2$COSTT4_A[i]) df2$cost_estimate[i] <-1.07 * df2$COSTT4_A[i]
}
df2 <- select(df2, college, cost_estimate)
df2 <- distinct(df2)
pp$INSTNM
dups <- unique(pp$INSTNM[duplicated(pp$INSTNM)]) #should've kept state abbreviations above. aargh.

df2$college
www <- data.frame(INSTNM = setdiff(str_remove_all(df2$college, "[- ()&.]") %>% str_remove_all("[A-Z]{2}"), pp$INSTNM) , stringsAsFactors = FALSE)
left_join(www, aaa, by = c("INSTNM" = "INSTNM"))
bbb <- read.csv("data/all_data.csv", stringsAsFactors = FALSE)
left_join(www, bbb)
pp$STABBR[duplicated(pp$INSTNM)]
filter(bbb, str_detect(INSTNM, "iddle"))

cl2 <- read.csv("CollegeScorecard_Raw_Data/all_colleges.csv", stringsAsFactors = FALSE)
cl2 <- cl2$x[stringr::str_detect(cl2$x, "[A-Z]{2}")]
cl2 <- cl2[1:656]
cl2[66] <- "George Washington University - DC"
cl2 <- data.frame(INSTNM = cl2,stringsAsFactors = FALSE)
cl2$STABBR <- unlist(str_extract_all(cl2$INSTNM, "[A-Z]{2}$"))
cl2$INSTNM <- str_remove(cl2$INSTNM, " - [A-Z]{2}")
cl2$INSTNM <- str_remove_all(cl2$INSTNM, "[- ()&.]")
df3 <- df2
df3$college <- str_remove_all(df3$college, "[- ()&.]")
left_join(cl2, df3, by = c("INSTNM" = "college")) %>% left_join(pp)
filter(bbb, str_detect(INSTNM, "Concordia"))
cl2[which(str_detect(cl2$INSTNM, "Concordia")),]
cl2$INSTNM[21] <- "ConcordiaUniversityIrvine"
cl2$INSTNM[106] <- "ConcordiaUniversityChicago"
cl2$INSTNM[310] <- "ConcordiaUniversityNebraska"
cl2$INSTNM[579] <- "ConcordiaUniversityTexas"
cl2$INSTNM[649] <- "ConcordiaUniversityWisconsin"

for_output <- left_join(cl2, df3, by = c("INSTNM" = "college")) %>% left_join(pp)
write.csv(for_output, "data/final_data.csv", row.names = FALSE)



#' here begins some by hand work. Bleah.

for_output[which(is.na(for_output$cost_estimate)),]
filter(bbb, INSTNM == "GeorgeWashingtonUniversity")
for_output$cost_estimate[66] <- 70443
for_output$TUITIONFEE_OUT[66] <- 53518
for_output$ACTCM25[66] <- 27
for_output$ACTCM75[66] <- 32
for_output$net_cost[66] <- 70443 - .7 * 53518
for_output$low_act[66] <- 27
for_output$high_act[66] <- 32
for_output[66,]

filter(cl2, INSTNM == "KnoxCollegeIL")
cl2$INSTNM[114] <- "KnoxCollege"
df3$college[112] <- "KnoxCollege"
filter(pp, INSTNM == "KnoxCollege")
for_output$cost_estimate[114] <- 56554


for_output$net_cost_2018_2019 <- 0
fff <- for_output
for(i in 1:672) {
  if(!is.na(fff$cost_estimate[i]) && !is.na(fff$TUITIONFEE_OUT[i]) && !is.na(fff$reward_type[i])) {
  if(fff$reward_type[i] == "Full Tuition") fff$net_cost_2018_2019[i] <- as.numeric(fff$cost_estimate[i]) - 1.072 * as.numeric(fff$TUITIONFEE_OUT[i]) else
    fff$net_cost_2018_2019[i] <- as.numeric(fff$cost_estimate[i]) - 37000
  }
}
for(i in 1:6) {
  if(allc$reward_type[i] == "Set Rate") allc$net_cost[i] <- as.numeric(allc$COSTT4_A[i]) * 1.06 - 36000
}
for(i in 1:645) {
  if(allc$reward_type[i] == "Other Amount") allc$net_cost[i] <- as.numeric(allc$COSTT4_A[i]) * 1.06 - 36000
}

names(fff)[16] <- "net_cost_scorecard_2018_2019"
names(fff)[17] <- "net_cost_2018_2019_best_estimate"

write.csv(fff, "data/final_data.csv", row.names = FALSE)
fff[duplicated.data.frame(select(fff, INSTNM, STABBR)),]
filter(fff, INSTNM == "AndersonUniversity") # tuition and fees minus $1000; counting as full tuition
fff <- fff[-136,]
filter(fff, INSTNM == "AndersonUniversity") #SC is full tuition
fff <- fff[-558,]
filter(fff, INSTNM == "MarianUniversity") #IN is full
fff[146,]
fff <- fff[-146,]

filter(fff, str_detect(INSTNM , "Wentworth"))
fff[248:251,]
fff[249:251,]
fff <- fff[-249,] #repeated twice!

filter(fff, str_detect(INSTNM , "StTh"))
fff <- fff[-280,]
fff[280,3] <- 53440 #Looked this up

fff[285:288,]
fff[286:287,]
fff <- fff[-287,]

fff[304:305,]
fff <- fff[-304,] #ran this twice

fff[536:540,]
fff <- fff[-536,]
fff <- fff[-537,]

fff[602:604,]
fff <- fff[-602,] #ran twice

fff[546:547,]
fff <- fff[-547,]


fff[548:555,]
fff <- fff[-548,]

fff[595:600,]
fff[597,]
fff <- fff[-597,]

write.csv(fff, "data/final_data.csv", row.names = FALSE)
