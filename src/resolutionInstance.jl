include("io.jl")
import(GR)

"""
Resouds toutes les instance situées  dans ".../data" avec la résolution par branch&cut et des coupes successives

On enregistre les résultats dans ".../res/branchAndBound" et ".../res/coupeSuccessive"

"""

function solveDataSet()


    dataFolder = "../data/"
    resFolder = "../res/"

    if !isdir("../res")
        mkdir("../zerohalfforsetcover/res")
    end

    # On parcourt les fichier
    for file in filter(x->occursin(".txt", x), readdir(dataFolder))

        println("--Resolution of ", file)
        t = readInputFile(dataFolder * file)

        # On définie le fichier où est écrite la solution
        outputFile = resFolder * file

        # Si l'on a pas encore résolue l'instance
        if !isfile(outputFile)

            global instanceResolue = InstanceResolue()

            # On résoud l'instance considérée
            instanceResolue = InstanceResolue(Instance(t))
    
            # On ouvre le fichier
            fout = open(outputFile, "w")

            # On écrit la solution du branchAndBound
            println(fout, "xBranchAndBound = [")
            n = size(instanceResolue.xBranchAndBound)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBound[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBound[i],"]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBound = ", instanceResolue.tempsBranchAndBound)
            println(fout, "isOptimalBranchAndBound = ", instanceResolue.isOptimalBranchAndBound)
            println(fout, "DistanceBranchAndBound = ", instanceResolue.distanceBranchAndBound)

            println(fout,"xBranchAndBoundCoupe = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBoundCoupe[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBoundCoupe[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBoundCoupe = ", instanceResolue.tempsBranchAndBoundCoupe)
            println(fout, "isOptimalBranchAndBoundCoupe = ", instanceResolue.isOptimalBranchAndBoundCoupe)
            println(fout, "DistanceBranchAndBoundCoupe = ", instanceResolue.distanceBranchAndBoundCoupe)

            println(fout,"xCoupeSuccessive = [")
            n = size(instanceResolue.xCoupeSuccessive)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xCoupeSuccessive[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xCoupeSuccessive[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "solveTimeCoupeSuccessive = ", instanceResolue.tempsCoupeSuccessive)

            println(fout, "isOptimalCoupeSuccessive = ", instanceResolue.isOptimalCoupeSuccessive)
            println(fout, "DistanceCoupeSuccessive =  ", instanceResolue.distanceCoupeSuccessive)
            close(fout)

        end

    end         
end
