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
    xBranchAndBoundCoupeReduit::Array{Float64}
    xBranchAndBoundPNLE::Array{Float64}
    xBranchAndBoundPNLEHighlyViolated::Array{Float64}
    xBranchAndBoundRien::Array{Float64}
    xEntierCoupeSuccessive::Array{Float64}
    xCoupeSuccessive::Array{Float64}
    tempsBranchAndBound::Float64
    tempsBranchAndBoundCoupe::Float64
    tempsBranchAndBoundCoupeReduit::Float64
    tempsBranchAndBoundPNLE::Float64
    tempsBranchAndBoundPNLEHighlyViolated::Float64
    tempsBranchAndBoundRien::Float64
    tempsCoupeSuccessive::Float64
    isOptimalBranchAndBound::Bool
    isOptimalBranchAndBoundCoupe::Bool
    isOptimalBranchAndBoundCoupeReduit::Bool
    isOptimalBranchAndBoundPNLE::Bool
    isOptimalBranchAndBoundPNLEHighlyViolated::Bool
    isOptimalBranchAndBoundRien::Bool
    isOptimalCoupeSuccessive::Bool
    bestBoundCoupeSuccessive::Float64
    bestBoundBranchAndBound::Float64
    bestBoundBranchAndBoundCoupe::Float64
    bestBoundBranchAndBoundCoupeReduit::Float64
    bestBoundBranchAndBoundPNLE::Float64
    bestBoundBranchAndBoundPNLEHighlyViolated::Float64
    bestBoundBranchAndBoundRien::Float64
    objectifBranchAndBound::Float64
    objectifBranchAndBoundCoupe::Float64
    objectifBranchAndBoundCoupeReduit::Float64
    objectifBranchAndBoundPNLE::Float64
    objectifBranchAndBoundPNLEHighlyViolated::Float64
    objectifBranchAndBoundRien
    objectifCoupeSuccessive::Float64
    distanceBranchAndBound::Float64
    distanceBranchAndBoundCoupe::Float64
    distanceBranchAndBoundCoupeReduit::Float64
    distanceBranchAndBoundPNLE::Float64
    distanceBranchAndBoundPNLEHighlyViolated::Float64
    distanceBranchAndBoundRien::Float64
    distanceCoupeSuccessive::Float64
    function InstanceResolue()
        return new()
    end
end

# Constructeur de la structure pour un n donnée

# function InstanceResolue(n::Int64)
#     this = InstanceResolue()
#     this.xBranchAndBound = Array{Float64}(undef, n)
#     this.xBranchAndBoundCoupe = Array{Float64}(undef, n)
#     this.xEntierCoupeSuccessive = Array{Float64}(undef, n)
#     this.xCoupeSuccessive = Array{Float64}(undef, n)
#     this.tempsBranchAndBound = -1
#     this.tempsBranchAndBoundCoupe = -1
#     this.tempsCoupeSuccessive = -1
#     this.isOptimalBranchAndBound = false
#     this.isOptimalBranchAndBoundCoupe = false
#     this.bestBoundCoupeSuccessive = -1
#     this.bestBoundBranchAndBound = -1
#     this.bestBoundBranchAndBoundCoupe = -1
#     this.objectifBranchAndBound = -1
#     this.objectifBranchAndBoundCoupe = -1
#     this.objectifCoupeSuccessive = -1
#     this.isOptimalCoupeSuccessive = false
#     this.distanceBranchAndBound = -1
#     this.distanceBranchAndBoundCoupe = -1
#     this.distanceCoupeSuccessive = -1
#     return(this)
# end

# Constructeur de la structure InstanceResolue à partir d'un structure Instance

