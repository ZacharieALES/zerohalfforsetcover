using JuMP
using CPLEX
using Plots
import GR
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
Fais la lecture d'une instance de PCentre à partir d'un fichier

Argument:
- inputFile: path of the input inputFile
"""

function readInputFilePCentre(inputFile::String)

    # Ouvre le fichier
    datafile = open(inputFile)

    data = readlines(datafile)
    close(datafile)

    n = length(split(data[2], ","))
    p = parse(Int64, split(data[1], ",")[1])
    m = 0
    for line in data
        
        lineSplit = split(line, ",")

        if size(lineSplit, 1) == n
            m = m + 1
        end
    end

    t = Array{Float64}(undef, m, n)

    lineNb = 0

    # For each line of the input inputFile
    for line in data

        lineSplit = split(line, ",")

        if size(lineSplit, 1) == n && lineNb != 0
            for colNb in 1:n
                t[lineNb, colNb] = Float64(parse(Int64, lineSplit[colNb]))
            end
        end

        lineNb = lineNb + 1

    end 

    return t, p

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
Sauvegarde d'une instance dans un fichier .txt

Argument :
- A: Matrice de flottant de taille m*n
- p 
- outputFile: chemin d'acce du fichier de sorti
"""

function savePCentreInstance(t::Array{Float64, 2}, p::Int64, outputFile::String)

    m = size(t)[1]
    n = size(t)[2]

    # Ouvre le fichier de sortie
    writer = open(outputFile, "w")
    print(writer, p, ",\n")
    # On parcours la matrice
    for i in 1:m


        for j in 1:n
            # On ecrit la valeur de chaque case
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
        println(fout, t[i])
    end
end

"""
Creer un fichier .txt compilable en latex, donnant un tableau avec les résultats du dossier ../res

Argument
-chemin du fichier de sortie (par defaut le dossier doc )
"""

