# Assignment 2
## CAP4770 Intro to Data Science

### Description

This project will implement data loading of Baby Names dataset with around 2 million tuples into SQLite Database. Dataset is a national data on the relative frequency of given names in the population of U.S. births where the individual has a Social Security Number. We will also perform simple data processing and plotting of a graph showing the frequency of a particular name over time in years. We will use Julia programming language for the project

### Data Loading(prepare.jl)

This Julia program(prepare.jl) will scan the zip file (names.zip) containing the different files for each year. The program will load each files' data to a temporary *Dataframe* variable. Dataframe will be written to a CSV file (names.csv) that will be used to directly load the entire Data to the SQLite database.
The program takes two command-line argument
* Name of the zip file
* Name of the database file

Also, we can directly read from the zip file and load to SQLite database using *prepared statement* but that will read each tuple row by row and there are about 2 million tuples. So it can take a lot of time. To speed up the process we have used *Dataframes* and *CSV file* to load the entire data in one go instead of reading line by line.

Add an extra column namely **years** to the table that will contain the year of births of the baby with the corresponding name. The years can be retrieved from the name of the file containing data. Each file has the name "yobXXXX.txt" format. Simply, extract the year from the name of each file.

Finally, the program will create **names.db** database with a table named *names*.


***libraries required***

Install the following libraries:
```
	SQLite
	ZipFile
	CSV
	DataFrames
```

Command to execute the program, run the following command into the terminal

` julia prepare.jl names.zip names.db`

**program takes around 2 minutes to execute but this can vary depending on the architecture**

### Plotting Graph(plot.jl)

This program(plot.jl) will scan the database, query the SQLite database and plot a graph based on the results from the query. The program takes three command-line arguments
* Name of the database file
* Name of the baby
* Sex of the baby

First, open the .db file and run the following query to retrieve the number of occurrences of the name and the year 
```
	SELECT num, year FROM names where name = ? AND sex = ? ORDER BY year
```
Load the results of the query to a *Dataframe* variable.

Now, simply plot the graph using Gadfly taking *num* column to Y-axis and *year* column to X-axis

The program will create a .svg file containing the graph. **Please use any browser to open the file**


***libraries required***

Install the following libraries:
```
	SQLite
	DataFrame
	Gadfly
```

Command to execute the program, run the following command into the terminal

` julia plot.jl names.db lia F`

**program takes around 1 minute to execute but this can vary depending on the architecture**
