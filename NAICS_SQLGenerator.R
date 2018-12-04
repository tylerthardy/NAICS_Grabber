load("NAICS2.RData")
load("NAICS4.RData")
load("NAICS6.RData")

FILE_NAME = "NAICSquery.SQL"

# Prepare SQL Queries -----------------------------------------------------
tableCreation = "
CREATE TABLE NAICS2(
NAICS2Id INT NOT NULL PRIMARY KEY,
NAICS2Code INT NOT NULL,
NAICS2Name VARCHAR(MAX)
);

CREATE TABLE NAICS4(
NAICS4Id INT NOT NULL PRIMARY KEY,
NAICS4Code INT NOT NULL,
NAICS4Name VARCHAR(MAX)
NAICS2Code INT NOT NULL FOREIGN KEY REFERENCES NAICS2(NAICS2Code)
);

CREATE TABLE NAICS6(
NAICS6Id INT NOT NULL PRIMARY KEY,
NAICS6Code INT NOT NULL,
NAICS6Name VARCHAR(MAX)
NAICS4Code INT NOT NULL FOREIGN KEY REFERENCES NAICS4(NAICS4Code)
NAICS2Code INT NOT NULL FOREIGN KEY REFERENCES NAICS2(NAICS2Code)
);
"

escapeQuotes = function(x)
{
  return(gsub("'", "\\\\'", x))
}

write(tableCreation, file = FILE_NAME, append = FALSE)

for (i in 1:nrow(NAICS2))
{
  row = NAICS2[i,]
  row$title = escapeQuotes(row$title)
  write(sprintf("INSERT INTO NAICS2 (NAICS2Code, NAICS2Name) VALUES (%s, '%s')", row$code, row$title),
                file = FILE_NAME, append=T)
}

for (i in 1:nrow(NAICS4))
{
  row = NAICS4[i,]
  row$title = escapeQuotes(row$title)
  naics2code = substring(row$code, 1, 2)
  write(sprintf("INSERT INTO NAICS4 (NAICS4Code, NAICS4Name, NAICS2Code) VALUES (%s, '%s', %s)", row$code, row$title, naics2code),
                file = FILE_NAME, append=T)
}

for (i in 1:nrow(NAICS6))
{
  row = NAICS6[i,]
  row$title = escapeQuotes(row$title)
  naics4code = substring(row$code, 1, 4)
  naics2code = substring(row$code, 1, 2)
  write(sprintf("INSERT INTO NAICS6 (NAICS6Code, NAICS6Name, NAICS4Code, NAICS2Code) VALUES (%s, '%s', %s, %s)", row$code, row$title, naics4code, naics2code),
                file = FILE_NAME, append=T)
}


