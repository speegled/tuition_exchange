allc <- read.csv("all_colleges_all_info.csv", stringsAsFactors = FALSE)
head(allc, 20)
allc$type.x[12] <- "Full Tuition"
allc$TUITIONFEE_OUT <- as.integer(allc$TUITIONFEE_OUT)
allc$COSTT4_A <- as.integer(allc$COSTT4_A)
allc$netcost <- 0
for(i in 1:398) {
  if(allc$type.x[i] == "Full Tuition") allc$netcost[i] <- allc$COSTT4_A[i] - allc$TUITIONFEE_OUT[i]
}
head(allc)
for(i in 1:398) {
  if(allc$type.x[i] == "Standard Rate") allc$netcost[i] <- allc$COSTT4_A[i] - 36500
}
allc$netcost[1] <- 64536 - .8*50277
head(select(allc, -type.x), 100)
allc %>% filter(STABBR == "WI")



fff <- read.csv("data/final_data.csv", stringsAsFactors = FALSE)
fff <- select(fff,  INSTNM, STABBR, cost_estimate, low_act, mid_act, high_act, ADM_RATE, UGDS, net_cost_2018_2019_best_estimate)
names(fff)[9] <- "net_cost"
fff %>% arrange(desc(low_act), net_cost)
compareNA <- function(v1,v2) {
  # This function returns TRUE wherever elements are the same, including NA's,
  # and false everywhere else.
  same <- (v1 == v2)  |  (is.na(v1) & is.na(v2))
  same[is.na(same)] <- FALSE
  return(same)
}
for(i in 1:655)
  if(compareNA(fff$low_act[i] >  35, TRUE)) fff$low_act[i] <- NA  

for(i in 1:655)
  if(is.na(fff$mid_act[i]) && is.na(fff$high_act[i])) {
    fff$mid_act[i] <- fff$low_act[i]
    fff$low_act[i] <- NA
  }
 
for(i in 1:655)
  if(fff$net_cost[i] == 0) fff$net_cost[i] <- NA

names(fff)[9] <- "net_cost"

write.csv(fff, "data/final_data.csv", row.names = FALSE)

fff %>% arrange(desc(high_act), net_cost) %>% filter(net_cost < 25000)
fff


#' Getting percentage of admitted students who are given TE + re-getting award type


pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "all")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)


cast <- html_nodes(out, "font")
allc <- html_text(cast)
allc
dd <- data.frame(college = allc[1:661 *2], text = allc[1:661 *2 +1], stringsAsFactors = FALSE)

dd$college
unlist(ifelse(length(str_extract_all(dd$text, "Full Tuition|Set Rate|Other Tuition")) > 0, str_extract_all(dd$text, "Full Tuition|Set Rate|Other Tuition"), "NULL"))
dd$award_type <- as.vector(str_extract_all(dd$text, "Full Tuition|Set Rate|Other Tuition", simplify = TRUE))
str_extract_all(dd$college, "[A-Z]{2}$", simplify = TRUE)
dd$college[c(54, 37, 217, 427)]
dd$STABBR <- as.vector(  str_extract_all(dd$college, "[A-Z]{2}$", simplify = TRUE) )
dd$percent_award <- as.vector(str_extract_all(dd$text, "61\\%-90\\%|Below 10\\%|91\\%-100\\%|11\\%-40\\%|41\\%-60\\%", simplify = TRUE))
dd$INSTNM <- str_remove_all(dd$college, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
setdiff(dd$INSTNM, fff$INSTNM)
setdiff(fff$INSTNM, dd$INSTNM)
setdiff(str_remove(fff$INSTNM, "[A-Z]{2}$"), str_remove(dd$INSTNM, "[A-Z]{2}$"))
setdiff(str_remove(dd$INSTNM, "[A-Z]{2}$"), str_remove(fff$INSTNM, "[A-Z]{2}$")    )
dd[which(str_detect(dd$INSTNM, "Concordia")),]
fff[which(str_detect(fff$INSTNM, "Concordia")),]        
dd$INSTNM[21] <- fff$INSTNM[21] 
dd$INSTNM[313] <- fff$INSTNM[310]
dd$INSTNM[467] <- fff$INSTNM[463]
dd$INSTNM[584] <- fff$INSTNM[578]
dd$INSTNM[654] <- fff$INSTNM[648]
dd$INSTNM[108] <- fff$INSTNM[106]
dd[which(str_detect(dd$INSTNM, "ofSaintM")),]
fff[which(str_detect(fff$INSTNM, "ofSaintM")),]   
dd$INSTNM[68] <- fff$INSTNM[66]
dd$STABBR[68] <- "DC"
dd$INSTNM <-  str_remove(dd$INSTNM, "[A-Z]{2}$")
fff$INSTNM <- str_remove(fff$INSTNM, "[A-Z]{2}$")
dd2 <- left_join(fff, select(dd, -text))
head(dd2)
dd2$college <- str_remove(dd2$college, " - [A-Z]{2}$")
select(dd2, college, STABBR, cost_estimate, percent_award, UGDS, ADM_RATE, low_act, mid_act, high_act, award_type, net_cost)
w