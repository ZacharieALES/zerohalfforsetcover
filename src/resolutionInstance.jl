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

function solvePCentreDataSet()

    dataFolder = "../dataPCentre/"
    resFolder = "../resPCentre/"

    if !isdir("../resPCentre")
        mkdir("../zerohalfforsetcover/resPCentre")
    end

    # On parcours les fichiers
    for file in filter(x->occursin(".txt", x), readdir(dataFolder))

        println("--Resolution of ", file)
        t, p = readInputFilePCentre(dataFolder * file)

        # On définie le fichier où est écrite la solution
        outputFile = resFolder * file

        # Si l'on a pas encore résolue l'instance
        if !isfile(outputFile)

            global pCentreResolu = PCentreResolu()

            # On résoud l'instance considérée
            pCentreResolu = PCentreResolu(t, p)
    
            # On ouvre le fichier
            fout = open(outputFile, "w")

            # On écrit la solution du branchAndBound
            println(fout, "distanceBranchAndBound = ", pCentreResolu.distanceBranchAndBound)
            println(fout, "xBranchAndBound = [")
            n = size(pCentreResolu.xBranchAndBound)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBound[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBound[i],"]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBound = ", pCentreResolu.resolutionTimeBranchAndBound)

            # On écrit la solution du branchAndBoundRelaxation
            println(fout, "distanceBranchAndBoundRelaxation = ", pCentreResolu.distanceBranchAndBoundRelaxation)
            println(fout, "xBranchAndBoundRelaxation = [")
            n = size(pCentreResolu.xBranchAndBoundRelaxation)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundRelaxation[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundRelaxation[i],"]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundRelaxation = ", pCentreResolu.resolutionTimeBranchAndBoundRelaxation)


            # On ecrit la solution du branchAndBoundCoupe
            println(fout, "distanceBranchAndBoundCoupe = ", pCentreResolu.distanceBranchAndBoundCoupe)
            println(fout,"xBranchAndBoundCoupe = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupe[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupe[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundCoupeRelaxation = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeRelaxation)

            # On ecrit la solution de BranchAndBoundCoupeSuccessive
            println(fout, "distanceBranchAndBoundCoupeRelaxation = ", pCentreResolu.distanceBranchAndBoundCoupeRelaxation)
            println(fout,"xBranchAndBoundCoupeRelaxation = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeRelaxation[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeRelaxation[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundCoupeRelaxation = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeRelaxation)


            # On ecrit la resolution de coupeSuccessive
            println(fout, "distanceCoupeSuccessive = ", pCentreResolu.distanceCoupeSuccessive)
            println(fout,"xCoupeSuccessive = [")
            n = size(pCentreResolu.xCoupeSuccessive)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xCoupeSuccessive[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xCoupeSuccessive[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeCoupeSuccessive = ", pCentreResolu.resolutionTimeCoupeSuccessive)

            # On ecrit la solution de coupeSuccessiveRelaxation
            println(fout, "distanceCoupeSuccessiveRelaxation = ", pCentreResolu.distanceCoupeSuccessiveRelaxation)
            println(fout,"xCoupeSuccessiveRelaxation = [")
            n = size(pCentreResolu.xCoupeSuccessiveRelaxation)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xCoupeSuccessiveRelaxation[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xCoupeSuccessiveRelaxation[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeCoupeSuccessiveRelaxation = ", pCentreResolu.resolutionTimeCoupeSuccessiveRelaxation)

            # On ecrit la solution de RelaxationClassique
            println(fout, "distanceRelaxationClassique = ", pCentreResolu.distanceRelaxationClassique)
            println(fout,"xRelaxationClassique = [")
            n = size(pCentreResolu.xRelaxationClassique)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xRelaxationClassique[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xRelaxationClassique[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeRelaxationClassique = ", pCentreResolu.resolutionTimeRelaxationClassique)

            # On ecrit la solution de RelaxationCoupe
            println(fout, "distanceRelaxationCoupe = ", pCentreResolu.distanceRelaxationCoupe)
            println(fout,"xRelaxationCoupe = [")
            n = size(pCentreResolu.xRelaxationCoupe)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xRelaxationCoupe[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xRelaxationCoupe[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeRelaxationCoupe = ", pCentreResolu.resolutionTimeRelaxationCoupe)

            close(fout)

        end

    end         
end
