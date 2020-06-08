include("io.jl")
import(GR)

"""
Resouds toutes les instance situées  dans ".../data" avec la résolution par branch&cut et des coupes successives

On enregistre les résultats dans ".../res/branchAndBound" et ".../res/coupeSuccessive"

"""

function solveDataSet()


    dataFolder = "../data/"
    resFolder = "../res/"

    resolutionMethod = ["branchAndBound", "coupeSuccessive"]
    resolutionFolder = resFolder .* resolutionMethod
    if !isdir("../res")
        mkdir("../zerohalfforsetcover/res")
    end
    for folder in resolutionFolder
        if !isdir(folder)
            mkdir(folder)
        end
    end

    global isOptimal = false
    global solveTime = -1

    # On parcourt les fichier
    for file in filter(x->occursin(".txt", x), readdir(dataFolder))

        println("--Resolution of ", file)
        t = readInputFile(dataFolder * file)

        # On utilise les différentes méthodes de résolution
        for methodId in 1:size(resolutionMethod)[1]

            outputFile = resolutionFolder[methodId] * "/" * file
            println(outputFile)
            # If the input file has not already been solved by this methd
            if !isfile(outputFile)

                fout = open(outputFile, "w")

                resolutionTime = -1
                isOptimal = false

                # Si on applique le branchandbound
                if resolutionMethod[methodId] == "branchAndBound"

                    # On résouds et on recupère la solution
                    isOptimal, solution, resolutionTime = resolution(t)

                    # On note la solution
                    if isOptimal
                        writeSolution(fout, x)
                    end

                # Si on applique la methode de coupeSuccessive
                else

                    isSolved = false
                    solution = []

                    isOptimal, solution, resolutionTime = coupeSuccessive(t)
                    solution
                end

                print("\n")
                
                # On ecrit la solution
                if isOptimal
                    writeSolution(fout, solution)
                end

                println(fout, "solveTime = ", resolutionTime)
                println(fout, "isOptimal = ", isOptimal)
                close(fout)
            end

        # Display the results obtained with the method on the current instance
        # include(outputFile)
        println(resolutionMethod[methodId], " optimal: ", isOptimal)
        println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits=2)) * "s\n")

        end
    end         
end
