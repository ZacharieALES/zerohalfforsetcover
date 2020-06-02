using JuMP 
using CPLEX

"""
Définition du callback
cb_data : correspond à une solution fractionnaire trouvée par cplex
"""
function testCallback(cb_data)

    # Pour tout couple de sommets i et j
    for i in 1:n
        for j in i+1:n

            # Récupération de la valeur de x[i] et x[j] dans la solution cb_data
            valueXi = callback_value(cb_data, x[i])
            valueXj = callback_value(cb_data, x[j])

            # Si x[i] > 0, x[j] > 0 et p[i] + p[j] > B
            if valueXi > 0.001 && valueXj > 0.001 && p[i] + p[j] > B - 0.001

                # Alors je définis une nouvelle contrainte...
                con = @build_constraint(x[i] + x[j] <= 1)

                # ... et je l'ajoute au problème
                MOI.submit(m, MOI.UserCut(cb_data), con)
                println("Add constraint x[", i, "] + x[", j, "] <= 1")
            end
        end
    end
end 

# Définition des données du problème
n = 11
B = 20
p = [12, 15, 5, 16, 17, 10, 5, 2, 6, 19, 15]
w = [2, 6, 1, 7, 8, 5, 23, 6, 1, 3, 3]

# Définition du modèle
m = Model(CPLEX.Optimizer)
@variable(m, x[i in 1:n], Bin) 
@constraint(m, sum(x[i] * w[i] for i in 1:n) <= B) 
@objective(m, Max, sum(x[i] * p[i] for i in 1:n))

# Ajout du callback
MOI.set(m, MOI.UserCutCallback(), testCallback)
            
optimize!(m)

println("Solution obtenue")
for i in 1:n
    println("x[", i, "] = ", JuMP.value(x[i]))
end 
