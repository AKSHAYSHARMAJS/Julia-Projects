using SQLite
using DataFrames
using LinearAlgebra

print("\nReading Database\n")
db = SQLite.DB("names.db")

print("\nLoading Database to DataFrames\n")
data = DataFrames.DataFrame(SQLite.DBInterface.execute(db, "SELECT * from names"))



print("\nCalculating - Nb (number of boy names), Ng(number of girl names), Ny(number of years)\n")
distinct_names= combine(groupby(data, [:name, :sex]),nrow)
count_names = combine(groupby(distinct_names, [:sex]), nrow)
if(count_names[!,1][1] == "M")
	Nb = count_names[!, 2][1]
	Ng = count_names[!, 2][2]
else
	Nb = count_names[!, 2][2]
	Ng = count_names[!, 2][1]
end

d = combine(groupby(data,:year), nrow)
Ny = nrow(d)
minyr = minimum(d[!,1])
minyr -= 1
print("\nNb = ",Nb, "\nNg = ", Ng,"\nNy = ",Ny,"\n")



boy_name = Dict{String,Int32}()  #boy_name => boy_index
girl_name = Dict{String, Int32}()   #girl_name => girl_index


print("\nCreating Fb(Nb x Ny) and Fg(Ng x Ny)\n")
Fb = zeros(Int32, Nb, Ny)
Fg = zeros(Int32, Ng, Ny)
Ty = zeros(Int32, Ny)
index_boy = 1
index_girl = 1
for entry in eachrow(data)
    if(entry[2] == "M")
        if(!haskey(boy_name, entry[1]))
            boy_name[entry[1]] = index_boy
            global index_boy += 1
        end            
        Fb[boy_name[entry[1]], entry[4] - minyr] = entry[3]
        Ty[entry[4] - minyr] += entry[3]
    else
        if(!haskey(girl_name, entry[1]))
            girl_name[entry[1]] = index_girl
            global index_girl += 1
        end
        Fg[girl_name[entry[1]], entry[4] - minyr] = entry[3]
        Ty[entry[4] - minyr] += entry[3]
    end
end


print("\nComputing Pb and Pg\n")
Pb = zeros(Float32, Nb, Ny) 
Pg = zeros(Float32, Ng, Ny)
for i = 1:Nb
    for j = 1:Ny
        Pb[i,j] = Fb[i,j] / Ty[j]
    end
end

for i = 1:Ng
    for j = 1:Ny
        Pg[i,j] = Fg[i,j] / Ty[j]
    end
end



print("\nNormalizing Pb & Pg and Storing in Qb & Qg\n")
Qb = zeros(Float32, Nb, Ny)
Qg = zeros(Float32, Ng, Ny)
for i = 1:Nb
    Qb[i,:] = normalize(Pb[i,:])
end
for i = 1:Ng
    Qg[i,:] = normalize(Pg[i,:])
end



boy_name_rev = Dict(b=>a for (a,b) in boy_name)  #boy_index => boy_name 
girl_name_rev = Dict(b=>a for (a,b) in girl_name) ##girl_index => girl_name 



print("\nPartitioning Qb rows into 10 parts\n")
### Partitioning the row index of Qb into 10 parts
l = Nb / 10
l = Int(floor(l))
i = l
start = 1
part_rows_boy = []
if(Nb%10 == 0)
    for j = 1:10
        push!(part_rows_boy, (start,i))
        global start = i + 1
        global i += l
    end
else
    for j = 1:9
        push!(part_rows_boy, (start,i))
        global start = i + 1
        global i += l
    end
    global i += Nb % 10
    push!(part_rows_boy, (start,i))
end



print("\nPartitioning Qg rows into 10 parts\n")
# Partitioning the row index of Qg into 10 parts
l = Ng / 10
l = Int(floor(l))
i = l
start = 1
part_rows_girl = []
if(Ng%10 == 0)
    for j = 1:10
        push!(part_rows_girl, (start,i))
        global start = i + 1
        global i += l
    end
else
    for j = 1:9
        push!(part_rows_girl, (start,i))
        global start = i + 1
        global i += l
    end
    global i += Ng % 10
    push!(part_rows_girl, (start,i))
end



print("\nComputing Cosine Distances\n\n")
print("\nMaximum Cosine Distance for each 100 (10 * 10) possible pair of fragments\n\n")
i1 = 1
Max = -1   #stores maximum Cosine Distance value
final_boy = ""   #stores index of boy name corresponding to Max value of dot product
final_girl = ""  #stores index of girl name corresponding to Max value of dot product
#BLAS.set_num_threads(8)
@time while(i1 <= 10)
    i2 = 1
    while(i2 <= 10)
        matrix1 = Qb[part_rows_boy[i1][1]:part_rows_boy[i1][2],:]    #Storing one fragment of Qb
        matrix2 = Qg[part_rows_girl[i2][1]:part_rows_girl[i2][2],:]   #Storing one fragment of Qg
        BLAS.set_num_threads(10)  #parallelization of matrix multiplication
        mul = matrix1 * matrix2'
        k = findmax(mul)   #finds maximum dot product in current iteration
        println(k[1]," ",boy_name_rev[k[2][1] + part_rows_boy[i1][1] - 1]," ",girl_name_rev[k[2][2] + part_rows_girl[i2][1] - 1])
        if(k[1] >= Max)
            global Max = k[1]
            global final_boy = boy_name_rev[k[2][1] + part_rows_boy[i1][1] - 1]
            global final_girl = girl_name_rev[k[2][2] + part_rows_girl[i2][1] - 1]
        end
        i2 += 1
    end
    global i1 += 1
end
print("\n\nOverall Maximum Cosine Distance\n")
print("\nBoy Name = ",final_boy, "\nGirl Name = ", final_girl, "\nCosine Distance = ", Max," \n")
