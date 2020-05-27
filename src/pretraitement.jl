# Ce fichier contient la methode de prétraitement des données 


"""
Procède à la simplification de la matrice A de taille n*m et b de taille m

Argument
- A: matrice de taille m*n d'entier relatif
- b: vecteur de taille m d'entier relatif
- x: vecteur de taille n de flottant

Sortie
- A_barre: matrice traitée issu de A
- b_barre: vecteur traité issu de b
- x_barre: vecteur traité issu de x
- indice: vecteur indiquant l'inégalité correspondant à chaque ligne
- s: vecteur de flottant contenant la slack associée à chaque ligne
"""

function retraitement(A::Array{Int, 2}, b::Array{Int, 1}, x::Array{Float, 1})

    m = size(A)[1]
    n = size(A)[2]
 
    # On initialise indice, à chaque ligne correspond l'indice de l'inégalité correspondante
    indice = Array{Int64}(undef, m)
    for i in 1:m
	indice[i] = i
    end

    # On initialise A_barre, b_barre et x_barre avec le reste de la division euclidienne de A et b par 2
    A_barre = Array{Int64}(undef, m, n)
    b_barre = Array{Int64}(undef, m)
    x_barre = Array{Int64}(undef, n)
    m_barre = m
    n_barre = n
    for i in 1:m
	for j in 1:n
	    A_barre[i, j] = A[i, j] % 2
	end
	b_barre[i] = b[i] % 2
    end
    for j in 1:n
	x_barre[j] = x[j]
    end

    # On initialise et calcule la slack pour chacune des lignes de A et b
    s = Array{Float64}(undef, m)
    s = b - A * x

    # On parcourt A_barre, b_barre et x et on supprime les colonnes suivantes : 
    # - si A[,j] = 0 on supprime la colonne
    # - si x[j] = 0 on supprime la colonne
    # - si la s[i] >= 1 on supprime la ligne

    count_i = 1
    count_j = 1
    somme = 0

   # On parcourt les colonne de A_barre
   while count_j != n_barre
	for i in 1:m_barre
	    somme = somme + A_barre[i, count_j]
	end
	# si la somme vaut zero ou que x[j] vaut zero, tout les elements sont nuls et on supprime la colonne correspondante
	if somme == 0 || x_barre[count_j] == 0
	    A_barre = A_barre[:, setdiff(1:end, count_j)]
	    x_barre = x_barre[setdiff(1:end, count_j)]
	    n_barre = n_barre - 1
	# sinon on passe à la colonne suivante
	elseif
	    count_j = count_j + 1
	end
    end

    # On parcourt les lignes, et on supprime les lignes de slack superieur ou égale à 1

    # On parcours les lignes 
    while count_i != m_barre
	if s[count_i] >= 1
	    A_barre = A_barre[setdiff(1:end, count_i), :]
	    b_barre = b_barre[setdiff(1:end, count_i)]
	    s_barre = s_barre[setdiff(1:end, count_i)]
	    indice = indice[setdiff(1:end, count_i)]
	    m_barre = m_barre - 1
	elseif
	    count_i = count_i + 1
	end
    end

    # On parcours les lignes et colonnes, si A_barre[i, k] = 1 et s[i] = 0 on supprime la colonne k et 
    # on ajoute la ligne i à toutes les autres lignes tel A_barre[i, j] = 1 et on pose s[i] = x_barre[k]
	  

    