function InstanceResolue(instance::Instance)

    this = InstanceResolue()
    this.isOptimalBranchAndBound, this.xBranchAndBound, this.tempsBranchAndBound, this.objectifBranchAndBound, this.bestBoundBranchAndBound = branchAndBound(instance.A, instance.b)
    this.isOptimalBranchAndBoundRien, this.xBranchAndBoundRien, this.tempsBranchAndBoundRien, this.objectifBranchAndBoundRien, this.bestBoundBranchAndBoundRien, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "Rien")
    this.isOptimalBranchAndBoundCoupe, this.xBranchAndBoundCoupe, this.tempsBranchAndBoundCoupe, this.objectifBranchAndBoundCoupe, this.bestBoundBranchAndBoundCoupe, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "zerohalfcut")
    this.isOptimalBranchAndBoundCoupeReduit, this.xBranchAndBoundCoupeReduit, this.tempsBranchAndBoundCoupeReduit, this.objectifBranchAndBoundCoupeReduit, this.bestBoundBranchAndBoundCoupeReduit, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "zerohalfcutreduit")
    this.isOptimalBranchAndBoundPNLE, this.xBranchAndBoundPNLE, this.tempsBranchAndBoundPNLE, this.objectifBranchAndBoundPNLE, this.bestBoundBranchAndBoundPNLE, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "PNLE")
    this.isOptimalBranchAndBoundPNLEHighlyViolated, this.xBranchAndBoundPNLEHighlyViolated, this.tempsBranchAndBoundPNLEHighlyViolated, this.objectifBranchAndBoundPNLEHighlyViolated, this.bestBoundBranchAndBoundPNLEHighlyViolated, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "PNLEHighlyViolated")
    this.isOptimalBranchAndBoundRien, this.xBranchAndBoundRien, this.tempsBranchAndBoundRien, this.objectifBranchAndBoundRien, this.bestBoundBranchAndBoundRien, A_inegalite, b_inegalite = branchAndBoundCoupe(instance.A, instance.b, [0.0001; 0.0001], "rien")
    this.isOptimalCoupeSuccessive, this.xCoupeSuccessive, this.tempsCoupeSuccessive, this.objectifCoupeSuccessive, this.bestBoundCoupeSuccessive, X4, A_inegalite, b_inegalite = coupeSuccessive(instance.A, instance.b)
    this.distanceBranchAndBound  = abs(this.bestBoundBranchAndBound - this.objectifBranchAndBound) / this.objectifBranchAndBound
    this.distanceBranchAndBoundCoupe = abs(this.bestBoundBranchAndBoundCoupe - this.objectifBranchAndBoundCoupe) / this.objectifBranchAndBoundCoupe
    this.distanceBranchAndBoundCoupeReduit = abs(this.bestBoundBranchAndBoundCoupeReduit - this.objectifBranchAndBoundCoupeReduit) / this.objectifBranchAndBoundCoupeReduit
    this.distanceBranchAndBoundPNLE = abs(this.bestBoundBranchAndBoundPNLE - this.objectifBranchAndBoundPNLE) / this.objectifBranchAndBoundPNLE
    this.distanceBranchAndBoundPNLEHighlyViolated = abs(this.bestBoundBranchAndBoundPNLEHighlyViolated - this.objectifBranchAndBoundPNLEHighlyViolated) / this.objectifBranchAndBoundPNLEHighlyViolated
    this.distanceBranchAndBoundRien = abs(this.bestBoundBranchAndBoundRien - this.objectifBranchAndBoundRien) / this.objectifBranchAndBoundRien
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
    distanceBranchAndBoundRien::Float64
    xBranchAndBoundRien::Array{Float64}
    resolutionTimeBranchAndBoundRien::Float64
    distanceBranchAndBoundCoupeReduit::Float64
    xBranchAndBoundCoupeReduit::Array{Float64}
    resolutionTimeBranchAndBoundCoupeReduit::Float64
    distanceBranchAndBoundPNLE::Float64
    xBranchAndBoundPNLE::Array{Float64}
    resolutionTimeBranchAndBoundPNLE::Float64
    distanceBranchAndBoundPNLEHighlyViolated::Float64
    xBranchAndBoundPNLEHighlyViolated::Array{Float64}
    resolutionTimeBranchAndBoundPNLEHighlyViolated::Float64
    distanceBranchAndBoundBorne::Float64
    xBranchAndBoundBorne::Array{Float64}
    resolutionTimeBranchAndBoundBorne::Float64
    distanceBranchAndBoundRelaxation::Float64
    xBranchAndBoundRelaxation::Array{Float64}
    resolutionTimeBranchAndBoundRelaxation::Float64
    distanceBranchAndBoundCoupe::Float64
    xBranchAndBoundCoupe::Array{Float64}
    resolutionTimeBranchAndBoundCoupe::Float64
    distanceBranchAndBoundCoupeBorne::Float64
    xBranchAndBoundCoupeBorne::Array{Float64}
    resolutionTimeBranchAndBoundCoupeBorne::Float64
    distanceBranchAndBoundCoupeRelaxation::Float64
    xBranchAndBoundCoupeRelaxation::Array{Float64}
    resolutionTimeBranchAndBoundCoupeRelaxation::Float64
    distanceCoupeSuccessive::Float64
    xCoupeSuccessive::Array{Float64}
    resolutionTimeCoupeSuccessive::Float64
    distanceCoupeSuccessiveBorne::Float64
    xCoupeSuccessiveBorne::Array{Float64}
    resolutionTimeCoupeSuccessiveBorne::Float64
    distanceCoupeSuccessiveRelaxation::Float64
    xCoupeSuccessiveRelaxation::Array{Float64}
    resolutionTimeCoupeSuccessiveRelaxation::Float64
    distancePC::Float64
    xPC::Array{Float64}
    resolutionTimePC::Float64
    distancePCSC::Float64
    xPCSC::Array{Float64}
    resolutionTimePCSC::Float64
    distancePCSCBorne::Float64
    xPCSCBorne::Array{Float64}
    resolutionTimePCSCBorne::Float64
    distancePCSCRelaxation::Float64
    xPCSCRelaxation::Array{Float64}
    resolutionTimePCSCRelaxation::Float64
    distanceRelaxationClassique::Float64
    xRelaxationClassique::Array{Float64}
    resolutionTimeRelaxationClassique::Float64
    distanceRelaxationCoupe::Float64
    xRelaxationCoupe::Array{Float64}
    resolutionTimeRelaxationCoupe::Float64
    borneUb0etLb0::Float64
    timeUb0etLb0::Float64
    borneUb1etLb1::Float64
    timeUb1etLb1::Float64
    borneRelaxation::Float64
    timeRelaxation::Float64
    function PCentreResolu()
        return new()
    end
