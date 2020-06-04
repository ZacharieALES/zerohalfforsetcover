using JuMP
using CPLEX
include("pretraitement.jl")
include("generation.jl")

"""
Fonction qui resoud le problème linaire ou sa relaxation continue
Arguments
- A: matrice de flottant de taille m*n
- b: vecteur de taille n de taille m
- isRelaxation: booleen valant true si on souhaite resoudre la relaxation, false sinon 

Sortie
- x: vecteur de taille n solution du problème linéaire
"""

function solveur(A::Array{Float64, 2}, b::Array{Float64, 1}, isRelaxation::Bool = true)

    m = size(A)[1]
    n = size(A)[2]
    x_sol = Array{Float64}(undef, n)

    model = Model(CPLEX.Optimizer)

    # Si on cherche la solution entière du problème
    if !isRelaxation

        @variable(model, x[i in 1:n], Bin) 
        
    # Si on cherche la solution de la relaxation continue
    else
        @variable(model, x[i in 1:n])
        @constraint(model,[i in 1:n], x[i] >= 0)
        @constraint(model,[i in 1:n], x[i] <= 1)

    end

    @constraint(model, [i in 1:m], sum(A[i, j] * x[j] for j in 1:n) <= b[i]) 
    @objective(model, Min, sum(x[i] for i in 1:n))

    optimize!(model)

    for i in 1:n 

        x_sol[i] = JuMP.value(x[i])

    end

    return x_sol
end    

# Definition des données du problème
A = generateInstance(50,30,0.3) 
global A
m = size(A)[1]
global m
n = size(A)[2]
b = -ones(Float64, m)
global b
coupe = Array{Float64}(undef, 1, m)
epsilon = [0.0001; 0.001]
global epsilon
x = Array{Float64}(undef, n)
A_barre = Array{Int64}
b_barre = Array{Int64}
x_barre = Array{Float64}
coupe = Array{Float64}(undef, 0, m)
indice = Array{Array{Int64}}
s = Array{Float64}
uA = Array{Float64}(undef, 1, n)
uA_abs = Array{Int64}(undef, 1, n)
u = zeros(Float64, m)

# On applique le solveur
x = solveur(A, b)
global x

# On verifie si la solution est entière
entier = true
global entier
for i in 1:n

    if abs(x[i] - floor(x[i])) >= epsilon[1]

        entier = false
        global entier

    end

end

Excoupe = true
global Excoupe
# Tant que la solution n'est pas entière et que l'on trouve des coupes
while !entier && Excoupe

    # On met à jour la taille de A
    m = size(A)[1]
    global m

    Excoupe = false
    global Excoupe
    println("hi")
    # On calcule de nouvelle coupe
    # On effectue le pretraitement des matrices A, b à partir de la solution continue x_sol
    A_barre, b_barre, x_barre, coupe, indice, s = pretraitement(A, b, x, epsilon)
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
                if (uA_abs * x)[1] - ub_abs > epsilon[2]
    
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

        # Pour chaque coupe, on ajoute l'inégalité correspondante. On les ajoute également à A et b
        nb_coupe = size(coupe)[1]
    
        if nb_coupe != 0

            Excoupe = true
            global Excoupe

        end    

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
    
            # On met à jour A et b 
            A = vcat(A, uA_abs)
            global A
            b = vcat(b, ub_abs)
            global b
        
        end
    end

    # On calcule la nouvelle solution de la relaxation avec les coupes
    x = solveur(A, b)
    global x
    entier = true
    global entier


    # On verifie si la solution est entière
    for i in 1:n

        if abs(x[i] - floor(x[i])) >= epsilon[1]

            entier = false
            global entier

        end
    end
end

# Affichage de la solution
print("\nSolution obtenue \n")
for i in 1:n

    println("x[", i, "] = ", x[i])   

end

if entier

    println("L'algorithme s'est arreté car la solution est entière")

elseif !Excoupe 

    println("L'algorithme s'est arreté car il n'a pas trouvé de coupe")

end