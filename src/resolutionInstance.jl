include("io.jl")
import(GR)

"""
Resouds toutes les instance situées  dans ".../data" avec la résolution par branch&cut et des coupes successives

On enregistre les résultats dans ".../res"

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

            # Resolution BranchAndBoundCoupe

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

            # Resolution BranchAndBoundCoupeReduit

            println(fout,"xBranchAndBoundCoupeReduit = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBoundCoupeReduit[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBoundCoupeReduit[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBoundCoupeReduit = ", instanceResolue.tempsBranchAndBoundCoupeReduit)
            println(fout, "isOptimalBranchAndBoundCoupeReduit = ", instanceResolue.isOptimalBranchAndBoundCoupeReduit)
            println(fout, "DistanceBranchAndBoundCoupeReduit = ", instanceResolue.distanceBranchAndBoundCoupeReduit)

            # Resolution BranchAndBoundRien

            println(fout,"xBranchAndBoundRien = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBoundRien[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBoundRien[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBoundRien = ", instanceResolue.tempsBranchAndBoundRien)
            println(fout, "isOptimalBranchAndBoundRien = ", instanceResolue.isOptimalBranchAndBoundRien)
            println(fout, "DistanceBranchAndBoundRien = ", instanceResolue.distanceBranchAndBoundRien)

            # Resolution BranchAndBoundPNLE

            println(fout,"xBranchAndBoundPNLE = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBoundPNLE[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBoundPNLE[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBoundPNLE = ", instanceResolue.tempsBranchAndBoundPNLE)
            println(fout, "isOptimalBranchAndBoundPNLE = ", instanceResolue.isOptimalBranchAndBoundPNLE)
            println(fout, "DistanceBranchAndBoundPNLE = ", instanceResolue.distanceBranchAndBoundPNLE)

            # Resolution BranchAndBoundPNLEHighlyViolated

            # println(fout,"xBranchAndBoundPNLEHighlyViolated = [")
            # for i in 1:n
            
            #     if i != n

            #         println(fout,"[", instanceResolue.xBranchAndBoundPNLEHighlyViolated[i], "];")

            #     else
                    
            #         println(fout,"[", instanceResolue.xBranchAndBoundPNLEHighlyViolated[i], "]") 

            #     end
            # end
            # println(fout,"]")
            # println(fout, "solveTimeBranchAndBoundPNLEHighlyViolated = ", instanceResolue.tempsBranchAndBoundPNLEHighlyViolated)
            # println(fout, "isOptimalBranchAndBoundPNLEHighlyViolated = ", instanceResolue.isOptimalBranchAndBoundPNLEHighlyViolated)
            # println(fout, "DistanceBranchAndBoundHighlyViolated = ", instanceResolue.distanceBranchAndBoundPNLEHighlyViolated)

            # Resolution BranchAndBoundRien

            println(fout,"xBranchAndBoundRien = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", instanceResolue.xBranchAndBoundRien[i], "];")

                else
                    
                    println(fout,"[", instanceResolue.xBranchAndBoundRien[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "solveTimeBranchAndBoundRien = ", instanceResolue.tempsBranchAndBoundRien)
            println(fout, "isOptimalBranchAndBoundRien = ", instanceResolue.isOptimalBranchAndBoundRien)
            println(fout, "DistanceBranchAndBoundRien = ", instanceResolue.distanceBranchAndBoundRien)


            # Redsolution CoupeSuccessive

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

            # On ecrit les résultats des bornes 
            println(fout, "borneUb0etLb0 = ", pCentreResolu.borneUb0etLb0)
            println(fout, "timeUb0etLb0 = ", pCentreResolu.timeUb0etLb0)
            println(fout, "borneUb1etLb1 = ", pCentreResolu.borneUb1etLb1)
            println(fout, "timeUb1etLb1 = ", pCentreResolu.timeUb1etLb1)
            println(fout, "borneRelaxation = ", pCentreResolu.borneRelaxation)
            println(fout, "timeRelaxation = ", pCentreResolu.timeRelaxation)

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

            # On écrit la solution du branchAndBoundBorne
            println(fout, "distanceBranchAndBoundBorne = ", pCentreResolu.distanceBranchAndBoundBorne)
            println(fout, "xBranchAndBoundBorne = [")
            n = size(pCentreResolu.xBranchAndBoundBorne)[1]
            for i in 1:n

                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundBorne[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundBorne[i],"]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundBorne = ", pCentreResolu.resolutionTimeBranchAndBoundBorne)

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
            println(fout, "resolutionTimeBranchAndBoundCoupeBorne = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeBorne)

            # On ecrit la solution du branchAndBoundCoupeReduit
            println(fout, "distanceBranchAndBoundCoupeReduit = ", pCentreResolu.distanceBranchAndBoundCoupeReduit)
            println(fout,"xBranchAndBoundCoupeReduit = [")
            for i in 1:n

                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeReduit[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeReduit[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundCoupeBorne = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeBorne)

            # On ecrit la solution du branchAndBoundRien
            println(fout, "distanceBranchAndBoundRien = ", pCentreResolu.distanceBranchAndBoundRien)
            println(fout,"xBranchAndBoundRien = [")
            for i in 1:n

                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundRien[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundRien[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundRien = ", pCentreResolu.resolutionTimeBranchAndBoundRien)


            # On ecrit la solution du branchAndBoundPNLE
            println(fout, "distanceBranchAndBoundPNLE = ", pCentreResolu.distanceBranchAndBoundPNLE)
            println(fout,"xBranchAndBoundPNLE = [")
            for i in 1:n

                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundPNLE[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundPNLE[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundPNLE = ", pCentreResolu.resolutionTimeBranchAndBoundPNLE)

            # On ecrit la solution du branchAndBoundPNLEHighlyViolated
            # println(fout, "distanceBranchAndBoundPNLEHighlyViolated = ", pCentreResolu.distanceBranchAndBoundPNLEHighlyViolated)
            # println(fout,"xBranchAndBoundPNLEHighlyViolated = [")
            # for i in 1:n

            #     if i != n

            #         println(fout,"[", pCentreResolu.xBranchAndBoundPNLEHighlyViolated[i], "];")

            #     else
                    
            #         println(fout,"[", pCentreResolu.xBranchAndBoundPNLEHighlyViolated[i], "]") 

            #     end
            # end
            # println(fout,"]")
            # println(fout, "resolutionTimeBranchAndBoundPNLEHighlyViolated = ", pCentreResolu.resolutionTimeBranchAndBoundPNLEHighlyViolated)

            # # On ecrit la solution de BranchAndBoundCoupeRelaxation
            # println(fout, "distanceBranchAndBoundCoupeRelaxation = ", pCentreResolu.distanceBranchAndBoundCoupeRelaxation)
            # println(fout,"xBranchAndBoundCoupeRelaxation = [")
            # for i in 1:n
            
            #     if i != n

            #         println(fout,"[", pCentreResolu.xBranchAndBoundCoupeRelaxation[i], "];")

            #     else
                    
            #         println(fout,"[", pCentreResolu.xBranchAndBoundCoupeRelaxation[i], "]") 

            #     end
            # end
            # println(fout,"]")
            # println(fout, "resolutionTimeBranchAndBoundCoupeRelaxation = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeRelaxation)


            # On ecrit la solution de BranchAndBoundCoupeBorne
            println(fout, "distanceBranchAndBoundCoupeBorne = ", pCentreResolu.distanceBranchAndBoundCoupeBorne)
            println(fout,"xBranchAndBoundCoupeBorne = [")
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeBorne[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xBranchAndBoundCoupeBorne[i], "]") 

                end
            end
            println(fout,"]")
            println(fout, "resolutionTimeBranchAndBoundCoupeBorne = ", pCentreResolu.resolutionTimeBranchAndBoundCoupeBorne)


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
            n = size(pCentreResolu.xCoupeSuccessiveBorne)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xCoupeSuccessiveRelaxation[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xCoupeSuccessiveRelaxation[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeCoupeSuccessiveRelaxation = ", pCentreResolu.resolutionTimeCoupeSuccessiveRelaxation)


            # On ecrit la solution de coupeSuccessiveBorne
            println(fout, "distanceCoupeSuccessiveBorne = ", pCentreResolu.distanceCoupeSuccessiveBorne)
            println(fout,"xCoupeSuccessiveBorne = [")
            n = size(pCentreResolu.xCoupeSuccessiveBorne)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xCoupeSuccessiveBorne[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xCoupeSuccessiveBorne[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimeCoupeSuccessiveBorne = ", pCentreResolu.resolutionTimeCoupeSuccessiveBorne)

            # On ecrit la resolution de PC-SC
            println(fout, "distancePCSC = ", pCentreResolu.distancePCSC)
            println(fout,"xPCSC = [")
            n = size(pCentreResolu.xPCSC)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xPCSC[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xPCSC[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimePCSC = ", pCentreResolu.resolutionTimePCSC)

            # On ecrit la solution de PCSCRelaxation
            println(fout, "distancePCSCRelaxation = ", pCentreResolu.distancePCSCRelaxation)
            println(fout,"xPCSCRelaxation = [")
            n = size(pCentreResolu.xPCSCBorne)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xPCSCRelaxation[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xPCSCRelaxation[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimePCSCRelaxation = ", pCentreResolu.resolutionTimePCSCRelaxation)


            # On ecrit la solution de PCSCBorne
            println(fout, "distancePCSCBorne = ", pCentreResolu.distancePCSCBorne)
            println(fout,"xPCSCBorne = [")
            n = size(pCentreResolu.xPCSCBorne)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xPCSCBorne[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xPCSCBorne[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimePCSCBorne = ", pCentreResolu.resolutionTimePCSCBorne)

            # On ecrit la resolution de PC
            println(fout, "distancePC = ", pCentreResolu.distancePC)
            println(fout,"xPC = [")
            n = size(pCentreResolu.xPC)[1]
            for i in 1:n
            
                if i != n

                    println(fout,"[", pCentreResolu.xPC[i], "];")

                else
                    
                    println(fout,"[", pCentreResolu.xPC[i], "]") 

                end
            end
            println(fout,"]")

            println(fout, "ResolutionTimePC = ", pCentreResolu.resolutionTimePC)

            # On ecrit la solution de RelaxationClassique
            println(fout, "distanceRelaxatio        nClassique = ", pCentreResolu.distanceRelaxationClassique)
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

function solveAllDataSet()

    solveDataSet()
    solvePCentreDataSet()

end
