library(rvest)
library(dplyr)
library(stringr)



pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "all")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)


cast <- html_nodes(out, "td td td:nth-child(1)")
allc <- html_text(cast)
allc <- data.frame(college = allc, stringsAsFactors = FALSE)
allc <- filter(allc, str_detect(college, "[A-Z]{2}"))
allc$low_act <- NA
allc$mid_act <- NA
allc$high_act <- NA

allc <- allc[1:656,]

cc <- read.csv("CollegeScorecard_Raw_Data/MERGED2015_16_PP.csv", stringsAsFactors = FALSE)
select(cc, STABBR, INSTNM, SATMT75) %>% filter(STABBR == "WI")
library(dplyr)


pgsession <- html_session("https://google.com")
pgform <- html_form(read_html(pgsession))
for(i in 1:656) {

  tt <- html_text(cast) 
  act_range <- tt[str_detect(tt, "25th")] %>% str_extract_all("is [0-9]{2}") %>% unlist() %>% str_extract_all("[0-9]{2}") %>% unlist() %>% as.integer() %>% 
    sort() %>% unique()
  if(length(act_range) < 3) act_range[(length(act_range) + 1) : 3] <- NA
  act_range <- act_range[1:3]
  allc[i,2:4] <- act_range
  Sys.sleep(1.5) #without this, I was getting kicked off after awhile...
}
allc[str_detect(allc$college, "Knox"),]
allc[114,2:4] <- c(23,26,29)
for(i in 1:656) {
  if(is.na(allc$high_act[i])) {
    allc[i, 2:4] <- allc[i, c(2,4,3)]
  }
}
allc
#write.csv(allc, "all_colleges_with_act_scraped.csv", row.names = FALSE)
for(i in which(!is.na(allc$high_act))) {
  if(allc$high_act[i] > 34) {
    allc[i, c(2,4)] <- allc[i, c(2,3)]
    allc[i,3] <- NA
  }
}
allc 

names(allc)[1] <- "INSTNM"
allc$STABBR <- unlist(str_extract_all(allc$INSTNM, "[A-Z]{2}", simplify = TRUE))
str_c(allc$STABBR)
allc$STABBR <- allc$STABBR[,1]
allc <- filter(allc, STABBR != "")
allc <- allc[1:656,]
allc$INSTNM <- str_remove_all(allc$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")

bd <- read.csv("all_data.csv", stringsAsFactors = FALSE)
bd <- select(bd, TUITIONFEE_OUT, ADM_RATE, STABBR, INSTNM, COSTT4_A,  UGDS, ACTCM25, ACTCM75, SATMT25, SATMT75)
bd$INSTNM <- str_remove_all(bd$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
allc <- left_join(allc, bd)

allc <- allc[1:656,]

allc$ACTCM75[!is.na(allc$ACTCM75) & (allc$ACTCM75 != "NULL")]
for(i in 1:656) {
  if(!is.na(allc$ACTCM75[i]) && (allc$ACTCM75[i] != "NULL")) {
    allc$high_act[i] <-  as.numeric(allc$ACTCM75[i])
    allc$low_act[i] <- as.numeric(allc$ACTCM25[i])
    allc$mid_act[i] <- NA
  }
} #trust the values from report cards rather than scraping!


head(allc)

#' Now, we need to go back and determine whether the colleges are full tuition, standard rate or other tuition benefit.
#' should have done that in the first place


allc$reward_type <- "A"

#write.csv(allc, "temp1.csv")
#allc <- read.csv("temp1.csv", stringsAsFactors = FALSE)
#allc$X <- NULL


pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "Full Tuition")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)
cast <- html_nodes(out, "td td td:nth-child(1)")
full <- html_text(cast)



pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "Optional Award")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)
cast <- html_nodes(out, "td td td:nth-child(1)")
other <- html_text(cast)


pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "Other Tuition")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)
cast <- html_nodes(out, "td td td:nth-child(1)")
other2 <- html_text(cast)


full <- full[unlist(str_extract_all(full, "[A-Z]{2}", simplify = TRUE))[,1] != ""]
full <- str_remove_all(full, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
full <- full[1:466]
full <- data.frame(INSTNM = full, reward_type = "Full Tuition", stringsAsFactors = FALSE)


set_rate <- other[unlist(str_extract_all(other, "[A-Z]{2}", simplify = TRUE))[,1] != ""]
set_rate <- str_remove_all(set_rate, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
set_rate <- data.frame(INSTNM = set_rate, reward_type = "Set Rate", stringsAsFactors = FALSE)

other_rate <- other2[unlist(str_extract_all(other2, "[A-Z]{2}", simplify = TRUE))[,1] != ""]
other_rate <- str_remove_all(other_rate, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
other_rate <- data.frame(INSTNM = other_rate, reward_type = "Other Amount", stringsAsFactors = FALSE)

alldat <- rbind(full, set_rate, other_rate)

allc <- left_join(allc, alldat  , by = "INSTNM") %>% filter(!is.na(reward_type.y)) %>% distinct()
allc$reward_type.x <- NULL
names(allc)[14] <- "reward_type"

allc$net_cost <- 0
for(i in 1:645) {
  if(allc$reward_type[i] == "Full Tuition") allc$net_cost[i] <- 1.06*(as.numeric(allc$COSTT4_A[i]) - as.numeric(allc$TUITIONFEE_OUT[i]))
}
for(i in 1:645) {
  if(allc$reward_type[i] == "Set Rate") allc$net_cost[i] <- as.numeric(allc$COSTT4_A[i]) * 1.06 - 36000
}
for(i in 1:645) {
  if(allc$reward_type[i] == "Other Amount") allc$net_cost[i] <- as.numeric(allc$COSTT4_A[i]) * 1.06 - 36000
}


#Tuition and Costs are from 2015/2016!! 

write.csv(allc, "data/final_data.csv", row.names = FALSE)

pp <- arrange(allc, desc(high_act), desc(low_act), ADM_RATE, net_cost) %>% filter(net_cost < 24000) 
pp[,c(1,2,3,4,5,7,9,15)]
filter(pp, str_detect(INSTNM, "Belo"))