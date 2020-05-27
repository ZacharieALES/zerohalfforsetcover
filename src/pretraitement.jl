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

    # On initialise A_barre et b_barre avec le reste de la division euclidienne de A et b par 2
    A_barre = Array{Int64}(undef, m, n)
    b_barre = Array{Int64}(undef, m)
    for i in 1:m
	for j in 1:n
	    A_barre[i, j] = A[i, j] % 2
	end
	b_barre[i] = b[i] % 2
    end

    # On initialise et calcule la slack pour chacune des lignes de A et b
    s = Array{Float64}(undef, m)
    s = b - A * x