function resultsArray(outputFile::String = "../doc/resultatTableau.txt")

    resFolder = "C:/Users/Luc/Documents/RO_PRE/zerohalfforsetcover/res/"
    dataFolder = "C:/Users/Luc/Documents/RO_PRE/zerohalfforsetcover/data/"


    # Nombre maximal de fichier 
    maxSize = 0

    # On ouvre le fichier de sortie
    fout = open(outputFile, "w")

    # On ecrit l'entete d'un fichier latex
    # Print the latex file output
    println(fout, raw"""\documentclass{article}

\usepackage[french]{babel}
\usepackage [utf8] {inputenc} % utf-8 / latin1 
\usepackage{multicol}

\setlength{\hoffset}{-18pt}
\setlength{\oddsidemargin}{0pt} % Marge gauche sur pages impaires
\setlength{\evensidemargin}{9pt} % Marge gauche sur pages paires
\setlength{\marginparwidth}{54pt} % Largeur de note dans la marge
\setlength{\textwidth}{481pt} % Largeur de la zone de texte (17cm)
\setlength{\voffset}{-18pt} % Bon pour DOS
\setlength{\marginparsep}{7pt} % Séparation de la marge
\setlength{\topmargin}{0pt} % Pas de marge en haut
\setlength{\headheight}{13pt} % Haut de page
\setlength{\headsep}{10pt} % Entre le haut de page et le texte
\setlength{\footskip}{27pt} % Bas de page + séparation
\setlength{\textheight}{668pt} % Hauteur de la zone de texte (25cm)

\begin{document}""")

        header = raw"""
\begin{center}
\renewcommand{\arraystretch}{1.4} 
\begin{tabular}{l"""       

    # Liste des instances résolues
    solvedInstances = Array{String, 1}()

    # Liste de méthode de résolution
    resolution = ["BranchAndBound"; "BranchAndBoundCoupe"; "CoupeSuccessive"]

    # Pour chaque fichier dans le fichier de résultats
    for file in filter(x->occursin(".txt", x), readdir(resFolder))

        # On ajoute les fichiers dans solvedInstance
        solvedInstances = vcat(solvedInstances, file)

        maxSize = maxSize + 1

    end

    # On ajoute 3 colonnes dans le tableau pour chaque méthode de résolution
    for methode in resolution

        header *= "rr"

    end

    header *= "}\n\t\\hline\n"

    # On crée la ligne de tête qui contient la méthode de résolution
    for methode in resolution

        header *= " &  \\multicolumn{2}{c}{\\textbf{" * methode * "}}"

    end

    header *= "\\\\\n\\textbf{Instance} "

    # On crée la seconde ligne de tête qui contient la colonne de résultats
    for methode in resolution 

        if methode == "CoupeSuccessive"

            header *= " & \\textbf{Temps (s)} & \\textbf{Entière ?} } "

        else

            header *= " & \\textbf{Temps (s)} & \\textbf{Optimal ?} } "

        end
    end

    header *= "\\\\\\hline\n"

    footer = raw"""\hline\end{tabular}
\end{center}

"""
 
    println(fout, header)

    # On limite le nombre d'instance par page
    maxInstancePerPage = 30
    id = 1

    # Pour chaque fichier de résolution 
    for solvedInstance in solvedInstances
        include(resFolder * solvedInstance)
        # Si on ne met pas un tableau sur une nouvelle page
        if rem(id, maxInstancePerPage) == 0

            println(fout, footer, "\\newpage")
            println(fout, header)

        end 

        # On remplace l'underscore dans les noms de fichiers
        print(fout, replace(solvedInstance, "_" => "\\_"))

        # Pour chaque méthode de résolution 
        for method in resolution
            if method == "BranchAndBound"

                println(fout, " & ", round(solveTimeBranchAndBound, digits=2), " & ")
                if isOptimalBranchAndBound

                    println(fout, "\$\\times\$")

                end 
                # println(fout, " & ", round(DistanceBranchAndBound, digits=2), " & ")

            elseif method == "BranchAndBoundCoupe"

                println(fout, " & ", round(solveTimeBranchAndBoundCoupe, digits=2), " & ")
                if isOptimalBranchAndBoundCoupe

                    println(fout, "\$\\times\$")

                end 
                # println(fout, " & ", round(DistanceBranchAndBoundCoupe, digits=2), " & ")

            elseif method == "CoupeSuccessive"

                println(fout, " & ", round(solveTimeCoupeSuccessive, digits=2), " & ")
                if isOptimalCoupeSuccessive

                    println(fout, "\$\\times\$")

                end 
                # println(fout, " & ", round(DistanceCoupeSuccessive, digits=2), " & ")
            
            end

        end

        println(fout, "\\\\")

        id += 1
    end

    # On ecrit la fin du fichier 
    println(fout, footer)

    println(fout, "\\end{document}")

    close(fout)
    
end 

"""
Creer un fichier .pdf qui contient les diagrammes de performances associées aux résultats
Renvoies une courbe pour chaque méthode

Argument :
-outputFile: chemin du fichier de sortie
"""

