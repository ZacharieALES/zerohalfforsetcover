# Ce fichier contient la methode de prétraitement des données 


"""
Procède à la simplification de la matrice A de taille n*m et b de taille m

Argument
- A: matrice de taille m*n d'entier relatif
- b: vecteur de taille m d'entier relatif
- x: vecteur de taille n de flottant
- eps: tableau contenant les differentes précisions

Sortie
- A_barre: matrice traitée issu de A
- b_barre: vecteur traité issu de b
- x_barre: vecteur traité issu de x
- indice: tableau de tableau indiquant les inégalités qui correspondent à chaque ligne
- s: vecteur de flottant contenant la slack associée à chaque ligne
- coupe: matrice à n colonnes contenant aux premières coupes  
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

    # On initialise le vecteur u
    u =  Array{Float64}(undef, m)

    # On initialise coupe
    coupe = Array{Int64}(undef, 0, n)

    # On initialise u'*A et abs(u'A)
    uA = Array{Int64}(undef, 1, n)
    uA_abs = Array{Int64}(undef, 1, n)

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

	# si x[j] < eps[1], on supprime la colonne correspondante
	if x_barre[count_j] < eps[1]

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
			    n_i = size(indice[i])
			
			    # On parcours les éléments de Ri
			    for h in 1:n_i

			        n_j = size(indice[j])
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

	    one = ones(Int64, m_barre)	    

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

	    one = ones(Int64, n_barre)	    

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

	one = ones(Int64, m_barre)

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

	one = ones(Int64, m_barre)
	
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

	one = ones(Int64, n_barre)

	if transpose(A[:, count_j]) * one == 0
            
	    A_barre = A_barre[:, setdiff(1:end, count_j)]
	    x_barre = x_barre[setdiff(1:end, count_j)]
	    n_barre = n_barre - 1

	else

	    count_j = count_j + 1

	end
    end

    # On cherche les coupes associées aux lignes telles que b_barre = 1, et la fonction de violation est supérieure à eps[2]

    count_i = 1
    n_i = 1	

    # On parcourt les lignes de A_barre
    while count_i != m_barre + 1

	#On regarde si b[i] == 1
        if b_barre[count_i] == 1

	    # On regarde la valeur de la fonction de violation pour la coupe associée
	    # On cree le vecteur u de la coupe associée
	    n_i = size(indice[count_i])

	    for j in 1:n_i
		
		# u[i] vaut 1/2 si i appartient à indice[i], 0 sinon
		u[indice[count_i][j]] = 1/2

	    end
	    
	    # On calcule uA et ub
	    uA = transpose(u) * A
	    ub = transpose(u) * b

	    # On calcule les valeurs absolues
	    ub_abs = floor(ub)
	    for i in 1:n

		uA_abs[1, i] = floor(uA[1, i])

	    end
	
	    # Si la fonction de violation est supérieure à eps, on ajoute la coupe et on supprime la ligne
	    if uA_abs * x - ub_abs > eps[2]
	
	        hcat(coupe, u)
	        A_barre = A_barre[setdiff(1:end, count_i), :]
	        b_barre = b_barre[setdiff(1:end, count_i)]
	        s = s[setdiff(1:end, count_i)]
	        indice = indice[setdiff(1:end, count_i)]
	        m_barre = m_barre - 1
		
	    else
		
		count_i = count_i + 1

	    end

	else
	
	    count_i = count_i + 1

	end
	
    end

    # On supprime les lignes et colonnes nulles, ainsi que les lignes de slacks supérieures ou égales à 1

    count_i = 0

    # On supprime les lignes nulles ou de slack supérieure ou égale à 1
    while count_i != m_barre

	one = ones(Int64, m_barre)

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

	one = ones(Int64, n_barre)
	
	if transpose(A[:, count_j]) * one == 0
            
	    A_barre = A_barre[:, setdiff(1:end, count_j)]
	    x_barre = x_barre[setdiff(1:end, count_j)]
	    n_barre = n_barre - 1

	else

	    count_j = count_j + 1

	end
    end

    # Suppression des colonnes identiques, on ne conserve que la colonne de slack la plus petite

    count_i = 0
    count_j = 0
    slack = 0
    reference = 0

    # On initialise done un vecteur d'entier de taille m_barre : done[i] = 1 si la ligne a déjà été traitée, 0 sinon
    done = zeros(Int64, m_barre)

    # On parcours les lignes
    while count_i != m_barre + 1

	# On vérifie que la ligne n'a pas été traitée
	if done[i] == 0

	    # On initialise slack et reference à chaque itération
	    slack = slack[i]
	    reference = i
	    count_j = count_i + 1

	    # On parcours les j lignes après la ieme ligne
	    while count_j != m_barre + 1
		
		# On vérifie que cette ligne n'a pas été traitée
		if done[count_j] != 1	

		    one = ones(Int64, m_barre)		 

		    # On verifie si les deux lignes sont identiques
		    if (A[i, :] - A[j, :]) * one == 0

			# On compare les valeurs de la slacks
			# Cas ou la valeur de réference est la plus petite, on supprime alors la ligne j
			if slack < s[j]


	  		    A_barre = A_barre[setdiff(1:end, count_j), :]
			    b_barre = b_barre[setdiff(1:end, count_j)]
	   		    s = s[setdiff(1:end, count_j)]
	 		    indice = indice[setdiff(1:end, count_j)]
	   		    m_barre = m_barre - 1			    

			# Cas ou la valeur de réference est la plus grande, on met alors à jour la ligne de reference et on supprime l'ancienne ligne
			else
			    slack = s[j]
	  		    A_barre = A_barre[setdiff(1:end, reference), :]
			    b_barre = b_barre[setdiff(1:end, reference)]
	   		    s = s[setdiff(1:end, reference)]
	 		    indice = indice[setdiff(1:end, reference)]
	   		    m_barre = m_barre - 1
			    reference = count_j - 1

			end
		        done[j] = 1
			done[i] = 1

		    else
			
			count_j = count_j + 1
			
		    end	    
		end
	    end
	else 
	
	    count_i = count_i + 1

	end
    end     

    # On supprime les lignes nulles ou de slack supérieure ou égale à 1
    while count_i != m_barre

	one = ones(Int64, m_barre)

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

	one = ones(Int64, n_barre)
	
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


    