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
    xEntierCoupeSuccessive::Array{Float64}
    xCoupeSuccessive::Array{Float64}
    tempsBranchAndBound::Float64
    tempsBranchAndBoundCoupe::Float64
    tempsCoupeSuccessive::Float64
    isOptimalBranchAndBound::Bool
    isOptimalBranchAndBoundCoupe::Bool
    isOptimalCoupeSuccessive::Bool
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
    this.xEntierCoupeSuccessive = Array{Float64}(undef, n)
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
    this.isOptimalCoupeSuccessive = false
    this.distanceBranchAndBound = -1
    this.distanceBranchAndBoundCoupe = -1
    this.distanceCoupeSuccessive = -1
    return(this)
end

# Constructeur de la structure InstanceResolue à partir d'un structure Instance

function InstanceResolue(instance::Instance)

    this = InstanceResolue()
    this.isOptimalBranchAndBound, this.xBranchAndBound, this.tempsBranchAndBound, this.objectifBranchAndBound, this.bestBoundBranchAndBound = branchAndBound(instance.A, instance.b)
    this.isOptimalBranchAndBoundCoupe, this.xBranchAndBoundCoupe, this.tempsBranchAndBoundCoupe, this.objectifBranchAndBoundCoupe, this.bestBoundBranchAndBoundCoupe, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b)
    this.isOptimalCoupeSuccessive, this.xEntierCoupeSuccessive, this.tempsCoupeSuccessive, this.objectifCoupeSuccessive, this.bestBoundCoupeSuccessive, this.xCoupeSuccessive, A_inegalite, b_inegalite = coupeSuccessive(instance.A, instance.b)
    this.distanceBranchAndBound  = abs(this.bestBoundBranchAndBound - this.objectifBranchAndBound) / this.objectifBranchAndBound
    this.distanceBranchAndBoundCoupe = abs(this.bestBoundBranchAndBoundCoupe - this.objectifBranchAndBoundCoupe) / this.objectifBranchAndBoundCoupe
    this.distanceCoupeSuccessive = abs(this.bestBoundCoupeSuccessive - this.objectifCoupeSuccessive) / this.objectifCoupeSuccessive
    return(this)
    
end

mutable struct PCentre
    A::Array{Float64}
    p::Int64
    function PCentre()
        return new()
    end
end

function PCentre(A::Array{Float64}, p::Int64)

    this = PCentre()
    this.A = A
    this.p = p
    return(this)
    
end

mutable struct PCentreResolu
    distanceBranchAndBound::Float64
    xBranchAndBound::Array{Float64}
    resolutionTimeBranchAndBound::Float64
    distanceBranchAndBoundRelaxation::Float64
    xBranchAndBoundRelaxation::Array{Float64}
    resolutionTimeBranchAndBoundRelaxation::Float64
    distanceBranchAndBoundCoupe::Float64
    xBranchAndBoundCoupe::Array{Float64}
    resolutionTimeBranchAndBoundCoupe::Float64
    distanceBranchAndBoundCoupeRelaxation::Float64
    xBranchAndBoundCoupeRelaxation::Array{Float64}
    resolutionTimeBranchAndBoundCoupeRelaxation::Float64
    distanceCoupeSuccessive::Float64
    xCoupeSuccessive::Array{Float64}
    resolutionTimeCoupeSuccessive::Float64
    distanceCoupeSuccessiveRelaxation
    xCoupeSuccessiveRelaxation::Array{Float64}
    resolutionTimeCoupeSuccessiveRelaxation::Float64
    distanceRelaxationClassique
    xRelaxationClassique
    resolutionTimeRelaxationClassique
    distanceRelaxationCoupe
    xRelaxationCoupe
    resolutionTimeRelaxationCoupe
    function PCentreResolu()
        return new()
    end
end

function PCentreResolu(matriceDistance::Array{Float64}, p::Int64)

    this = PCentreResolu()

    this.distanceBranchAndBound, this.xBranchAndBound, this.resolutionTimeBranchAndBound = pCentreEntier(matriceDistance, p, "branchAndBound", false)
    this.distanceBranchAndBoundRelaxation, this.xBranchAndBoundRelaxation, this.resolutionTimeBranchAndBoundRelaxation = pCentreEntier(matriceDistance, p, "branchAndBound", true)
    this.distanceBranchAndBoundCoupe, this.xBranchAndBoundCoupe, this.resolutionTimeBranchAndBoundCoupe = pCentreEntier(matriceDistance, p, "branchAndBoundCoupe", false)
    this.distanceBranchAndBoundCoupeRelaxation, this.xBranchAndBoundCoupeRelaxation, this.resolutionTimeBranchAndBoundCoupeRelaxation = pCentreEntier(matriceDistance, p, "branchAndBoundCoupe", true)
    this.distanceCoupeSuccessive, this.xCoupeSuccessive, this.resolutionTimeCoupeSuccessive = pCentreEntier(matriceDistance, p, "coupeSuccessive", false)   
    this.distanceCoupeSuccessiveRelaxation, this.xCoupeSuccessiveRelaxation, this.resolutionTimeCoupeSuccessiveRelaxation = pCentreEntier(matriceDistance, p, "coupeSuccessive", true)  
    this.distanceRelaxationClassique, this.xRelaxationClassique, this.resolutionTimeRelaxationClassique = pCentreRelaxation(matriceDistance, p, "classique")
    this.distanceRelaxationCoupe, this.xRelaxationCoupe, this.resolutionTimeRelaxationCoupe = pCentreRelaxation(matriceDistance, p, "planCoupantFini")
    return this

end