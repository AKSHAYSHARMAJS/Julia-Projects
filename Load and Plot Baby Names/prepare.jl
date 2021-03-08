# prepare.jl
import ZipFile
import SQLite 
import CSV
import DataFrames

input_file = ARGS[1]
output_file = ARGS[2]


zipped = ZipFile.Reader(input_file)

data = DataFrames.DataFrame(name=[], sex=[], num=[], year=[])

for file in zipped.files
	if(occursin("yob", file.name))
		for lines in readlines(file)
			push!(data, push!(split(lines, ','), file.name[4:7]))
		end
	end
end

close(zipped)

CSV.write("names.csv", data)

db = SQLite.DB(output_file)   
   
CSV.File("names.csv") |> SQLite.load!(db, "names")

close(db)