mutable struct Instance
    A::Array{Float64}
    function Instance()
        return new()
    end
end

# Constructeur de la structure
function Instance(matrice::Array{Float64})   
    this = Instance()
    m = size(matrice)[1]
    n = size(matrice)[2]
    this.A = Array{Float64}(undef, m, n)
    this.A = matrice
    return (this)
end# Affichage de la structure

function Base.show(io::IO, instance::Instance)
    println("A = ")
    m = size(instance.A)[1]
    n = size(instance.A)[2]
    for i in 1:m
        for j in 1:n

            print(instance.A[i, j]," ")

        end
        println("    ")
    end
end