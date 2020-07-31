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
    for i in [5, 10, 20, 30, 40]

        # # Pour chaque nombre de colonne
        # for j in [ 10, 20, 30, 50, 80]

            # Pour chaque densité considérée
            for density in [0.1, 0.25, 0.5, 0.75, 0.9]

                # Genere 5 instances
                for instance in 1:10

                    fileName = "../data/instance_t" * "_i" * string(i) * "_j" * string(i) * "_" * string(density) * "_" * string(instance) * ".txt"
                    println("--Generating file" * fileName)
                    saveInstance(generateInstance(i, i, density).A, fileName) 

                end
            end
        # end
    end
end

"""
Generation d'une instance de P-centre

Argument : 
- m : le nombre de maison
- n : le nombre d'entrepot
- p : entier correspondant au p-centre (si mis à -1 choisi aléatoirement)
- Max : la coordonnée ou distance max
- methode : la methode de génération

Sortie :
- A : matrice des distances
- p 
"""

function generationPCentre(m::Int64, n::Int64, p::Int64 = -1, Max::Int64 = 20, methode::String = "carthesien")

    distance = Array{Float64}(undef, m, n)
    

    # Si p est négatif, on le choisit aléatoirement
    if p < 0

        p = ceil(n * rand())

    end

    # On genere selon la méthode
    if methode == "carthesien"

        # On initialise les matrices de coordonnées
        entrepot = Array{Float64}(undef, n, 2)
        maison = Array{Float64}(undef, m, 2)
        for i in 1:m

            maison[i, 1] = ceil(Max * rand())
            maison[i, 2] = ceil(Max * rand())
        
        end

        for j in 1:n

            entrepot[j, 1] = ceil(Max * rand())
            entrepot[j, 2] = ceil(Max * rand())

        end

        # On calcule les distances correspondantes
        for i in 1:m

            for j in 1:n

                distance[i, j] = (entrepot[j, 1] - maison[i, 1]) ^ 2 + (entrepot[j, 2] - maison[i, 2]) ^ 2
            
            end
        end

    elseif methode == "aleatoire"

        for i in 1:m

            for j in 1:n

                distance[i, j] = ceil(Max * rand())

            end
        end
    end

    pCentre = PCentre(distance, p)
    return(pCentre)
end
                    
"""
Generation des instances de pCentre
"""

function generatePCentreDataSet()

    # Pour chaque nombre d'entrepot
    for m in [ 10, 20, 30]

        #  Pour chaque nombre de maison
        for n in [ 10, 20, 30]

            # Pour chaque densité considérée
            for methode in ["aleatoire", "carthesien"]

                for p in [2, 4, 6]

                    # Genere 10 instances
                    for instance in 1:10

                        fileName = "../dataPCentre/instance_t" * "_m" * string(m) * "_n" * string(n) * "_p" * string(p) * "_" * methode * "_" * string(instance) * ".txt"
                        println("--Generating file" * fileName)
                        pCentreInstance = generationPCentre(m, n, p, 20, methode)
                        savePCentreInstance(pCentreInstance.A, pCentreInstance.p, fileName)

                    end
                end
            end
        # end
    end
end
end