library(rvest)

#html <- read_html("https://telo.tuitionexchange.org/search.cfm")
#cast <- html_nodes(html, "td td td:nth-child(1)")
#length(cast)


pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "all")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)


cast <- html_nodes(out, "td td td:nth-child(1)")
allc <- html_text(cast)

#write.csv(other_tuition, "/Users/speegled/Dropbox/Lisa/college/all_colleges.csv", row.names = FALSE)
#read.csv("/Users/speegled/Dropbox/Lisa/college/full_tuition.csv")

library(dplyr)
library(stringr)
sd <- read.csv("small_data.csv", stringsAsFactors = FALSE)
sd <- dplyr::select(sd, INSTNM, STABBR, UGDS, ACTCM25, ACTCM75, SATMT25, SATMT75)
ft <- read.csv("/Users/speegled/Dropbox/Lisa/college/full_tuition.csv", stringsAsFactors = FALSE)
filter(sd, STABBR =="AL")
names(ft)[1] <- "INSTNM"
ft$STABBR <- unlist(str_extract_all(ft$INSTNM, "[A-Z]{2}", simplify = TRUE))
str_c(ft$STABBR)
ft$STABBR <- ft$STABBR[,1]
ft <- filter(ft, STABBR != "")
ft <- ft[1:466,]
ft$INSTNM <- str_remove_all(ft$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
sd$INSTNM <- str_remove_all(sd$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
ft <- left_join(ft, sd)
ft <- ft[complete.cases(ft),]
ft <- filter(ft, SATMT75 != "NULL", ACTCM75 != "NULL")
ft <- arrange(ft, desc(ACTCM75), desc(SATMT75))
##write.csv(ft, "full_tuition_with_act_scores.csv", row.names = FALSE)




sd <- read.csv("small_data.csv", stringsAsFactors = FALSE)
sd <- dplyr::select(sd, INSTNM, STABBR, UGDS, ACTCM25, ACTCM75, SATMT25, SATMT75)
allc <- read.csv("/Users/speegled/Dropbox/Lisa/college/all_colleges.csv", stringsAsFactors = FALSE)
names(allc)[1] <- "INSTNM"
allc$STABBR <- unlist(str_extract_all(allc$INSTNM, "[A-Z]{2}", simplify = TRUE))
str_c(allc$STABBR)
allc$STABBR <- allc$STABBR[,1]
allc <- filter(allc, STABBR != "")
allc <- allc[1:656,]
allc$INSTNM <- str_remove_all(allc$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
sd$INSTNM <- str_remove_all(sd$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
allc <- left_join(allc, sd)
allc <- allc[complete.cases(allc),]
allc <- filter(allc, SATMT75 != "NULL", ACTCM75 != "NULL")
allc <- arrange(allc, desc(ACTCM75), desc(SATMT75))
##write.csv(allc, "all_colleges_with_act_scores.csv", row.names = FALSE)


ft$type <- "Full Tuition"
allc <- left_join(allc, ft)

pgsession <- html_session("https://telo.tuitionexchange.org/search.cfm")
pgform <- html_form(read_html(pgsession))
filled_form <- set_values(pgform[[2]], tuition = "Other Tuition")
for(i in 1:18)
  filled_form$fields[[i]]$type <- "type1"
out <- submit_form(session = pgsession, filled_form)


cast <- html_nodes(out, "td td td:nth-child(1)")
other_tuition <- html_text(cast)
other_tuition <- data.frame(INSTNM = other_tuition)
other_tuition$STABBR <- unlist(str_extract_all(other_tuition$INSTNM, "[A-Z]{2}", simplify = TRUE))
str_c(other_tuition$STABBR)
other_tuition$STABBR <- other_tuition$STABBR[,1]
other_tuition <- filter(other_tuition, STABBR != "")
#other_tuition <- other_tuition[1:656,]
other_tuition$INSTNM <- str_remove_all(other_tuition$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
other_tuition$type <- "Other Tuition"
allc <- left_join(allc, other_tuition, by = c("INSTNM", "STABBR"))
for(i in 1:388) {
  if(is.na(allc$type.x[i])) allc$type.x[i] <- allc$type.y[i]
}
for(i in 1:388) {
  if(is.na(allc$type.x[i])) allc$type.x[i] <- "Standard Rate"
}
#write.csv(allc, "all_colleges_with_act_and_scholarship.csv", row.names = FALSE)

bd <- read.csv("all_data.csv", stringsAsFactors = FALSE)
bd <- select(bd, TUITIONFEE_OUT, ADM_RATE, STABBR, INSTNM, COSTT4_A)
bd$INSTNM <- str_remove_all(bd$INSTNM, "[- ()&.]") %>% str_remove("[A-Z]{2}$")
allc <- left_join(allc, bd)
write.csv(allc, "all_colleges_all_info.csv", row.names = FALSE)

head(allc, 50)

allc$NOTES[8] <- "preference to upper-class students"
allc$NOTES[1] <- "80 percent of tuition"
allc$NOTES[7] <- "37584 for 2017-2018"
allc$NOTES[12] <- "full tuition minus any other awards received"
allc$NOTES[15] <- "two scholarships/90-100 apps"



# 
# 
# pgform$fields$tuition$value <- "Full Tuition"
# filled_form <- set_values(pgsession, pgform)
# result <- submit_form(pgsession, filled_form)
# search <- html_form(read_html("https://telo.tuitionexchange.org/search.cfm"))
# set_values(search[[2]], tuition = "Full tuition")
# submit_form(search)
# 
# 
# 
# url <- "https://iemweb.biz.uiowa.edu/pricehistory/pricehistory_SelectContract.cfm?market_ID=214"
# 
# pg.session <- html_session(url)
# 
# pg.form <- html_form(read_html(pg.session))
# filled_form <- set_values(pg.form[[1]],
#                           Month = "08",
#                           Year = "2007")
# filled_form$fields$Month$type <- "type1"
# filled_form$fields$Year$type <- "type1"
# out <- submit_form(session = pg.session, filled_form)
