using JuMP
using CPLEX
include("resolution.jl")
include("coupe_successive.jl")


"""
Fais la lecture d'une instance à partir d'un fichier

Argument:
- inputFile: path of the input inputFile
"""

function readInputFile(inputFile::String)

    # Ouvre le fichier
    datafile = open(inputFile)

    data = readlines(datafile)
    close(datafile)

    n = length(split(data[1], ","))
    m = 0
    for line in data
        
        lineSplit = split(line, ",")

        if size(lineSplit, 1) == n
            m = m + 1
        end
    end

    t = Array{Float64}(undef, m, n)

    lineNb = 1

    # For each line of the input inputFile
    for line in data

        lineSplit = split(line, ",")

        if size(lineSplit, 1) == n
            for colNb in 1:n
                t[lineNb, colNb] = Float64(parse(Int64, lineSplit[colNb]))
            end
        end

        lineNb = lineNb + 1

    end 

    return t

end


"""
Sauvegarde une grille dans un fichier .txt

Argument
- t: matrice de flottant de taile m*colNb
- outputFile: chemin d'acce du fichier de sortie
"""

function saveInstance(t::Array{Float64, 2}, outputFile::String)

    m = size(t)[1]
    n = size(t)[2]

    # Ouvre le fichier de sortie
    writer = open(outputFile, "w")

    # On parcours la matrice
    for i in 1:m
        for j in 1:n

            # On ecrit la valeur de chaque case
            print(writer, " ")
            print(writer, Int64(t[i, j]))

            if j != n
                print(writer, ",")
            else
                print(writer, "\n")
            end
        end
    end

    close(writer)
end

"""
Ecrit une solution dans un flux de sortie

Arguments
- fout: le flux de sortie
- x: vecteur de variable ref de taille n
"""

function writeSolution(fout::IOStream, x::Array{VariableRef, 1})

    # Convertie la solution en flottant
    n = size(x)[1]
    t = Array{Float64}(undef, n)

    for i in 1:n
        t[i] = JuMP.value(x[i])
    end

    # Ecrit la solution
    writeSolution(fout, t)
end

"""
Ecrit une solution dans un flux de sortie

Arguments
- fout: le flux de sortie
- x: vecteur de flottant de taille n
"""

function writeSolution(fout::IOStream, t::Array{Float64, 1})

    n = size(t)[1]
    println("Solution : ")
    for i in 1:n
        println(fout, "x[", i, "] = [",t[i], "]")
    end
end
