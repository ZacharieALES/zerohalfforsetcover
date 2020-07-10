include("resolutionInstance.jl")

"""
On met en place une résolution dichotomique du problème des p-centres
Arguments:
- A: matrice de flottant de taille m*n representant la distance des clients aux entrepots
- p: la valeur du problème des p-centres
- method: chaine de caractère reresentant la méthode de résolution
"""

function pCentreEntier(matriceDistance::Array{Float64, 2}, p::Int64, methode::String = "branchAndBoundCoupe", relaxation::Bool = false)
 
    start = time()
    m = size(matriceDistance)[1]
    n = size(matriceDistance)[2]

    # On récupère l'ensemble des distances
    vecteurDistance = Array{Float64}(undef, m * n)

    for i in 1:m

        for j in 1:n

            vecteurDistance[(i - 1) * n + j] = matriceDistance[i, j]
        
        end
    end

    # On ne garde qu'une seule occurance de chaque distance
    vecteurDistance = sort(unique(vecteurDistance))

    # On regarde le problème dans le cadre continue pour le simplifier
    if relaxation

        distanceMin, x = pCentreRelaxation(matriceDistance, p, "classique")

        # On cherche l'indice du premier element supérieur ou égal a distanceMin
        nbDistance = size(vecteurDistance)[1]
        indice = 0
        traite = false
        for i in 1:nbDistance

            if !traite && distanceMin >= vecteurDistance[i]

                traite = true
                indice = i
            
            end
        end

        # On supprime les distances inférieure ou égale à distanceMin
        vecteurDistance = vecteurDistance[indice:nbDistance]
        
    end

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

                isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie)

            elseif methode == "coupeSuccessive"

                isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = coupeSuccessive(matriceDichotomie)
                
                    
                for j in 1:n

                    if abs(x[j]) <= 0.0001

                        x[j] = 0

                    else

                        x[j] = 1

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

    return distanceDichotomie, x, time() - start

end

function pCentreRelaxation(matriceDistance::Array{Float64, 2}, p::Int64, methode::String = "classique", nb_coupe::Int64 = 10, epsilon::Array{Float64, 1} = [0.0001; 0.001])

    start = time()
    m = size(matriceDistance)[1]
    n = size(matriceDistance)[2]

    # On récupère l'ensemble des distances
    vecteurDistance = Array{Float64}(undef, m * n)

    for i in 1:m

        for j in 1:n

            vecteurDistance[(i - 1) * n + j] = matriceDistance[i, j]
        
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

        # On initialise un vecteur b de taille m 
        b = -ones(Float64, m)

        # On verifie que le problème de set-cover associé est solvable
        isSolvable = true
        solvable = Array{Float64}(undef, m)
        for i in 1:m

            solvable[i] = sum(matriceDichotomie[i, j] for j in 1:n)

        end

        for j in 1:m

            if solvable[j] == 0

                isSolvable = false

            end
        end
        objectif = p + 1

        # Si le probleme est solvable on met en place la méthode de résolution associée
        if isSolvable

            # On considère uniquement la relaxation continue
            if methode == "classique"

                isOptimal, x, timeSolve, objectif, bestBound = solveur(matriceDichotomie, b)
            
            # On considère la relaxation continue mais on affine celle-ci avec la méthode des plan coupants
            elseif methode == "planCoupantFini"

                isOptimal, xEntier, timeSolve, objectif, bestBound, x, A_inegalite, b_inegalite = coupeSuccessive(matriceDichotomie, b, epsilon, nb_coupe)

            elseif methode == "planCoupant"

                isOptimal, xEntier, timeSolve, objectif, bestBound, x, A_inegalite, b_inegalite = coupeSuccessive(matriceDichotomie, b)

            end
        end

        # Si le problème de set-cover ne peut pas être résolue, ou qu'il est résolue en plus de p centres, on passe à l'itération suivante
        if !isSolvable || (isSolvable && sum(x) > p)

            borneInf = dichotomie + 1
            dichotomie = div(borneSup + borneInf, 2)
            tailleDichotomie = borneSup - borneInf + 1
            distanceDichotomie = vecteurDistance[dichotomie]

        elseif isSolvable && sum(x) <= p

            borneSup = dichotomie
            dichotomie = div(borneSup + borneInf, 2)
            tailleDichotomie = borneSup - borneInf + 1
            distanceDichotomie = vecteurDistance[dichotomie]
            
        end
    end

    return distanceDichotomie, x, time() - start

end