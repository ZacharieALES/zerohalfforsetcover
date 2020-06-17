mutable struct Instance
    A::Array{Float64}
    b::Array{Float64}
    function Instance()
        return new()
    end
end

# Constructeur de la structure à partir d'une matrice A
function Instance(A::Array{Float64})   
    this = Instance()
    m = size(A)[1]
    n = size(A)[2]
    this.A = Array{Float64}(undef, m, n)
    this.A = A
    this.b = Array{Float64}(undef, m)
    this.b = -ones(Float64, m)
    return(this)
end

# Constructeur de la structure à partir d'une matrice A et d'un vecteur b
function Instance(A::Array{Float64}, b::Array{Float64})
    this = Instance()
    m = size(A)[1]
    n = size(A)[2]
    this.A = Array{Float64}(undef, m, n)
    this.A = A
    this.b = Array{Float64}(undef, m)
    this.b = b
    return(this)
end


# Affichage de la structure

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

mutable struct InstanceResolue
    xBranchAndBound::Array{Float64}
    xBranchAndBoundCoupe::Array{Float64}
    xCoupeSuccessive::Array{Float64}
    tempsBranchAndBound::Float64
    tempsBranchAndBoundCoupe::Float64
    tempsCoupeSuccessive::Float64
    isOptimalBranchAndBound::Bool
    isOptimalBranchAndBoundCoupe::Bool
    entiereCoupeSuccessive::Bool
    bestBoundCoupeSuccessive::Float64
    bestBoundBranchAndBound::Float64
    bestBoundBranchAndBoundCoupe::Float64
    objectifBranchAndBound::Float64
    objectifBranchAndBoundCoupe::Float64
    objectifCoupeSuccessive::Float64
    distanceBranchAndBound::Float64
    distanceBranchAndBoundCoupe::Float64
    distanceCoupeSuccessive::Float64
    function InstanceResolue()
        return new()
    end
end

# Constructeur de la structure pour un n donnée

function InstanceResolue(n::Int64)
    this = InstanceResolue()
    this.xBranchAndBound = Array{Float64}(undef, n)
    this.xBranchAndBoundCoupe = Array{Float64}(undef, n)
    this.xCoupeSuccessive = Array{Float64}(undef, n)
    this.tempsBranchAndBound = -1
    this.tempsBranchAndBoundCoupe = -1
    this.tempsCoupeSuccessive = -1
    this.isOptimalBranchAndBound = false
    this.isOptimalBranchAndBoundCoupe = false
    this.bestBoundCoupeSuccessive = -1
    this.bestBoundBranchAndBound = -1
    this.bestBoundBranchAndBoundCoupe = -1
    this.objectifBranchAndBound = -1
    this.objectifBranchAndBoundCoupe = -1
    this.objectifCoupeSuccessive = -1
    this.entiereCoupeSuccessive = false
    this.distanceBranchAndBound = -1
    this.distanceBranchAndBoundCoupe = -1
    this.distanceCoupeSuccessive = -1
    return(this)
end

# Constructeur de la structure InstanceResolue à partir d'un structure Instance

function InstanceResolue(instance::Instance)

    this = InstanceResolue()
    this.isOptimalBranchAndBound, this.xBranchAndBound, this.tempsBranchAndBound, this.objectifBranchAndBound, this.bestBoundBranchAndBound = branchAndBound(instance.A, instance.b)
    this.isOptimalBranchAndBoundCoupe, this.xBranchAndBoundCoupe, this.tempsBranchAndBoundCoupe, this.objectifBranchAndBoundCoupe, this.bestBoundBranchAndBoundCoupe = branchAndBoundCoupe(instance.A, instance.b)
    this.entiereCoupeSuccessive, this.xCoupeSuccessive, this.tempsCoupeSuccessive, this.objectifCoupeSuccessive, this.bestBoundCoupeSuccessive = coupeSuccessive(instance.A, instance.b)
    this.distanceBranchAndBound  = abs(this.bestBoundBranchAndBound - this.objectifBranchAndBound) / this.objectifBranchAndBound
    this.distanceBranchAndBoundCoupe = abs(this.bestBoundBranchAndBoundCoupe - this.objectifBranchAndBoundCoupe) / this.objectifBranchAndBoundCoupe
    this.distanceCoupeSuccessive = abs(this.bestBoundCoupeSuccessive - this.objectifCoupeSuccessive) / this.objectifCoupeSuccessive
    return(this)
    
end
