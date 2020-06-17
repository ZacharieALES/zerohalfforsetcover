include("instance.jl")


"""
Genere un grille de taille p*n à partir d'une densité donnée

Argument
- m: nombre de ligne sur la grille
- n: nombre de colonne
- density : pourcentage dans [0, 1] de un dans la grille
"""

function generateInstance(m::Int64, n::Int64, density::Float64)

    t = Array{Float64}(undef, m, n)
    t = zeros(Float64, m, n)
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

    instance = Instance(t)
    return(instance)
end

"""
Generation de toutes les instances

"""

function generateDataSet()

    # Pour chaque nombre de ligne
    for i in [ 10, 20, 30, 50, 80, 100]

        # Pour chaque nombre de colonne
        for j in [ 10, 20, 30, 50, 80, 100]

            # Pour chaque densité considérée
            for density in [0.1, 0.25, 0.5, 0.75, 0.9]

                # Genere 5 instances
                for instance in 1:10

                    fileName = "../data/instance_t" * "_i" * string(i) * "_j" * string(j) * "_" * string(density) * "_" * string(instance) * ".txt"
                    println("--Generating file" * fileName)
                    saveInstance(generateInstance(i, j, density).A, fileName) 

                end
            end
        end
    end
end