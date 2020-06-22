include("resolution.jl")

"""
On met en place une résolution dichotomique du problème des p-centres
Arguments:
- A: matrice de flottant de taille m*n representant la distance des clients aux entrepots
- p: la valeur du problème des p-centres
- method: chaine de caractère reresentant la méthode de résolution
"""

function pCentre(matriceDistance::Array{Float64, 2}, p::Int64, methode::String = "branchAndBoundCoupe")
 
    m = size(matriceDistance)[1]
    n = size(matriceDistance)[2]

    # On récupère l'ensemble des distances
    vecteurDistance = Array{Float64}(undef, m * n)

    for i in 1:m

        for j in 1:n

            vecteurDistance[(i - 1) * m + j] = matriceDistance[i, j]
        
        end
    end

    # On ne garde qu'une seule occurance de chaque distance
    vecteurDistance = sort(unique(vecteurDistance))


    nbDistance = size(vecteurDistance)[1]
    

    # On initialise les valeurs de la dichotomie
    borneInf = 1
    borneSup = nbDistance
    dichotomie = div(borneSup + borneInf, 2)
    tailleDichotomie = borneSup - borneInf + 1
    distanceDichotomie = vecteurDistance[dichotomie]
    matriceDichotomie = Array{Float64}(undef, m, n)
    solvable = Array{Float64}(undef, n)
    x = Array{Float64}(undef, n)
    # Tant que l'on a pas finis la dichotomie

    while tailleDichotomie != 1 

        # On modifie la matriceDichotomie en ne conservant que les distances inférieures à distanceDichotomie
        for i in 1:m

            for j in 1:n

                if matriceDistance[i, j] > distanceDichotomie

                    matriceDichotomie[i, j] = 0

                else

                    matriceDichotomie[i, j] = -1

                end    
            end
        end

        # On verifie que le problème de set-cover associé est solvable
        isSolvable = true
        solvable = Array{Float64}(undef, m)
        for i in 1:m

            solvable[i] = sum(matriceDichotomie[i, j] for j in 1:n)

        end
        println(solvable)
        println(matriceDichotomie)
        for j in 1:m

            if solvable[j] == 0

                isSolvable = false

            end
        end
        objectif = p + 1
        # Si le problème de set-cover peut-être résolue, on applique la méthode de résolution associée
        if isSolvable

            if methode == "branchAndBound"

                isOptimal, x, timeSolve, objectif, bestBound = branchAndBound(matriceDichotomie) 

            elseif methode == "branchAndBoundCoupe"

                isOptimal, x, timeSolve, objectif, bestBound = branchAndBoundCoupe(matriceDichotomie)

            elseif methode == "coupeSuccessive"

                isEntier, x, timeSolve, objectif, bestBound = coupeSuccessive(matriceDichotomie)
                
                    
                for j in 1:m

                    if abs(x[i]) <= 0.0001

                        x[i] = 0

                    else

                        x[i] = 1

                    end
                end                   
            end
        end

        # Si le problème de set-cover ne peut pas être résolue, ou qu'il est résolue en plus de p centres, on passe à l'itération suivante
        if !isSolvable || (isSolvable && objectif > p)

            borneInf = dichotomie + 1
            dichotomie = div(borneSup + borneInf, 2)
            tailleDichotomie = borneSup - borneInf + 1
            distanceDichotomie = vecteurDistance[dichotomie]

        elseif isSolvable && objectif <= p

            borneSup = dichotomie
            dichotomie = div(borneSup + borneInf, 2)
            tailleDichotomie = borneSup - borneInf + 1
            distanceDichotomie = vecteurDistance[dichotomie]

        end

    end

    return distanceDichotomie, x

end

