using JuMP
using CPLEX
include("pretraitement.jl")
include("generation.jl")
include("instance.jl")

"""
Definition du callback
cb_data : correspond à une solution fractionnaire trouvée par CPLEX
"""

function branchAndBoundCoupe(A_entree::Array{Float64, 2}, b_entree::Array{Float64, 1} = Array{Float64}(undef, 0), epsilon_entree::Array{Float64, 1} = [0.0001; 0.0001], methode::String = "PNLE")

    A = A_entree
    # global A
    m = size(A)[1]
    n = size(A)[2]
    allCoupe = Array{Float64}(undef, 0, n+1)
    if size(b_entree)[1] == 0
        b = -ones(Float64, m)
    else
        b = b_entree
    end
    # global b
    x_sol = Array{Float64}(undef, n)
    epsilon = epsilon_entree
    # global epsilon
    function testCallback(cb_data)

        println("callback")
        if methode == "zerohalfcut" || methode == "zerohalfcutreduit"

            m = size(A)[1]
            n = size(A)[2]
            x_sol = Array{Float64}(undef, n)
            A_barre = Array{Int64}
            b_barre = Array{Int64}
            x_barre = Array{Float64}
            coupe = Array{Float64}(undef, 0, m)
            indice = Array{Array{Int64}}
            s = Array{Float64}
            uA = Array{Float64}(undef, 1, n)
            uA_abs = Array{Int64}(undef, 1, n)
            u = zeros(Float64, m)
        
            # On initialise la valeur de x_sol
            for i in 1:n
        
                x_sol[i] = callback_value(cb_data, x[i])
        
            end
        
            # On effectue le pretraitement des matrices A, b à partir de la solution continue x_sol
            A_barre, b_barre, x_barre, coupe, indice, s = pretraitement(A, b, x_sol, epsilon)
            m_barre = size(A_barre)[1]
            n_barre = size(b_barre)[1]
            k = 1
            # On fait une recherche pour les coupes suivantes.
            # On ne considère pas le cas k=1, car on a déjà traité les partitions de tailles 1
            while size(coupe)[1] == 0 && k != m_barre && methode == "zerohalfcut"
                    
                for count_k in 1:k
        
                    # On initialise un vecteur qui va nous permettre de compter les itérations, ainsi que le décalage sur chaque itération
                    count = Array{Int64}(undef, count_k)
                    decalage = Array{Int64}(undef, count_k)
        
                    for i in 1:count_k
        
                        count[i] = i
                        decalage[i] = i
        
                    end
                        
                    # Tant que l'on a pas étudier toutes les partitions de taille count_k
                    while decalage[count_k ] != m_barre + 1
        
                        # On calcule u à partir des éléments de la partitions
        
                        # On initialise u
                        u = zeros(Float64, m)
        
                        # On récupère les indices des inégalités concernées
                        indice_ine = indice[count[1]]
                        for i in 2:count_k
        
                            indice_ine = vcat(indice_ine, indice[count[i]])
        
                        end
                            
                        # On calcule u avec les inégalitées correspondante
                        for i in 1:size(indice_ine)[1]
        
                            if u[indice_ine[i]] == 1/2
        
                                u[indice_ine[i]] = 0
                                
                            elseif u[indice_ine[i]] == 0
        
                                u[indice_ine[i]] = 1/2
                                
                            end
                        end
        
                        # On calcule la fonction de la coupe associée
        
                        # On calcule uA et ub
                        uA = transpose(u) * A
                        ub = transpose(u) * b
        
                        # On calcule les valeurs absolues
                        ub_abs = floor(ub)
                        for i in 1:n
        
                            uA_abs[i] = floor(uA[i])
        
                        end
                            
                        # Si la fonction de violation est supérieure à epsilon[2], on ajoute la coupe
                        if (uA_abs * x_sol)[1] - ub_abs > epsilon[2]
        
                            coupe = vcat(coupe, transpose(u))
                            
                        end    
        
                        # On passe à la partition suivantes
                        # On incremente de 1 le dernier compteur
                        count[count_k] = count[count_k] + 1
        
                        # On gère le cas ou count_k = 1 e tque l'on a parcouru toute la matrice
                        if count_k == 1 &&  count[1] == m_barre + 1
        
                            decalage = m_barre + 1
        
                        end    
        
                        # On propage l'incrementation
                        for i in 0:count_k-2
                                
                            if count[count_k - i] == m_barre - i + 1 && count_k != 1
        
                                count[count_k - i] = decalage[count_k - i] + 1
                                count[count_k - i - 1] = count[count_k - i - 1] + 1
                                decalage[count_k - i] = decalage[count_k - i] + 1
        
                            end
                        end
                    end
                end

                k = k + 1

            end

            if methode == "zerohalfcutreduit" && size(coupe)[1] == 0

                m = size(A)[1]
                n = size(A)[2]

                # Mise en place du modele pour trouver la coupe la plus violée
                modele = Model(CPLEX.Optimizer)
                @variable(modele, q, Int)
                @constraint(modele, q >= 0)
                @variable(modele, r[i in 1:n], Int)
                @constraint(modele, [i in 1:n], r[i] >= 0)
                @variable(modele, y[i in 1:n], Bin)
                @variable(modele, v[i in 1:m], Bin)
                @constraint(modele, sum(b_barre[i] * v[i] for i in 1:n) - 2 * q == 1)
                @constraint(modele, [j in 1:n], sum(A_barre[i, j] * v[i] for i in 1:m) - 2 * r[j] - y[j] == 0)
                @objective(modele, Min, sum(s[i] * v[i] for i in 1:m) + sum(x_sol[j] * y[j] for j in 1:n))
                optimize!(modele)

                # Si une coupe violée existe
                if JuMP.objective_value(modele) <= 1 && JuMP.objective_value(modele) >= 0

                    v_sol = zeros(m)
                    u_sol = zeros(m)
                    for i in 1:m

                        v_sol[i] = JuMP.value(v[i])
                        
                        if abs(v_sol[i] - 1) <= epsilon_entree[1]

                            u_sol[i] = 1/2

                        end
                    end

                    # On ajoute à coupe u_sol
                    coupe = vcat(coupe, transpose(u_sol))
                end

            end
                
            # Pour chaque coupe, on ajoute l'inégalité correspondante. On les ajoute également à A et b
            nb_coupe = size(coupe)[1]
            
            for j in 1:nb_coupe
            
                # On calcule uA et ub correspondant
                for i in 1:n
                    uA[i] = sum(coupe[j, k] * A[k, i] for k in 1:m)
                end
                ub = sum(coupe[j, k] * b[k] for k in 1:m)
            
                # On calcule abs(uA) et abs(ub)
                ub_abs = floor(ub)
            
                for i in 1:n
            
                    uA_abs[i] = floor(uA[i])
            
                end
            
                # Definition de la nouvelle contrainte
                con = @build_constraint(sum(uA_abs[i] * x[i] for i in 1:n) <= ub_abs)
            
                # On l'ajoute au problème
                MOI.submit(model, MOI.UserCut(cb_data), con)
            
                # On met à jour A et b 
                A = vcat(A, uA_abs)
                b = vcat(b, ub_abs)
                # global A
                # global b
                
            end

        
        elseif methode == "PNLE"

            m = size(A)[1]
            n = size(A)[2]
            A_barre = zeros(Float64, m, n)
            b_barre = zeros(Float64, m)
            x_sol = zeros(n)
            for i in 1:n

                x_sol[i] = callback_value(cb_data, x[i])

            end
            s = zeros(m)

            for i in 1:m

                s[i] = b[i] - sum(A[i, j] * x_sol[j] for j in 1:n)

            end

            for i in 1:m
                
                for j in 1:n

                    A_barre[i, j] = mod(A[i, j], 2)

                end

                b_barre[i] = mod(b[i], 2)
            end

            solvable = false

            for i in 1:m

                if b_barre[i] == 1

                    solvable = true

                end
            end

            if solvable
                # Mise en place du modele pour trouver la coupe la plus violée
                modele = Model(CPLEX.Optimizer)
                @variable(modele, q, Int)
                @variable(modele, r[i in 1:n], Int)
                @variable(modele, y[i in 1:n], Bin)
                @variable(modele, z[i in 1:m], Bin)
                @constraint(modele, [i in 1:n], r[i] >= 0)
                @constraint(modele, q >= 0)
                @constraint(modele, sum(b_barre[i] * z[i] for i in 1:n) - 2 * q == 1)
                @constraint(modele, [j in 1:n], sum(A_barre[i, j] * z[i] for i in 1:m) - 2 * r[j] - y[j] == 0)
                @objective(modele, Min, sum(s[i] * z[i] for i in 1:m) + sum(x_sol[j] * y[j] for j in 1:n))
                optimize!(modele)

                # Si une coupe violée existe
                if JuMP.objective_value(modele) <= 1 && JuMP.objective_value(modele) >= 0

                    v_sol = zeros(m)
                    u_sol = zeros(m)
                    for i in 1:m

                        v_sol[i] = JuMP.value(z[i])
                        
                        if abs(v_sol[i] - 1) <= epsilon_entree[1]

                            u_sol[i] = 1/2

                        end
                    end

                    # On calcule la nouvelle coupe
                    A_coupe = zeros(n)
                    for j in 1:n

                        A_coupe[j] = 0

                        for i in 1:m

                            A_coupe[j] = A_coupe[j] + u_sol[i] * A[i, j]
                        
                        end

                        A_coupe[j] = floor(A_coupe[j])

                    end

                    b_coupe = floor(sum(u_sol[i] * b[i] for i in 1:m))

                    # On ajoute A_coupe et b_coupe à A et b
                    A = vcat(A, transpose(A_coupe))
                    b = vcat(b, b_coupe)

                    # Definition de la nouvelle contrainte
                    con = @build_constraint(sum(A_coupe[i] * x[i] for i in 1:n) <= b_coupe)
                
                    # On l'ajoute au problème
                    MOI.submit(model, MOI.UserCut(cb_data), con)
                end
            end
        # Cas où l'on ne met pas en place de coupe              
        else
        
        end
    end
    
    # Définition du problème
    model = Model(CPLEX.Optimizer)
    @variable(model, x[i in 1:n], Bin) 
    @constraint(model, [i in 1:m], sum(A[i, j] * x[j] for j in 1:n) <= b[i]) 
    @objective(model, Min, sum(x[i] for i in 1:n))

    # Ajout du callback
    MOI.set(model, MOI.UserCutCallback(), testCallback)

    # On met en place une durée maximale
    set_parameter(model, "CPX_PARAM_TILIM", 3600)
    
    # Start a chronometer
    start = time()    

    optimize!(model)

    # Affichage de la solution
    print("\nSolution obtenue \n")
    for i in 1:n

        println("x[", i, "] = ", JuMP.value(x[i]))   
        x_sol[i] = JuMP.value(x[i])

    end

    # Return:
    # 1 - true si un optimum est trouvé
    # 2 - la valeur associée à chaque sous-ensemble
    # 3 - le temps de resolution
    return JuMP.primal_status(model) == JuMP.MathOptInterface.FEASIBLE_POINT, x_sol, time() - start,  JuMP.objective_value(model), JuMP.objective_bound(model), A, b