end

function PCentreResolu(matriceDistance::Array{Float64}, p::Int64)

    this = PCentreResolu()
    X0, X1, X2, this.borneUb0etLb0, this.timeUb0etLb0 = pCentreEntier(matriceDistance, p, "branchAndBound", "Ub0EtLb0")
    X0, X1, X2, this.borneUb1etLb1, this.timeUb1etLb1 = pCentreEntier(matriceDistance, p, "branchAndBound", "Ub1EtLb1")
    X0, X1, X2, this.borneRelaxation, this.timeRelaxation = pCentreEntier(matriceDistance, p, "branchAndBound", "Relaxation")   
    this.distanceBranchAndBound, this.xBranchAndBound, this.resolutionTimeBranchAndBound, X3, X4 = pCentreEntier(matriceDistance, p, "branchAndBound", "rien")
    this.distanceBranchAndBoundBorne, this.xBranchAndBoundBorne, this.resolutionTimeBranchAndBoundBorne, X3, X4 = pCentreEntier(matriceDistance, p, "branchAndBound", "Ub1EtLb1")
    this.distanceBranchAndBoundRelaxation, this.xBranchAndBoundRelaxation, this.resolutionTimeBranchAndBoundRelaxation, X3, X4 = pCentreEntier(matriceDistance, p, "branchAndBound", "Relaxation")
    this.distanceBranchAndBoundCoupe, this.xBranchAndBoundCoupe, this.resolutionTimeBranchAndBoundCoupe = pCentreEntier(matriceDistance, p, "branchAndBoundCoupe", "rien")
    this.distanceBranchAndBoundCoupeBorne, this.xBranchAndBoundCoupeBorne, this.resolutionTimeBranchAndBoundCoupeBorne = pCentreEntier(matriceDistance, p, "branchAndBoundCoupe", "Ub1EtLb1")
    this.distanceBranchAndBoundCoupeReduit, this.xBranchAndBoundCoupeReduit, this.resolutionTimeBranchAndBoundCoupeReduit = pCentreEntier(matriceDistance, p, "branchAndBoundCoupeReduit", "Relaxation")
    this.distanceBranchAndBoundPNLE, this.xBranchAndBoundPNLE, this.resolutionTimeBranchAndBoundPNLE = pCentreEntier(matriceDistance, p, "branchAndBoundPNLE", "Relaxation")
    this.distanceBranchAndBoundPNLEHighlyViolated, this.xBranchAndBoundPNLEHighlyViolated, this.resolutionTimeBranchAndBoundPNLEHighlyViolated = pCentreEntier(matriceDistance, p, "branchAndBoundPNLEHighlyViolated", "Relaxation")
    this.distanceBranchAndBoundRien, this.xBranchAndBoundRien, this.resolutionTimeBranchAndBoundRien = pCentreEntier(matriceDistance, p, "branchAndBoundRien", "Relaxation")
    this.distanceBranchAndBoundCoupeRelaxation, this.xBranchAndBoundCoupeRelaxation, this.resolutionTimeBranchAndBoundCoupeRelaxation = pCentreEntier(matriceDistance, p, "branchAndBoundCoupe", "Relaxation")
    this.distanceCoupeSuccessive, this.xCoupeSuccessive, this.resolutionTimeCoupeSuccessive = pCentreEntier(matriceDistance, p, "coupeSuccessive", "rien")   
    this.distanceCoupeSuccessiveBorne, this.xCoupeSuccessiveBorne, this.resolutionTimeCoupeSuccessiveBorne = pCentreEntier(matriceDistance, p, "coupeSuccessive", "Ub1EtLb1")
    this.distanceCoupeSuccessiveRelaxation, this.xCoupeSuccessiveRelaxation, this.resolutionTimeCoupeSuccessiveRelaxation = pCentreEntier(matriceDistance, p, "coupeSuccessive", "Relaxation")
    this.distancePC, this.xPC, this.resolutionTimePC = pCentreEntier(matriceDistance, p, "PC", "rien")  
    this.distancePCSC, this.xPCSC, this.resolutionTimePCSC = pCentreEntier(matriceDistance, p, "PC-SC", "rien")   
    this.distancePCSCBorne, this.xPCSCBorne, this.resolutionTimePCSCBorne = pCentreEntier(matriceDistance, p, "PC-SC", "Ub1EtLb1")
    this.distancePCSCRelaxation, this.xPCSCRelaxation, this.resolutionTimePCSCRelaxation = pCentreEntier(matriceDistance, p, "PC-SC", "Relaxation")  
    this.distanceRelaxationClassique, this.xRelaxationClassique, this.resolutionTimeRelaxationClassique = pCentreRelaxation(matriceDistance, p, "classique")
    this.distanceRelaxationCoupe, this.xRelaxationCoupe, this.resolutionTimeRelaxationCoupe = pCentreRelaxation(matriceDistance, p, "planCoupantFini")
    return this

end