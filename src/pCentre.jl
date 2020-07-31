include("resolutionInstance.jl")

"""
On met en place une résolution dichotomique du problème des p-centres
Arguments:
- A: matrice de flottant de taille m*n representant la distance des clients aux entrepots
- p: la valeur du problème des p-centres
- method: chaine de caractère reresentant la méthode de résolution
"""

function pCentreEntier(matriceDistanceInitiale::Array{Float64, 2}, p::Int64, methode::String = "PC", borne::String = "Ub1EtLb1")
 
    start = time()
    m = size(matriceDistanceInitiale)[1]
    n = size(matriceDistanceInitiale)[2]
    simplification = 0

    matriceDistance = Array{Float64}(undef, m, n)

    for i in 1:m

        for j in 1:n

            matriceDistance[i, j] = matriceDistanceInitiale[i, j]

        end
    end

    # Simplification du probleme en mettant en place la borne inferieure Ub0 
    if borne == "Lb0" || borne == "Ub0EtLb0"

        # On assigne chaque client à l'entrepot le plus proche
        assignation = Array{Float64}(undef, m)
        
        for i in 1:m

            assignation[i] = minimum(matriceDistance[i, :])
        
        end

        borneMin = maximum(assignation)

        # On met à jour les distance plus petites que borne min
        for i in 1:m

            for j in 1:n

                if matriceDistance[i, j] < borneMin

                    matriceDistance[i, j] = borneMin
                    
                end
            end
        end
    end

    # Simplification du probleme en mettant en place la borne superieure Ub0
    if borne == "Ub0" || borne == "Ub0EtLb0"
        
        # On cherche l'entreprise la moins eloignée de son client le plus eloigné
        assignation = Array{Float64}(undef, n)

        for j in 1:n
            
            assignation[j] = maximum(matriceDistance[:, j])

        end

        upperBound = minimum(assignation)

        # On supprime toutes les distances supérieures à la borne superieure
        for i in 1:m

            for j in 1:n

                if matriceDistance[i, j] > upperBound

                    matriceDistance[i, j] = upperBound
                
                end
            end
        end
    end

    # Simplification du probleme en mettant en place la borne inferieure Ub1  
    if borne == "Ub1" || borne == "Ub1EtLb1" || borne == "Relaxation"

        upperBound = maximum(matriceDistance)
        matriceDistanceBis = matriceDistance

        # On repete la procedure jusqu'à avoir p entrepot
        for compteur in 1:p

            mBis = size(matriceDistanceBis)[1]
            nBis = size(matriceDistanceBis)[2]

            for i in 1:mBis
                
                for j in 1:nBis

                    if matriceDistanceBis[i, j] > upperBound

                        matriceDistanceBis[i, j] = 0
                    
                    end
                end
            end
            
            assignation = Array{Float64}(undef, nBis)

            for j in 1:nBis

                assignation[j] = maximum(matriceDistanceBis[:, j])
            
            end

            upperBound = minimum(assignation)
            
            # On cherche l'indice de cette colonne pour pouvoir la supprimer
            indice = 0

            for j in 1:nBis

                if upperBound == assignation[j]

                    indice = j
                
                end
            end

            # On supprime la colonne 
            if indice == 1

                matriceDistanceBis = matriceDistanceBis[:, 2:nBis]

            elseif indice == nBis

                matriceDistanceBis = matriceDistanceBis[:, 1:nBis-1]

            else

                matriceDistanceBis = hcat(matriceDistanceBis[:, 1:indice-1], matriceDistanceBis[:, indice+1:nBis])

            end
        end

        # On met à jour matriceDistance grâce à l'upperBound
        for i in 1:m

            for j in 1:n

                if matriceDistance[i, j] > upperBound

                    matriceDistance[i, j] = upperBound

                end
            end
        end         
    end

    # Simplification du probleme en mettant en place la borne superieure Lb1
    if borne == "Lb1" || borne == "Ub1EtLb1"

        # On assigne chaque client à un  entrepot en supposant qu'un entrepot est fermé à chaque fois
        assignation = Array{Float64}(undef, n, m)

        # Pour chaque entrepot fermé
        for entrepot in 1:n

            ferme = Array{Float64}(undef, n - 1)

            # On parcourt chaque client
            for i in 1:m

                for j in 1:n

                    if j < entrepot

                        ferme[j] = matriceDistance[i, j]

                    elseif j > entrepot

                        ferme[j-1] = matriceDistance[i, j]

                    end
                end
                
                assignation[entrepot, i] = minimum(ferme)
            end
        end

        Lb = Array{Float64}(undef, n)
            
        for i in 1:n

            Lb[i] = maximum(assignation[i, :])
            
        end
        
        # On trie Lb[i] et on recupere la n-p eme valeur 
        Lb = sort(Lb)
        borneMin = Lb[n-p]

        # On supprime les distances plus grande que borneMin
        for i in 1:m
            
            for j in 1:n

                if matriceDistance[i, j] < borneMin 

                    matriceDistance[i, j] = borneMin

                end
            end
        end
    end



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
    if borne == "Relaxation"

        distanceMin, x = pCentreRelaxation(matriceDistance, p, "classique")

        for i in 1:m

            for j in 1:n

                if matriceDistance[i, j] < distanceMin

                    matriceDistance[i, j] = distanceMin

                end
            end
        end

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

    # On recupere le temps de mise en place des bornes 
    timeBorne = time() - start

    # On récupère le nombre de valeur de distance modifiée
    for i in 1:m

        for j in 1:n

            if matriceDistanceInitiale[i, j] != matriceDistance[i, j]

                simplification = simplification + 1

            end
        end
    end

    nbDistance = size(vecteurDistance)[1]

    # Si on resoud en appliquant PC
    if methode == "PC"

        # On definit le probleme à résoudre
        model = Model(CPLEX.Optimizer)
        @variable(model, z, Int)
        @variable(model, w[i in 1:n], Bin)
        @variable(model, y[i in 1:m, j in 1:n], Bin)
        @constraint(model, sum(w[i] for i in 1:n) <= p)
        @constraint(model, [i in 1:m], sum(y[i, j] for j in 1:n) == 1)
        @constraint(model, [i in 1:m, j in 1:n], y[i, j] <= w[j])
        @constraint(model, [i in 1:m], sum(matriceDistance[i, j] * y[i, j] for j in 1:n) <= z)
        @objective(model, Min, z)
        optimize!(model)
        distanceDichotomie =  JuMP.objective_value(model)
        x = Array{Int64}(undef, n)

        for j in 1:n

            if abs(JuMP.value(w[j])) <= 0.001

                x[j] = 0

            else

                x[j] = 1

            end
        end

    # Si on resoud en appliquant PC-SC
    elseif methode == "PC-SC"

        K = size(vecteurDistance)[1] - 1
        model = Model(CPLEX.Optimizer)
        @variable(model, z[k in 1:K], Bin)
        @variable(model, y[j in 1:n], Bin)
        @constraint(model, sum(y[j] for j in 1:n) >= 1)
        @constraint(model, sum(y[j] for j in 1:n) <= p)
        @constraint(model, [i in 1:m, k in 1:K], z[k] + sum(y[j] for j in 1:n if matriceDistance[i, j] < vecteurDistance[k + 1]) >= 1)
        @objective(model, Min, vecteurDistance[1] + sum((vecteurDistance[k + 1] - vecteurDistance[k]) * z[k] for k in 1:K))
        optimize!(model)
        distanceDichotomie = JuMP.objective_value(model)
        x = Array{Int64}(undef, n)

        for j in 1:n

            if abs(JuMP.value(y[j])) <= 0.001 

                x[j] = 0

            else

                x[j] = 1
            
            end
        end

    # Si on resouds par dichotomie
    elseif methode == "branchAndBoundCoupe" || methode == "branchAndBound" || methode == "coupeSuccessive" || methode == "branchAndBoundRien" || methode == "branchAndBoundPNLE" || methode == "branchAndBoundPNLEHighlyViolated" || methode == "branchAndBoundCoupeReduit"

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

                elseif methode == "branchAndBoundRien"

                    isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie, Array{Float64}(undef, 0), [0.0001; 0.0001], "rien")

                elseif methode == "branchAndBoundCoupe"

                    isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie, Array{Float64}(undef, 0), [0.0001; 0.0001], "zerohalfcut")

                elseif methode == "branchAndBoundCoupeReduit"

                    isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie, Array{Float64}(undef, 0), [0.0001; 0.0001], "zerohalfcutreduit")

                elseif methode == "branchAndBoundPNLE"

                    isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie, Array{Float64}(undef, 0), [0.0001; 0.0001], "PNLE")
                
                elseif methode == "branchAndBoundPNLEHighlyViolated"

                    isOptimal, x, timeSolve, objectif, bestBound, A_inegalite, b_barre = branchAndBoundCoupe(matriceDichotomie, Array{Float64}(undef, 0), [0.0001; 0.0001], "PNLEHighlyViolated")

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
    end

    return distanceDichotomie, x, time() - start, simplification, timeBorne
    
end

function pCentreRelaxation(matriceDistance::Array{Float64, 2}, p::Int64, methode::String = "classique", nb_coupe::Int64 = 20, epsilon::Array{Float64, 1} = [0.0001; 0.001])

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