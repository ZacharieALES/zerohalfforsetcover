# Ce fichier contient la methode de prétraitement des données 


"""
Procède à la simplification de la matrice A de taille n*m et b de taille m

Argument
- A: matrice de taille m*n d'entier relatif
- b: vecteur de taille m d'entier relatif
- x: vecteur de taille n de flottant
- eps: précision pour mesurer si x[i] est nul

Sortie
- A_barre: matrice traitée issu de A
- b_barre: vecteur traité issu de b
- x_barre: vecteur traité issu de x
- indice: vecteur indiquant l'inégalité correspondant à chaque ligne
- s: vecteur de flottant contenant la slack associée à chaque ligne
"""

function pretraitement(A::Array{Int, 2}, b::Array{Int, 1}, x::Array{Float64, 1}, eps::Float64)

    m = size(A)[1]
    n = size(A)[2]
    one = ones(Int64, n_barre)
 
    # On initialise indice, à chaque ligne correspond l'indice de l'inégalité correspondante
    indice = Array{Array{Int64}(1)}(undef, m)
    for i in 1:m
	indice[i][1] = i
    end

    # On initialise A_barre, b_barre et x_barre avec le reste de la division euclidienne de A et b par 2
    A_barre = Array{Int64}(undef, m, n)
    b_barre = Array{Int64}(undef, m)
    x_barre = Array{Float64}(undef, n)
    m_barre = m
    n_barre = n
    A_barre = -A
    b_barre = -b
    x_barre = x

    # On initialise et calcule la slack pour chacune des lignes de A et b
    s = Array{Float64}(undef, m)
    s = b - A * x

    # On parcourt A_barre, b_barre et x et on supprime les colonnes et lignes suivantes : 
    # - si x[j] = 0 on supprime la colonne
    # - si la s[i] >= 1 on supprime la ligne

    count_i = 1
    count_j = 1

   # On parcourt les colonne de A_barre
   while count_j != n_barre + 1

	# si x[j] < eps, on supprime la colonne correspondante
	if x_barre[count_j] < eps

	    A_barre = A_barre[:, setdiff(1:end, count_j)]
	    x_barre = x_barre[setdiff(1:end, count_j)]
	    n_barre = n_barre - 1

	# sinon on passe à la colonne suivante
	else

	    count_j = count_j + 1

	end
    end

    # On parcourt les lignes, et on supprime les lignes de slack superieur ou égale à 1

    # On parcours les lignes 
    while count_i != m_barre + 1

	if s[count_i] >= 1

	    A_barre = A_barre[setdiff(1:end, count_i), :]
	    b_barre = b_barre[setdiff(1:end, count_i)]
	    s = s[setdiff(1:end, count_i)]
	    indice = indice[setdiff(1:end, count_i)]
	    m_barre = m_barre - 1

	else

	    count_i = count_i + 1

	end
    end

    # On parcours les lignes et colonnes, si A_barre[i, k] = 1 et s[i] = 0 on supprime la colonne k et 
    # on ajoute la ligne i à toutes les autres lignes tel A_barre[j, k] = 1 et on pose s[i] = x_barre[k]
    count_i = 1
    count_j = 1
    count_k = 1
    modif = true

    # Tant que l'on a pas fait une itération sans apporter de modification
    while modif = true
    
	# On initialise modif à chaque début de tour de boucle
	modif = false

        # On parcours les lignes
        while count_i != 1 && modif == false

	    # On parcours les colonnes
	    while count_k != n_barre + 1 && modif == false

	        # Si A[i,k] == 1 et s[i] == 0 on supprime la colonne k, on pose s[i] = x[k] et on ajoute la ligne i de A au autre ligne telle que A[j,k] == 1
	        if A[i, count_k] == 1 && s[i] == 0
			

                    # On retient que l'on a apporté une modification
		    modif = true		    

		    # On parcours les ligne
		    for j in 1:m_barre

		        # Si une ligne (différente de la ligne i) vérifie A[j,k] == 1 on somme la ligne i à la ligne j
		        if A[j, count_k] == 1 && j != i
			
			    # A[j,:] prend la valeur de la somme des deux lignes modulo 2
			    A[j, :] = (A[j, :] + A[i, :]) % 2
		
			    # b[j] = (b[i] + b[j]) mod 2
			    b[j] = (b[i] + b[j]) % 2
			

			    # On met à jour Rj
			    n_i = length(indice[i])
			
			    # On parcours les éléments de Ri
			    for h in 1:n_i

			        n_j = length(indice[j])
			        count_j = 1

			        # On parcours les elements de Rj
			        while count_j != n_j +1

				    # Si un element de Ri est dans Rj, on le supprime de Rj
				    if indice[h][n_i] == indice[j][count_j]

		       	                indice[j][count_j] = indice[j][setdiff(1:end, count_j)]	
				        n_j = n_j - 1

				    # Sinon on ajoute l'element de Ri dans Rj en première position
				    else 

				        vcat([indice[h][n_i]], indice[j])
				        count_j = count_j + 2
				        n_j = n_j + 1
    
				    end			    
			        end

			    # On met à jour s[i] avec x[k]
			    s[i] = x_barre[k]

			    end
		        end	
		    end
		
		    # On supprime la colonne k de A
	            A_barre = A_barre[:, setdiff(1:end, count_k)]
		    x_barre = x_barre[setdiff(1:end, count_k)]
		    n_barre = n_barre - 1

	        else
		    count_k = count_k + 1
	        end
	    end
	
	    count_i = count_i + 1
	
        end

        # Pour chaque simplification liée à la proposition 5, on supprime les lignes et colonnes nulles, ainsi que les lignes de slack supérieure égale à 1

	count_i = 0

        # On supprime les lignes nulles ou de slack supérieure ou égale à 1
        while count_i != m_barre

            if (A[count_i,:] * one == 0 && b[count_i] == 0) || s[count_i] >= 1

	        A_barre = A_barre[setdiff(1:end, count_i), :]
	        b_barre = b_barre[setdiff(1:end, count_i)]
	        s = s[setdiff(1:end, count_i)]
	        indice = indice[setdiff(1:end, count_i)]
	        m_barre = m_barre - 1

	    else

		count_i = count_i + 1

	    end
	end	
	
	count_j = 0
	
	# On supprime les colonnes nulles
	while count_j != n_barre

	    if transpose(A[:, count_j]) * one == 0

	        A_barre = A_barre[:, setdiff(1:end, count_j)]
	        x_barre = x_barre[setdiff(1:end, count_j)]
	        n_barre = n_barre - 1

	    else

		count_j = count_j + 1

	    end
	end

    end


    # On cherche des vecteur unitaires

    count_j = 1

    # On parcourt les colonnes de A
    while count_j != n_barre + 1

	# On verifie si il s'agit d'un vecteur unitaire
	if transpose(A_barre[j,:]) * one == 1
	
	    # On met à jour la slack
	    for i in 1:m_barre
		if A_barre[i, j] == 1
		    s[i] = s[i] + x_barre[j]
		end
	    end

	    # On supprime la colonne correspondante
	    A_barre = A_barre[:, setdiff(1:end, j)]
	    x_barre = x_barre[:, setdiff(1:end, j)]
	    n_barre = n_barre - 1
	
	else
	    count_j = count_j + 1
 	end    
    end

    # On supprime les lignes et colonnes nulles, ainsi que les lignes de slacks supérieures ou égales à 1

    count_i = 0

    # On supprime les lignes nulles ou de slack supérieure ou égale à 1
    while count_i != m_barre

        if (A[count_i,:] * one == 0 && b[count_i] == 0) || s[count_i] >= 1

	    A_barre = A_barre[setdiff(1:end, count_i), :]
	    b_barre = b_barre[setdiff(1:end, count_i)]
	    s = s[setdiff(1:end, count_i)]
	    indice = indice[setdiff(1:end, count_i)]
	    m_barre = m_barre - 1

	else

	    count_i = count_i + 1

	end
    end	
	
    count_j = 0
	
    # On supprime les colonnes nulles
    while count_j != n_barre

	if transpose(A[:, count_j]) * one == 0
            
	    A_barre = A_barre[:, setdiff(1:end, count_j)]
	    x_barre = x_barre[setdiff(1:end, count_j)]
	    n_barre = n_barre - 1

	else

	    count_j = count_j + 1

	end
    end

    return(A_barre, b_barre, x_barre, indice, s)
end


    