end

"""
Effectue la résolution d'une instance en faisant appel au solveur par défault de CPLEX

Arguments
- A: matrice de taille m*n de flottant
- b: vecteur de taille m de flottant
Sorties
-isOptimal: booléen retourne l'etat de la résolution (true si la résolution est optimale)
-x: vecteur binaire de taille n solution de l'instance
-time() - start: temps de la résolution
"""

function branchAndBound(A::Array{Float64, 2}, b_entree::Array{Float64, 1} = Array{Float64}(undef, 0))

    m = size(A)[1]
    n = size(A)[2]
    x_sol = Array{Float64}(undef, n)  

    if size(b_entree)[1] == 0
        b = -ones(Float64, m)
    else
        b = b_entree
    end


    # Définition du problème
    model = Model(CPLEX.Optimizer)
    @variable(model, x[i in 1:n], Bin) 
    @constraint(model, [i in 1:m], sum(A[i, j] * x[j] for j in 1:n) <= b[i]) 
    @objective(model, Min, sum(x[i] for i in 1:n))
    
    # On met en place une durée maximale 
    set_parameter(model, "CPX_PARAM_TILIM", 3600)

    # Start a chronometer
    start = time()    

    optimize!(model)

    # Affichage de la solution
    print("\nSolution obtenue \n")
    for i in 1:n

        println("x[", i, "] = ", JuMP.value(x[i]))   
        x_sol[i] = JuMP.value(x[i])

    end

    # Return:
    # 1 - true si un optimum est trouvé
    # 2 - la valeur associée à chaque sous-ensemble
    # 3 - le temps de resolution
    return JuMP.primal_status(model) == JuMP.MathOptInterface.FEASIBLE_POINT, x_sol, time() - start, JuMP.objective_value(model), JuMP.objective_bound(model)

end

