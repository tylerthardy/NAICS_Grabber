#install.packages("rvest")
library(rvest)

mainPage = read_html("https://www.naics.com/business-lists/counts-by-naics-code/")

# Grab the summaries of each industry (NAICS2) ----------------------------
NAICS2 = data.frame(code=character(0), title=character(0), businesses=character(0), link=character(0), stringsAsFactors = FALSE)
rows = mainPage %>% html_nodes(".table tr")
for (i in 2:(length(rows)-1))
{
  row = rows[i]
  columns = row %>% html_nodes("td")
  columnText = columns %>% html_text()
  link = columns[1] %>% html_node("a") %>% html_attr("href")
  
  NAICS2[nrow(NAICS2) + 1,] = list(code=columnText[1],
             title=columnText[2],
             businesses=columnText[3],
             link=link)
}
colnames(NAICS2) = c("code", "title", "businesses", "link")


# Grab each sub-code (NAICS4 and NAICS6) ----------------------------------
NAICS4 = data.frame(code=character(0), title=character(0), businesses=character(0), link=character(0), stringsAsFactors = FALSE)
NAICS6 = data.frame(code=character(0), title=character(0), businesses=character(0), link=character(0), stringsAsFactors = FALSE)

for (link in NAICS2$link)
{
  page = read_html(link)
  NAICS4rows = page %>% html_nodes(".table tr.headerRow:not(.groupFinal)")
  NAICS6rows = page %>% html_nodes(".table tr.groupRow")
  
  for (i in 1:length(NAICS4rows))
  {
    row = NAICS4rows[i]
    columns = row %>% html_nodes("td")
    columnText = columns %>% html_text()
    link = columns[1] %>% html_node("a") %>% html_attr("href")
    
    NAICS4[nrow(NAICS4) + 1,] = list(code=columnText[1],
                                     title=columnText[2],
                                     businesses=columnText[3],
                                     link=link)
  }
  
  for (i in 1:length(NAICS6rows))
  {
    row = NAICS6rows[i]
    columns = row %>% html_nodes("td")
    columnText = columns %>% html_text()
    link = columns[1] %>% html_node("a") %>% html_attr("href")
    
    NAICS6[nrow(NAICS6) + 1,] = list(code=columnText[1],
                                     title=columnText[2],
                                     businesses=columnText[3],
                                     link=link)
  }
}

# Cleanup NAICS2 ----------------------------------------------------------
regexHyphenated = "(\\d*)-(\\d*)"
NAICS2new = data.frame(code=character(0), title=character(0), businesses=character(0), link=character(0), stringsAsFactors = FALSE)
for (i in 1:nrow(NAICS2))
{
  row = NAICS2[i,]
  if (is.na(suppressWarnings(as.numeric(row$code)))) { # hyphenated
    m = regmatches(row$code, regexec(regexHyphenated, row$code))
    
    start = as.numeric(m[[1]][2])
    end = as.numeric(m[[1]][3])
    
    for (j in start:end)
    {
      r = row
      r$code = j
      NAICS2new[nrow(NAICS2new) + 1,] = r
    }
  } else {
    NAICS2new[nrow(NAICS2new) + 1,] = row
  }
}

NAICS2 = NAICS2new

# Save data ---------------------------------------------------------------
# save(NAICS2, file=fileName)
# save(NAICS4, file=fileName)
# save(NAICS6, file=fileName)