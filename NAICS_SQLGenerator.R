load("NAICS2.RData")
load("NAICS4.RData")
load("NAICS6.RData")

FILE_NAME = "NAICSquery.SQL"

# Prepare SQL Queries -----------------------------------------------------
tableCreation = "
CREATE TABLE NAICS2(
  NAICS2Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Slug VARCHAR(128) NOT NULL,
  NAICS2Name VARCHAR(MAX),
  CreatedBy INT,
  CreatedOn DATETIMEOFFSET(7),
  ModifiedBy INT,
  ModifiedOn DATETIMEOFFSET(7),
  DeletedOn DATETIMEOFFSET(7)
);

CREATE TABLE NAICS4(
  NAICS4Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Slug VARCHAR(128) NOT NULL,
  NAICS4Name VARCHAR(MAX),
  NAICS2Id INT NOT NULL FOREIGN KEY REFERENCES NAICS2(NAICS2Id),
  CreatedBy INT,
  CreatedOn DATETIMEOFFSET(7),
  ModifiedBy INT,
  ModifiedOn DATETIMEOFFSET(7),
  DeletedOn DATETIMEOFFSET(7)
);

CREATE TABLE NAICS6(
  NAICS6Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Slug VARCHAR(128) NOT NULL,
  NAICS6Name VARCHAR(MAX),
  NAICS4Id INT NOT NULL FOREIGN KEY REFERENCES NAICS4(NAICS4Id),
  NAICS2Id INT NOT NULL FOREIGN KEY REFERENCES NAICS2(NAICS2Id),
  CreatedBy INT,
  CreatedOn DATETIMEOFFSET(7),
  ModifiedBy INT,
  ModifiedOn DATETIMEOFFSET(7),
  DeletedOn DATETIMEOFFSET(7)
);
"

escapeQuotes = function(x)
{
  return(gsub("\'", "\'\'", x))
}

slugify = function(x)
{
  return(x %>% gsub('[[:punct:] ]+',' ', .) %>% gsub(' ', '_', .))
}

write(tableCreation, file = FILE_NAME, append = FALSE)

write("SET IDENTITY_INSERT NAICS2 ON;", file = FILE_NAME, append=T)
for (i in 1:nrow(NAICS2))
{
  row = NAICS2[i,]
  row$title = escapeQuotes(row$title)
  slug = slugify(row$title)
  write(sprintf("INSERT INTO NAICS2 (NAICS2Id, NAICS2Name, SLUG) VALUES (%s, '%s', '%s');", row$code, row$title, slug),
                file = FILE_NAME, append=T)
}
write("SET IDENTITY_INSERT NAICS2 OFF;", file = FILE_NAME, append=T)

write("SET IDENTITY_INSERT NAICS4 ON;", file = FILE_NAME, append=T)
for (i in 1:nrow(NAICS4))
{
  row = NAICS4[i,]
  row$title = escapeQuotes(row$title)
  slug = slugify(row$title)
  naics2code = substring(row$code, 1, 2)
  write(sprintf("INSERT INTO NAICS4 (NAICS4Id, NAICS4Name, SLUG, NAICS2Id) VALUES (%s, '%s', '%s', %s);", row$code, row$title, slug, naics2code),
                file = FILE_NAME, append=T)
}
write("SET IDENTITY_INSERT NAICS4 OFF;", file = FILE_NAME, append=T)

write("SET IDENTITY_INSERT NAICS6 ON;", file = FILE_NAME, append=T)
for (i in 1:nrow(NAICS6))
{
  row = NAICS6[i,]
  row$title = escapeQuotes(row$title)
  slug = slugify(row$title)
  naics4code = substring(row$code, 1, 4)
  naics2code = substring(row$code, 1, 2)
  write(sprintf("INSERT INTO NAICS6 (NAICS6Id, NAICS6Name, SLUG, NAICS4Id, NAICS2Id) VALUES (%s, '%s', '%s', %s);", row$code, row$title, slug, naics4code, naics2code),
                file = FILE_NAME, append=T)
}
write("SET IDENTITY_INSERT NAICS6 OFF;", file = FILE_NAME, append=T)
