"""
Genere un grille de taille p*n à partir d'une densité donnée

Argument
- m: nombre de ligne sur la grille
- n: nombre de colonne
- density : pourcentage dans [0, 1] de un dans la grille
"""

function generateInstance(m::Int64, n::Int64, density::Float64)

    t = Array{Int64}(undef, m, n)
    t = zeros(Int64, m, n)
    count = 0

    # Tant que l'on a as remplis assez de case
    while count < m * n * density

        # On choisit aléatoirement une case
        i = ceil.(Int, m*rand())
        j = ceil.(Int, n*rand())

        if t[i, j] == 0

            t[i, j] = -1
            count = count + 1

        end    
    end

    # On complete t de manière aléatoire afin que l'instance puisse être résolue
    for i in 1:m

        if sum(t[i, :]) == 0

            j = ceil.(Int, n*rand())
            t[i, j] = -1

        end
    end

    return(t)
end