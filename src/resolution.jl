using JuMP
using CPLEX
include("pretraitement.jl")
include("generation.jl")

"""
Definition du callback
cb_data : correspond à une solution fractionnaire trouvée par CPLEX
"""

function testCallback(cb_data)

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
    k = 2
    # On fait une recherche pour les coupes suivantes.
    # On ne considère pas le cas k=1, car on a déjà traité les partitions de tailles 1
    while size(coupe)[1] == 0 && k != m_barre 
            
        for count_k in 2:k

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

                # On propage l'incrementation
                for i in 0:count_k-2
                        
                    if count[count_k - i] == m_barre - i + 1

                        count[count_k - i] = decalage[count_k - i] + 1
                        count[count_k - i - 1] = count[count_k - i - 1] + 1
                        decalage[count_k - i] = decalage[count_k - i] + 1

                    end
                end
            end
        end

        k = k + 1

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
        global A
        global b
    
    end

end

"""
Résouds une instance en faisant appel aux coupes {0,1/2}

Arguments:
- A :  matrice de taille m*n, avec A[i, j] = -1 si le ieme elements est couvert par le jeme sous ensemble

Sortie:
- status : optimal si le probleme est résolu de façon optimale
- x : vecteur d'entier de taille n, avec x[i] = 1 si le ieme sous ensemble est actif dans la solution
- getsolvetime(m) : le temps de résolution en seconde
"""

# function cplexSolve(A::Array{Int,2}, b::Array{Int,1} = Array{Int64}(undef,0),  epsilon::Array{Float64,1} = [0.0001; 0])
    A = generateInstance(50,30,0.3) 
    global A
    m = size(A)[1]
    n = size(A)[2]
    b = -ones(Int64, m)
    global b
    epsilon = [0.0001; 0]
    global epsilon

    # # Si b n'est pas renseigné, on l'initialise
    # if size(b)[1] == 0

    #     b = -ones(Int64, m)
    
    # end

    # Définition du problème
    model = Model(CPLEX.Optimizer)
    @variable(model, x[i in 1:n], Bin) 
    @constraint(model, [i in 1:m], sum(-x[j] for j in 1:n if A[i, j] == -1) <= b[i]) 
    @objective(model, Min, sum(x[i] for i in 1:n))

    # Ajout du callback
    MOI.set(model, MOI.UserCutCallback(), testCallback)
    
    # Start a chronometer
    start = time()    

    optimize!(model)

    # Affichage de la solution
    print("\nSolution obtenue \n")
    for i in 1:n

        println("x[", i, "] = ", JuMP.value(x[i]))   

    end

    # Return:
    # 1 - true si un optimum est trouvé
    # 2 - la valeur associée à chaque sous-ensemble
    # 3 - le temps de resolution
    return JuMP.primal_status(model) == JuMP.MathOptInterface.FEASIBLE_POINT, x, time() - start
# end


