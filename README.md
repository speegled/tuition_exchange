# tuition_exchange

The file data/full_data.csv is the main attraction of this repo. It contains information about the colleges and universities that participate in tuition exchange in one convenient csv file. 

Information about colleges and universities that participate in tuition exchange. The list of colleges and their participation levels was scraped from http://tuitionexchange.org. The costs and some admissions information associated with the various colleges was taken from the college scorecards https://collegescorecard.ed.gov/data/. For schools that don't participate in college scorecards, I wrote a script to scrape google searches for ACT scores associated with the college.

Note that the scorecard data is from 2015/2016. So, I scraped total cost of attendance for colleges I could find. For those I couldn't, I added about 7 per cent to the 2015/2016 total. 

The main dataset is in data/full_data.csv. There are errors and omissions in this data. I welcome any pull request that fixes any problem, no matter how small! The data contains 655 observations of the following variables

1. college - The name of the institution.
2. STABBR - the state abbreviation for where the institution is located.
2. cost_estimate - scraped or estimated total cost of attendance
2. percent_award -the percentage of students admitted who receive tuition exvhange benefit
2. TUITION_FEE_OUT - out of state tuition and fees
9. UGDS - number of undergraduate students.
7. ADM_RATE - admission rate from scorecard     
3. low_act - the 25th percentile ACT score; either from scorecard or scraping.
4. mid_act - the median ACT score, from scraping.
5. high_act - the 75th percentile ACT score;ither from scorecard or scraping.
14. award_type - tuition exchange reward type; either full, set rate or other
16. net_cost - OK, this is my best estimate for what net cost will be in 2018/2019 if you get tuition exchange scholarship.

## R code
The R code that was used to (help) create this data is in the R folder. It is included for semi-reproducibility. I used this project to improve my web scraping skills, and you can probably tell which scripts I wrote last. For example, I found the award type two different ways in two files, and the way at the end of `full_tution_scraper.R` is clearly better. I also should have done a better job of standardizing `INSTNM` throughout the code. There is very little documentation included; sorry future me. I also made many changes to the data by hand; I believe they are all documented in the commit history, but I'm not sure.

Known issues:

1. When scraping the total cost of attendance, I accidentally got the cost for in-state students in some cases.
2. The `Other Tuition` award type was treated as Set Rate for the purposes of net cost estimation. Many colleges with Other Tuition give essentially full tuition minus some admin fee; it really jusrt varies. I have fixed some of these by hand, but certainly not all.