function performanceDiagram(outputFile::String = "../doc/performanceDiagram")

    resFolder = "../res/"

    # Liste des méthodes utilisées
    method = ["branchAndBound"; "branchAndBoundCoupe"; "coupeSuccessive"]

    # Nombre de méthodes employées
    nbMethod = size(method)[1]

    # Nombre de fichier
    nbFile = size(readdir(resFolder))[1]

    # Tableau qui contient les temps de résolutions de toutes les instances
    solveTime = Array{Float64}(undef, nbMethod, nbFile)
    distance = Array{Float64}(undef, nbMethod, nbFile)

    for i in 1:nbMethod

        for j in 1:nbFile

            solveTime[i, j] = Inf 
            distance[i, j] = Inf 

        end
    end

    maxSolveTime = zeros(Float64, 4)
    maxDistance = zeros(Float64, 4)

    countFile = 0

    # On parcours le fichier de résultat
    for file in filter(x->occursin(".txt", x), readdir(resFolder))

        countFile = countFile + 1

        # On recupère les données du fichier
        include(resFolder * file)
    
        if isOptimalBranchAndBound

            solveTime[1, countFile] = solveTimeBranchAndBound

            if maxSolveTime[1] < solveTimeBranchAndBound

                maxSolveTime[1] = solveTimeBranchAndBound

            end
        end

        if isOptimalBranchAndBoundCoupe

            solveTime[2, countFile] = solveTimeBranchAndBound

            if maxSolveTime[2] < solveTimeBranchAndBound

                maxSolveTime[2] = solveTimeBranchAndBound

            end
        end

        if isOptimalCoupeSuccessive

            solveTime[3, countFile] = solveTimeCoupeSuccessive

            if maxSolveTime[3] < solveTimeCoupeSuccessive

                maxSolveTime[3] = solveTimeCoupeSuccessive

            end
        end

        distance[1, countFile] = DistanceBranchAndBound

        if maxDistance[1] < DistanceBranchAndBound

            maxDistance[1] = DistanceBranchAndBound
        
        end

        distance[2, countFile] = DistanceBranchAndBoundCoupe

        if maxDistance[2] < DistanceBranchAndBoundCoupe

            maxDistance[2] = DistanceBranchAndBoundCoupe
        
        end

        distance[3, countFile] = DistanceCoupeSuccessive

        if maxDistance[3] < DistanceCoupeSuccessive

            maxDistance[3] = DistanceCoupeSuccessive
        
        end
    end

    maxSolveTime[4] = maxSolveTime[1]

    if maxSolveTime[4] < maxSolveTime[2]

        maxSolveTime[4] < maxSolveTime[2]

    end

    if maxSolveTime[4] < maxSolveTime[3]

        maxSolveTime[4] < maxSolveTime[3]
        
    end

    maxDistance[4] = maxDistance[1]

    if maxDistance[4] < maxDistance[2]

        maxDistance[4] < maxDistance[2]

    end

    if maxDistance[4] < maxDistance[3]

        maxDistance[4] < maxDistance[3]
        
    end

    # On trie chaque ligne
    solveTime = sort(solveTime, dims = 2)
    distance = sort(distance, dims = 2)
    println("Max solve time branch and bound = ", maxSolveTime[1])
    println("Max solve time branch and bound coupe = ", maxSolveTime[2])
    println("Max solve time coupe successive = ", maxSolveTime[3])
    println("Max distance branch and bound = ", maxDistance[1])
    println("Max distance branch and bound coupe = ", maxDistance[2])
    println("Max Distance coupe successive = ", maxDistance[3])

    # Pour chaque méthode à afficher, on étudie le temps de résolution
    for dim in 1:size(method)[1]

        x = Array{Float64, 1}()
        y = Array{Float64, 1}()

        # coordonnée du point precedent 
        previousX = 0.0
        previousY = 0.0

        append!(x, previousX)
        append!(y, previousY)

        # Position actuelle
        currentId = 1

        # Tant que l'on a pas atteint la fin
        while currentId != size(solveTime)[2] && solveTime[dim, currentId] != Inf

            # Nombre de valeur identique à previous X
            identicalValues = 1

            while solveTime[dim, currentId] == previousX && currentId <= size(solveTime)[2]

                currentId = currentId + 1
                identicalValues = identicalValues + 1
            end

            # On ajoute le points
            append!(x, previousX)
            append!(y, currentId - 1)

            if solveTime[dim, currentId] != Inf
                append!(x, solveTime[dim, currentId])
                append!(y, currentId - 1)
            end
            
            previousX = solveTime[dim, currentId]
            previousY = currentId - 1

        end

        append!(x, maxSolveTime[size(maxSolveTime)[1]])
        append!(y, currentId - 1)

        # Si c'est la première méthode traitée
        if dim == 1

            # On crée un nouveau plot
            plot(x, y , label = method[dim], legend = :bottomright, xaxis = "Time (s)", yaxis = "Solved instances",linewidth=3)

        else

            # On ajoute la courbe
            savefig(plot!(x, y, label = method[dim], linewidth=3), outputFile)      
        
        end
    end 
end