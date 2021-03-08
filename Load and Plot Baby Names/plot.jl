#plot.jl

import SQLite
import DataFrames
using Gadfly


db = SQLite.DB(ARGS[1])

in_name = ARGS[2]
in_name = uppercasefirst(in_name)
in_sex = ARGS[3]


data = DataFrames.DataFrame(SQLite.DBInterface.execute(db, "SELECT num, year FROM names where name = ? AND sex = ? ORDER BY year", [in_name, in_sex]))
 
p = Gadfly.plot(x=data[!,2], y=data[!,1], Geom.line, Guide.xlabel("Time in Years"), Guide.ylabel("Occurrences Of Name"))
img =  SVG("name_plot.svg")
draw(img, p)
